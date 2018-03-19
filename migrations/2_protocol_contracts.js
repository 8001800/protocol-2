var ComplianceCoordinator = artifacts.require("./ComplianceCoordinator.sol");
var AbacusToken = artifacts.require("./AbacusToken.sol");
var AbacusKernel = artifacts.require("./AbacusKernel.sol");

module.exports = function(deployer) {
  deployer
    .deploy(ComplianceCoordinator)
    .then(() => {
      return deployer.deploy(AbacusToken);
    })
    .then(() => {
      return deployer.deploy(
        AbacusKernel,
        AbacusToken.address,
        ComplianceCoordinator.address
      );
    });
};
