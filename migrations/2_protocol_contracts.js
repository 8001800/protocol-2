const ProviderRegistry = artifacts.require("ProviderRegistry");
var ComplianceCoordinator = artifacts.require("./ComplianceCoordinator.sol");
var AbacusToken = artifacts.require("./AbacusToken.sol");
var AbacusKernel = artifacts.require("./AbacusKernel.sol");

module.exports = async deployer => {
  await deployer.deploy(ProviderRegistry);
  await deployer.deploy(ComplianceCoordinator, ProviderRegistry.address);
  // await deployer.deploy(AbacusToken);
  // await deployer.deploy(
  //   AbacusKernel,
  //   AbacusToken.address,
  //   ComplianceCoordinator.address
  // );
};
