const SandboxComplianceProvider = artifacts.require(
  "SandboxComplianceProvider"
);
const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const AbacusKernel = artifacts.require("AbacusKernel");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");

/**
 *  Please make sure artificats for AbacusKernel and ComplianceToken exist before
 *  migrating contracts in this script.
 *  Run `npx truffle migrate -f 2 --to 3` to only migrate contracts in this script
 *  with the protocol.
 */

module.exports = async deployer => {
  await deployer.deploy(
    SandboxComplianceProvider,
    AbacusKernel.address,
    AnnotationDatabase.address,
    0,
    ComplianceCoordinator.address
  );

  const sip = await SandboxComplianceProvider.deployed();
  await sip.registerProvider("Sandbox Compliance", "", true);
};
