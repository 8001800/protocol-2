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

  it("should not update the identity if no request", async () => {
    const identityProvider = await BooleanIdentityProvider.new(
      identityCoordinator.address,
      0
    );
    return;
    await identityProvider.registerProvider(
      "Boolean",
      "http://identity.abacusprotocol.com"
    );

    await identityProvider.addPassing(accounts[3]);
    const allowed = await identityProvider.getBoolField(
      accounts[3],
      await identityProvider.FIELD_PASSES()
    );

    assert.false(allowed, "Should not pass since verification is incomplete");
  });
});
