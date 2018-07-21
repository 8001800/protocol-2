const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const ProviderRegistry = artifacts.require("ProviderRegistry");

module.exports = async deployer => {
  await deployer.deploy(ComplianceCoordinator, ProviderRegistry.address);
};
