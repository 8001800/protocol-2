const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const IdentityToken = artifacts.require("IdentityToken");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");

const SampleCompliantToken = artifacts.require("SampleCompliantToken");

const BooleanSandboxComplianceStandard = artifacts.require(
  "BooleanSandboxComplianceStandard"
);
const UintSandboxComplianceStandard = artifacts.require(
  "UintSandboxComplianceStandard"
);

const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");

const AccreditedUSCS = artifacts.require("AccreditedUSCS");
const AccreditedUSToken = artifacts.require("AccreditedUSToken");
const OutsideUSCS = artifacts.require("OutsideUSCS");
const OutsideUSToken = artifacts.require("OutsideUSToken");
const WhitelistCS = artifacts.require("WhitelistCS");
const WhitelistToken = artifacts.require("WhitelistToken");

const ABAFaucet = artifacts.require("ABAFaucet");

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

    // bool compliance standard
    await deployer.deploy(
      BooleanSandboxComplianceStandard,
      IdentityToken.address,
      ProviderRegistry.address,
      0,
      await sip.providerId()
    );
    const bscs = await BooleanSandboxComplianceStandard.deployed();
    await bscs.registerProvider("BooleanSandbox", "", false);
    const bscsId = await bscs.providerId();
    console.log("BSCS provider id:", bscsId.toString());

    // bool compliance standard
    await deployer.deploy(
      UintSandboxComplianceStandard,
      IdentityToken.address,
      ProviderRegistry.address,
      0,
      await sip.providerId()
    );
    const uscs = await UintSandboxComplianceStandard.deployed();
    await uscs.registerProvider("UintSandbox", "", false);
    const uscsId = await uscs.providerId();
    console.log("USCS provider id:", uscsId.toString());

    // compliant token
    await deployer.deploy(
      SampleCompliantToken,
      ComplianceCoordinator.address,
      bscsId
    );

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

    await deployer.deploy(ABAFaucet, AbacusToken.address);
  });
};
