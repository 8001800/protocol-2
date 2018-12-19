const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const IdentityToken = artifacts.require("IdentityToken");
const ProviderRegistry = artifacts.require("ProviderRegistry");

/**
 *  Please make sure artifacts for ProviderRegistry and IdentityToken exist before
 *  migrating contracts in this script.
 *  Run `npx truffle migrate -f 2 --to 3` to only migrate contracts in this script
 *  with the protocol.
 */

module.exports = async deployer => {
  await deployer.deploy(
    SandboxIdentityProvider,
    ProviderRegistry.address,
    IdentityToken.address,
    0
  );

  const sip = await SandboxIdentityProvider.deployed();
  await sip.registerProvider("Sandbox Identity", "", true);
};
