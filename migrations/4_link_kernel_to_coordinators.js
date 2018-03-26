const AbacusKernel = artifacts.require("AbacusKernel");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");

module.exports = async deployer => {
  const compliance = await ComplianceCoordinator.deployed();
  await compliance.setKernel(AbacusKernel.address);

  const identity = await IdentityCoordinator.deployed();
  await identity.setKernel(AbacusKernel.address);
};
