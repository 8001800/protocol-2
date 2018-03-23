const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const SampleCompliantToken = artifacts.require("SampleCompliantToken");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const { promisify } = require("es6-promisify");

contract("ComplianceCoordinator", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.new();
    complianceCoordinator = await ComplianceCoordinator.new(
      providerRegistry.address
    );
  });

  it("should ensure registry and compliance", async () => {
    const standard = await WhitelistStandard.new(
      providerRegistry.address,
      0,
      0
    );
    const regReceipt = await standard.registerProvider("Whitelist", "");

    const id = await standard.providerId();
    const owner = await providerRegistry.providerOwner(id);

    assert.equal(standard.address, owner);

    // Create token using list standard
    const token = await SampleCompliantToken.new(
      complianceCoordinator.address,
      id.toString()
    );

    // Authorize account 2 on list standard
    await standard.allow(accounts[2]);

    const { logs: acc1XferLogs } = await token.transfer(accounts[1], 10);
    assert.equal(acc1XferLogs.length, 0);

    const { logs: acc2XferLogs } = await token.transfer(accounts[2], 10);
    assert.equal(acc2XferLogs.length, 1);
    assert.equal(acc2XferLogs[0].event, "Transfer");
    assert.equal(acc2XferLogs[0].args.to, accounts[2]);
    assert.equal(acc2XferLogs[0].args.value.toNumber(), 10);

    const balance1 = await token.balanceOf(accounts[1]);
    const balance2 = await token.balanceOf(accounts[2]);

    assert.equal(balance1.toNumber(), 0);
    assert.equal(balance2.toNumber(), 10);

    const complianceCheckPerformedEvents = await promisify(cb =>
      complianceCoordinator
        .ComplianceCheckPerformed({}, { fromBlock: 0, toBlock: "latest" })
        .get(cb)
    )();

    assert.equal(complianceCheckPerformedEvents.length, 2);

    // first xfer is blocked
    assert.equal(
      complianceCheckPerformedEvents[0].args.providerId.toNumber(),
      id.toNumber()
    );
    assert.equal(
      complianceCheckPerformedEvents[0].args.checkResult.toNumber(),
      1
    );

    // second xfer is permitted
    assert.equal(
      complianceCheckPerformedEvents[1].args.providerId.toNumber(),
      id.toNumber()
    );
    assert.equal(
      complianceCheckPerformedEvents[1].args.checkResult.toNumber(),
      0
    );
  });

  it("should support delegation", async () => {
    const standard = await WhitelistStandard.new(
      providerRegistry.address,
      0,
      0
    );
    await standard.registerProvider("Whitelist", "");

    const id = await standard.providerId();
    const owner = await providerRegistry.providerOwner(id);

    const parentStandard = await WhitelistStandard.new(
      providerRegistry.address,
      0,
      id
    );
    await parentStandard.registerProvider("ParentWhitelist", "");
    const parentId = await parentStandard.providerId();

    assert.equal(standard.address, owner);
    assert.equal(
      parentStandard.address,
      await providerRegistry.providerOwner(parentId)
    );

    // Create token using list standard
    const token = await SampleCompliantToken.new(
      complianceCoordinator.address,
      parentId.toString()
    );

    // Authorize account 2 on both standards
    await standard.allow(accounts[2]);
    await parentStandard.allow(accounts[2]);

    // Authorize account 3 only on parent standard
    await parentStandard.allow(accounts[3]);

    const { logs: acc1XferLogs } = await token.transfer(accounts[1], 10);
    assert.equal(acc1XferLogs.length, 0);

    const { logs: acc2XferLogs } = await token.transfer(accounts[2], 10);
    assert.equal(acc2XferLogs.length, 1);
    assert.equal(acc2XferLogs[0].event, "Transfer");
    assert.equal(acc2XferLogs[0].args.to, accounts[2]);
    assert.equal(acc2XferLogs[0].args.value.toNumber(), 10);

    const { logs: acc3XferLogs } = await token.transfer(accounts[3], 10);
    assert.equal(acc3XferLogs.length, 0);

    const balance1 = await token.balanceOf(accounts[1]);
    const balance2 = await token.balanceOf(accounts[2]);
    const balance3 = await token.balanceOf(accounts[3]);

    assert.equal(balance1.toNumber(), 0);
    assert.equal(balance2.toNumber(), 10);
    assert.equal(balance3.toNumber(), 0);

    const complianceCheckPerformedEvents = await promisify(cb =>
      complianceCoordinator
        .ComplianceCheckPerformed({}, { fromBlock: 0, toBlock: "latest" })
        .get(cb)
    )();

    assert.equal(complianceCheckPerformedEvents.length, 5);

    // first xfer is blocked by the parent
    assert.equal(
      complianceCheckPerformedEvents[0].args.providerId.toNumber(),
      parentId.toNumber()
    );
    assert.equal(complianceCheckPerformedEvents[0].args.to, accounts[1]);
    assert.equal(
      complianceCheckPerformedEvents[0].args.checkResult.toNumber(),
      1
    );

    // second xfer is fully permitted
    assert.equal(
      complianceCheckPerformedEvents[1].args.providerId.toNumber(),
      parentId.toNumber()
    );
    assert.equal(complianceCheckPerformedEvents[1].args.to, accounts[2]);
    assert.equal(
      complianceCheckPerformedEvents[1].args.checkResult.toNumber(),
      0
    );
    assert.equal(
      complianceCheckPerformedEvents[2].args.providerId.toNumber(),
      id.toNumber()
    );
    assert.equal(complianceCheckPerformedEvents[2].args.to, accounts[2]);
    assert.equal(
      complianceCheckPerformedEvents[2].args.checkResult.toNumber(),
      0
    );

    // third xfer is permitted by parent, blocked by child
    assert.equal(
      complianceCheckPerformedEvents[3].args.providerId.toNumber(),
      parentId.toNumber()
    );
    assert.equal(complianceCheckPerformedEvents[3].args.to, accounts[3]);
    assert.equal(
      complianceCheckPerformedEvents[3].args.checkResult.toNumber(),
      0
    );
    assert.equal(
      complianceCheckPerformedEvents[4].args.providerId.toNumber(),
      id.toNumber()
    );
    assert.equal(complianceCheckPerformedEvents[4].args.to, accounts[3]);
    assert.equal(
      complianceCheckPerformedEvents[4].args.checkResult.toNumber(),
      1
    );
  });
});
