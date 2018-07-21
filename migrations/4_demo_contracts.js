const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const AbacusKernel = artifacts.require("AbacusKernel");
const IdentityToken = artifacts.require("IdentityToken");
const AbacusToken = artifacts.require("AbacusToken");
const ProviderRegistry = artifacts.require("ProviderRegistry");

const AccreditedUSCS = artifacts.require("AccreditedUSCS");
const AccreditedUSToken = artifacts.require("AccreditedUSToken");
const OutsideUSCS = artifacts.require("OutsideUSCS");
const OutsideUSToken = artifacts.require("OutsideUSToken");
const WhitelistCS = artifacts.require("WhitelistCS");
const WhitelistToken = artifacts.require("WhitelistToken");

/**
 * Please make sure artificats for protocol contracts exist before
 * migrating contracts in this script.
 *
 * Run `npx truffle migrate -f 2 --to 4` to migrate contracts in
 * this script with the protocol contracts
 */

module.exports = async deployer => {
  /////////////////
  // DEMO STUFF
  /////////////////

  // deploy Outside US Compliance Standard
  await deployer.deploy(
    OutsideUSCS,
    IdentityToken.address,
    ProviderRegistry.address,
    0,
    await sip.providerId()
  );
  // deploy Outside US Token
  const outsideUSCS = await OutsideUSCS.deployed();
  await outsideUSCS.registerProvider("Outside US", "", false);
  await deployer.deploy(
    OutsideUSToken,
    ComplianceCoordinator.address,
    await outsideUSCS.providerId()
  );

  // deploy Accredited US Compliance Standard
  await deployer.deploy(
    AccreditedUSCS,
    IdentityToken.address,
    ProviderRegistry.address,
    0,
    await sip.providerId()
  );
  const accreditedUSCS = await AccreditedUSCS.deployed();
  await accreditedUSCS.registerProvider("Accredited US", "", false);
  // deploy Accredited US Token
  await deployer.deploy(
    AccreditedUSToken,
    ComplianceCoordinator.address,
    await accreditedUSCS.providerId()
  );

  // deploy whitelist Compliance Standard
  await deployer.deploy(
    WhitelistCS,
    IdentityToken.address,
    ProviderRegistry.address,
    0,
    await sip.providerId()
  );
  const whitelistCS = await WhitelistCS.deployed();
  await whitelistCS.registerProvider("Whitelist", "", false);
  // deploy Whitelist Token
  await deployer.deploy(
    WhitelistToken,
    ComplianceCoordinator.address,
    await whitelistCS.providerId()
  );
};
