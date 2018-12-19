const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const IdentityToken = artifacts.require("IdentityToken");
const ProviderRegistry = artifacts.require("ProviderRegistry");

/**
 *  Run `npx truffle migrate -f 2 --to 2` to only migrate contracts on this script"
 */

module.exports = async deployer => {
  await deployer.deploy(ProviderRegistry).then(async () => {
    await deployer.deploy(AnnotationDatabase, ProviderRegistry.address);
    await deployer.deploy(IdentityToken, AnnotationDatabase.address);
  });
};
