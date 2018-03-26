const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");

module.exports = async deployer => {
  await deployer.deploy(AbacusToken);
  await deployer.deploy(
    AbacusKernel,
    ComplianceCoordinator.address,
    IdentityCoordinator.address,
    ProviderRegistry.address
  );
};
