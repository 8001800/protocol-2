const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const SampleCompliantToken = artifacts.require("SampleCompliantToken");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const BooleanIdentityProvider = artifacts.require("BooleanIdentityProvider");
const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");

contract("IdentityCoordinator", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let identityCoordinator = null;
  let aba = null;
  let kernel = null;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.new();
    complianceCoordinator = await ComplianceCoordinator.new(
      providerRegistry.address
    );
    identityCoordinator = await IdentityCoordinator.new(
      providerRegistry.address
    );
    aba = await AbacusToken.new();
    kernel = await AbacusKernel.new(
      aba.address,
      complianceCoordinator.address,
      identityCoordinator.address,
      providerRegistry.address
    );

    await complianceCoordinator.setKernel(kernel.address);
    await identityCoordinator.setKernel(kernel.address);
    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1));
  });

  it("should update the identity if request exists", async () => {
    const identityProvider = await BooleanIdentityProvider.new(
      identityCoordinator.address,
      0
    );
    await identityProvider.registerProvider(
      "Boolean",
      "http://identity.abacusprotocol.com"
    );

    const requestId = 1289479214;
    const cost = 0;

    const { logs: reqLogs } = await identityCoordinator.requestVerification(
      await identityProvider.providerId(),
      "",
      cost,
      requestId,
      { from: accounts[3] }
    );
    assert.equal(reqLogs.length, 1);
    assert.equal(reqLogs[0].args.requestId, requestId);

    await identityProvider.addPassing(accounts[3], requestId);
    const allowed = await identityProvider.getBoolField(
      accounts[3],
      await identityProvider.FIELD_PASSES()
    );

    assert(allowed, "Should be allowed in identity provider");
  });

  it("should not update the identity if no request", async () => {
    const identityProvider = await BooleanIdentityProvider.new(
      identityCoordinator.address,
      0
    );
    await identityProvider.registerProvider(
      "Boolean",
      "http://identity.abacusprotocol.com"
    );

    await identityProvider.addPassing(accounts[3], 123);
    const allowed = await identityProvider.getBoolField(
      accounts[3],
      await identityProvider.FIELD_PASSES()
    );

    assert(!allowed, "Should not pass since verification is incomplete");
  });
});
