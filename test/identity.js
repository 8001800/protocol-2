const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const SampleCompliantToken = artifacts.require("SampleCompliantToken");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");

contract("IdentityCoordinator", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let identityCoordinator = null;
  let aba = null;
  let kernel = null;
  let identityProvider = null;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    identityCoordinator = await IdentityCoordinator.deployed();
    aba = await AbacusToken.deployed();
    kernel = await AbacusKernel.deployed();

    identityProvider = await SandboxIdentityProvier.deployed();

    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1));
  });

  it("should update the identity if request exists", async () => {
    const requestId = 1289479214;
    const cost = 0;

    const { logs: reqLogs } = await identityCoordinator.requestVerification(
      await identityProvider.providerId(),
      cost,
      requestId,
      10,
      { from: accounts[3] }
    );
    assert.equal(reqLogs.length, 1);
    assert.equal(reqLogs[0].args.requestId, requestId);

    await identityProvider.writeBytes32Field(accounts[3], requestId, 88, "0x1");
    const allowed = await identityCoordinator.bytes32Data(
      await identityProvider.providerId(),
      accounts[3],
      88
    );

    assert(allowed.includes("1"), "Should be allowed in identity provider");
  });

  it("should not update the identity if no request", async () => {
    await identityProvider.writeBytes32Field(accounts[3], 123, 88, "0x1");
    const allowed = await identityCoordinator.bytes32Data(
      await identityProvider.providerId(),
      accounts[3],
      88
    );

    assert(
      !allowed.includes("1"),
      "Should not pass since verification is incomplete"
    );
  });
});
