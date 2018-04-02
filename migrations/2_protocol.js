const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");

const BooleanIdentityProvider = artifacts.require("BooleanIdentityProvider");
const BooleanIdentityComplianceStandard = artifacts.require(
  "BooleanIdentityComplianceStandard"
);

module.exports = async deployer => {
  await deployer.deploy(ProviderRegistry);
  await deployer.deploy(ComplianceCoordinator, ProviderRegistry.address);
  await deployer.deploy(IdentityCoordinator, ProviderRegistry.address);
  await deployer.deploy(AbacusToken);
  await deployer.deploy(
    AbacusKernel,
    AbacusToken.address,
    ComplianceCoordinator.address,
    IdentityCoordinator.address,
    ProviderRegistry.address
  );
  const compliance = await ComplianceCoordinator.deployed();
  await compliance.setKernel(AbacusKernel.address);

  const identity = await IdentityCoordinator.deployed();
  await identity.setKernel(AbacusKernel.address);

  // TEST stuff
  const identityProvider = await BooleanIdentityProvider.new(
    IdentityCoordinator.address,
    0
  );
  await identityProvider.registerProvider("Boolean", "");
  const identityProviderId = await identityProvider.providerId();
  console.log("Identity provider id:", identityProviderId.toString());
  console.log("Identity provider address:", identityProvider.address);

  const cs = await BooleanIdentityComplianceStandard.new(
    ProviderRegistry.address,
    0,
    identityProviderId
  );
  await cs.registerProvider("BooleanIdentity", "");
  const csId = await cs.providerId();
  console.log("CS provider id:", csId.toString());
  console.log("CS address:", cs.address);
};
