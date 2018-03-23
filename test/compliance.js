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
    const standard = await WhitelistStandard.new(providerRegistry.address, 0);
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
});
