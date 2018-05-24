const Bundle = artifacts.require("Bundle");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");

module.exports = async deployer => {
  await deployer.deploy(Bundle, ComplianceCoordinator.address);
};
