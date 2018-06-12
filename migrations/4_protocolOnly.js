const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityToken = artifacts.require("IdentityToken");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const ProviderRegistry = artifacts.require("ProviderRegistry");

/**
 *  Run `npx truffle migrate -f 4 --to 4` to only migrate contracts on this script"
 */

module.exports = async deployer => {
    await deployer.deploy(ProviderRegistry).then(async () => {
        await deployer.deploy(ComplianceCoordinator, ProviderRegistry.address);
        await deployer.deploy(AbacusToken);
        await deployer.deploy(
          AbacusKernel,
          AbacusToken.address,
          ProviderRegistry.address,
          ComplianceCoordinator.address
        );
        const compliance = await ComplianceCoordinator.deployed();
        await compliance.setKernel(AbacusKernel.address);
    
        await deployer.deploy(AnnotationDatabase, ProviderRegistry.address);
        await deployer.deploy(IdentityToken, AnnotationDatabase.address);
    });
};
