const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const SampleCompliantToken = artifacts.require("SampleCompliantToken");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const BooleanSandboxComplianceStandard = artifacts.require(
  "BooleanSandboxComplianceStandard"
);

const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");

contract("E2E compliance and identity", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let identityCoordinator = null;
  let aba = null;
  let kernel = null;

  let identityProvider = null;
  let complianceStandard = null;
  let ctoken = null;

  before(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    identityCoordinator = await IdentityCoordinator.deployed();
    aba = await AbacusToken.deployed();
    kernel = await AbacusKernel.deployed();

    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1));

    identityProvider = await SandboxIdentityProvider.deployed();
    complianceStandard = await BooleanSandboxComplianceStandard.deployed();
    ctoken = await SampleCompliantToken.deployed();
  });

  it("should allow transaction for both approved by identity provider", async () => {
    const requestId1 = 1234;
    const requestId2 = 5678;
    const cost = 0;

    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1), {
      from: accounts[0]
    });
    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1), {
      from: accounts[4]
    });

    const { logs: reqLogs1 } = await identityCoordinator.requestVerification(
      await identityProvider.providerId(),
      cost,
      requestId1,
      10,
      { from: accounts[0] }
    );
    assert.equal(reqLogs1.length, 1);
    assert.equal(reqLogs1[0].args.requestId, requestId1);

    await identityProvider.writeBytes32Field(accounts[0], requestId, 88, "0x1");

    const { logs: reqLogs2 } = await identityCoordinator.requestVerification(
      await identityProvider.providerId(),
      cost,
      requestId2,
      10,
      { from: accounts[4] }
    );
    assert.equal(reqLogs2.length, 1);
    assert.equal(reqLogs2[0].args.requestId, requestId2);

    await identityProvider.writeBytes32Field(
      accounts[4],
      requestId2,
      88,
      "0x1"
    );

    const { logs: xferLogs } = await ctoken.transfer(accounts[4], 100);
    assert.equal(xferLogs.length, 1);
  });
});
