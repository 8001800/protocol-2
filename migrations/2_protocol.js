const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");

module.exports = async deployer => {
  await deployer.deploy(ProviderRegistry);
  await deployer.deploy(ComplianceCoordinator, ProviderRegistry.address);
  await deployer.deploy(IdentityCoordinator, ProviderRegistry.address);
  await deployer.deploy(AbacusToken);
  await deployer.deploy(
    AbacusKernel,
    ComplianceCoordinator.address,
    IdentityCoordinator.address,
    ProviderRegistry.address
  );
  const compliance = await ComplianceCoordinator.deployed();
  await compliance.setKernel(AbacusKernel.address);

  const identity = await IdentityCoordinator.deployed();
  await identity.setKernel(AbacusKernel.address);
};
