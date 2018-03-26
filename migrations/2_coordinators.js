const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");

module.exports = async deployer => {
  await deployer.deploy(ProviderRegistry);
  await deployer.deploy(ComplianceCoordinator, ProviderRegistry.address);
  await deployer.deploy(IdentityCoordinator, ProviderRegistry.address);
};
