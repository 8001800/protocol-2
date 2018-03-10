var ComplianceRegistry = artifacts.require("./ComplianceRegistry.sol");
var AbacusToken = artifacts.require("./AbacusToken.sol");
var AbacusKernel = artifacts.require("./AbacusKernel.sol");

module.exports = function(deployer) {
  deployer
    .deploy(ComplianceRegistry)
    .then(() => {
      return deployer.deploy(AbacusToken);
    })
    .then(() => {
      return deployer.deploy(
        AbacusKernel,
        AbacusToken.address,
        ComplianceRegistry.address
      );
    });
};
