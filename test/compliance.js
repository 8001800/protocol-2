const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const SampleCompliantToken = artifacts.require("SampleCompliantToken");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");

contract("ComplianceCoordinator", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let identityCoordinator = null;
  let aba = null;
  let kernel = null;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    identityCoordinator = await IdentityCoordinator.deployed();
    aba = await AbacusToken.deployed();
    kernel = await AbacusKernel.deployed();

    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1));
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
    const { receipt: { blockNumber } } = await standard.registerProvider(
      "Whitelist",
      ""
    );

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
    const lol = await standard.allow(accounts[2]);
    console.log(lol);
    await parentStandard.allow(accounts[2]);

    // Authorize account 3 only on parent standard
    await parentStandard.allow(accounts[3]);

    const { logs: acc1XferLogs, ...test } = await token.transfer(
      accounts[1],
      10
    );
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
        .ComplianceCheckPerformed(
          {},
          { fromBlock: blockNumber, toBlock: "latest" }
        )
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

  it("should support off-chain checks", async () => {
    // Create off chain standard
    const { logs } = await providerRegistry.registerProvider(
      "Ian",
      "some sort of ipfs hash",
      accounts[3]
    );
    const id = logs[0].args.id;
    const owner = await providerRegistry.providerOwner(id);
    assert.equal(accounts[3], owner);

    // Create token using list standard
    const token = await SampleCompliantToken.new(
      complianceCoordinator.address,
      id.toString()
    );

    const params = {
      instrumentAddr: token.address,
      instrumentIdOrAmt: 10,
      from: accounts[0],
      to: accounts[1],
      cost: 10
    };

    // This should be blocked.
    const { logs: acc1XferLogs } = await token.transfer(accounts[1], 10);
    assert.equal(acc1XferLogs.length, 0);

    // Make a request
    const { logs: requestCheckLogs } = await complianceCoordinator.requestCheck(
      id,
      params.instrumentAddr,
      params.instrumentIdOrAmt,
      params.from,
      params.to,
      [],
      params.cost
    );

    assert.equal(requestCheckLogs.length, 1);
    assert.equal(requestCheckLogs[0].event, "ComplianceCheckRequested");
    assert.equal(requestCheckLogs[0].args.cost.toNumber(), params.cost);

    const {
      logs: writeCheckLogs
    } = await complianceCoordinator.writeCheckResult(
      id,
      1,
      params.instrumentAddr,
      params.instrumentIdOrAmt,
      params.from,
      params.to,
      0, // no data
      999999999,
      0,
      { from: accounts[3] }
    );

    assert.equal(writeCheckLogs.length, 1);
    assert.equal(writeCheckLogs[0].event, "ComplianceCheckResultWritten");
    assert.equal(writeCheckLogs[0].args.checkResult.toNumber(), 0);
    assert.equal(await aba.balanceOf(accounts[3]), params.cost);

    // Test transfer is allowed
    const { logs: acc1XferLogsSuccess } = await token.transfer(
      accounts[1],
      params.instrumentIdOrAmt
    );
    assert.equal(acc1XferLogsSuccess.length, 1);
    assert.equal(acc1XferLogsSuccess[0].event, "Transfer");

    // Second transfer should fail, since check result is consumed
    const { logs: acc1XferLogsSuccess2 } = await token.transfer(
      accounts[1],
      params.instrumentIdOrAmt
    );
    assert.equal(acc1XferLogsSuccess2.length, 0);
  });

  it("should error on nonexistent provider", async () => {
    const params = {
      instrumentAddr: accounts[0], // doesn't matter
      instrumentIdOrAmt: 10,
      from: accounts[0],
      to: accounts[1]
    };

    const {
      logs: writeCheckLogs
    } = await complianceCoordinator.writeCheckResult(
      1, // nonexistent id
      0, // arbitrary version (shouldn't matter)
      params.instrumentAddr,
      params.instrumentIdOrAmt,
      params.from,
      params.to,
      [],
      999999999,
      0
    );

    assert.equal(writeCheckLogs.length, 0);
  });

  it("should error on incorrect provider version", async () => {
    // Create off chain standard
    const { logs } = await providerRegistry.registerProvider(
      "Ian",
      "some sort of ipfs hash",
      accounts[0]
    );
    const id = logs[0].args.id;
    const owner = await providerRegistry.providerOwner(id);
    assert.equal(accounts[0], owner);

    const params = {
      instrumentAddr: accounts[0], // doesn't matter
      instrumentIdOrAmt: 10,
      from: accounts[0],
      to: accounts[1]
    };

    const {
      logs: writeCheckLogs
    } = await complianceCoordinator.writeCheckResult(
      id,
      42, // wrong version
      params.instrumentAddr,
      params.instrumentIdOrAmt,
      params.from,
      params.to,
      [],
      999999999,
      0
    );

    assert.equal(writeCheckLogs.length, 0);
  });

  it("should error on incorrect service owner", async () => {
    // Create off chain standard
    const { logs } = await providerRegistry.registerProvider(
      "Ian",
      "some sort of ipfs hash",
      accounts[0]
    );
    const id = logs[0].args.id;
    const owner = await providerRegistry.providerOwner(id);
    assert.equal(accounts[0], owner);

    const params = {
      instrumentAddr: accounts[0], // doesn't matter
      instrumentIdOrAmt: 10,
      from: accounts[0],
      to: accounts[1]
    };

    const {
      logs: writeCheckLogs
    } = await complianceCoordinator.writeCheckResult(
      id,
      1, // current version of provider
      params.instrumentAddr,
      params.instrumentIdOrAmt,
      params.from,
      params.to,
      [],
      999999999,
      0,
      {
        from: accounts[1] // wrong owner
      }
    );

    assert.equal(writeCheckLogs.length, 0);
  });
});
