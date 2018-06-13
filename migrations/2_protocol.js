const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const IdentityToken = artifacts.require("IdentityToken");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const Bundle = artifacts.require("Bundle");

const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");

const AccreditedUSCS = artifacts.require("AccreditedUSCS");
const AccreditedUSToken = artifacts.require("AccreditedUSToken");
const OutsideUSCS = artifacts.require("OutsideUSCS");
const OutsideUSToken = artifacts.require("OutsideUSToken");
const WhitelistCS = artifacts.require("WhitelistCS");
const WhitelistToken = artifacts.require("WhitelistToken");

module.exports = async deployer => {
  await deployer.deploy(ProviderRegistry).then(async () => {
    await deployer.deploy(ComplianceCoordinator, ProviderRegistry.address);
    await deployer.deploy(AbacusToken);
    await deployer.deploy(
      AbacusKernel,
      AbacusToken.address,
      ProviderRegistry.address
    );
    const compliance = await ComplianceCoordinator.deployed();

    await deployer.deploy(AnnotationDatabase, ProviderRegistry.address);
    await deployer.deploy(IdentityToken, AnnotationDatabase.address);
    const identity = await IdentityToken.deployed();

    // Sandbox identity provider
    await deployer.deploy(
      artifacts.require("IdentityProvider"),
      IdentityToken.address,
      ProviderRegistry.address,
      0
    );

    await deployer.deploy(
      SandboxIdentityProvider,
      AbacusKernel.address,
      IdentityToken.address,
      0
    );
    const sip = await SandboxIdentityProvider.deployed();
    await sip.registerProvider("SandboxIdentity", "", false);

    // Bundle Protocol
    await deployer.deploy(Bundle, ComplianceCoordinator.address);

    /////////////////
    // DEMO STUFF
    /////////////////

    // outside US token
    await deployer.deploy(
      OutsideUSCS,
      IdentityToken.address,
      ProviderRegistry.address,
      0,
      await sip.providerId()
    );
    const outsideUSCS = await OutsideUSCS.deployed();
    await outsideUSCS.registerProvider("Outside US", "", false);
    await deployer.deploy(
      OutsideUSToken,
      ComplianceCoordinator.address,
      await outsideUSCS.providerId()
    );

    // accredited US token
    await deployer.deploy(
      AccreditedUSCS,
      IdentityToken.address,
      ProviderRegistry.address,
      0,
      await sip.providerId()
    );
    const accreditedUSCS = await AccreditedUSCS.deployed();
    await accreditedUSCS.registerProvider("Accredited US", "", false);
    await deployer.deploy(
      AccreditedUSToken,
      ComplianceCoordinator.address,
      await accreditedUSCS.providerId()
    );

    // whitelist token
    await deployer.deploy(
      WhitelistCS,
      IdentityToken.address,
      ProviderRegistry.address,
      0,
      await sip.providerId()
    );
    const whitelistCS = await WhitelistCS.deployed();
    await whitelistCS.registerProvider("Whitelist", "", false);
    await deployer.deploy(
      WhitelistToken,
      ComplianceCoordinator.address,
      await whitelistCS.providerId()
    );
  });
};
