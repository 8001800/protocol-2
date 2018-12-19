const SandboxComplianceProvider = artifacts.require(
  "SandboxComplianceProvider"
);
const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const ProviderRegistry = artifacts.require("ProviderRegistry");

/**
 *  Please make sure artifacts for ProviderRegistry and ComplianceToken exist before
 *  migrating contracts in this script.
 *  Run `npx truffle migrate -f 2 --to 3` to only migrate contracts in this script
 *  with the protocol.
 */

module.exports = async deployer => {
  await deployer.deploy(
    SandboxComplianceProvider,
    ProviderRegistry.address,
    AnnotationDatabase.address,
    0,
    ComplianceCoordinator.address
  );

  const sip = await SandboxComplianceProvider.deployed();
  await sip.registerProvider("Sandbox Compliance", "", true);
};
