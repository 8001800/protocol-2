const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const ProviderRegistry = artifacts.require("ProviderRegistry");

/**
 *  Please make sure artificats for ProviderRegistry exist before 
 *  migrating contracts in this script.
 *  Run `npx truffle migrate -f 2 --to 3` to only migrate contracts in this script 
 *  with the protocol.
 */

module.exports = async deployer => {
    await deployer.deploy(ComplianceCoordinator, ProviderRegistry.address);
};
