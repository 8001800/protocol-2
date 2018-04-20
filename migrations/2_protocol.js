const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const IdentityToken = artifacts.require("IdentityToken");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");

const SampleCompliantToken = artifacts.require("SampleCompliantToken");
const SampleCompliantToken2 = artifacts.require("SampleCompliantToken2");
const SampleCompliantToken3 = artifacts.require("SampleCompliantToken3");

const BooleanSandboxComplianceStandard = artifacts.require(
  "BooleanSandboxComplianceStandard"
);
const UintSandboxComplianceStandard = artifacts.require(
  "UintSandboxComplianceStandard"
);

const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");

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

    console.log("identity", IdentityToken.address, identity.address);
    const kernel = await AbacusKernel.deployed();
    console.log("prov reg", await kernel.providerRegistry());

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

    // // bool compliance standard
    // await deployer.deploy(
    //   BooleanSandboxComplianceStandard,
    //   IdentityToken.address,
    //   ProviderRegistry.address,
    //   0,
    //   await sip.providerId()
    // );
    // const bscs = await BooleanSandboxComplianceStandard.deployed();
    // await bscs.registerProvider("BooleanSandbox", "", false);
    // const bscsId = await bscs.providerId();
    // console.log("BSCS provider id:", bscsId.toString());

    // // bool compliance standard
    // await deployer.deploy(
    //   UintSandboxComplianceStandard,
    //   IdentityToken.address,
    //   ProviderRegistry.address,
    //   0,
    //   await sip.providerId()
    // );
    // const uscs = await UintSandboxComplianceStandard.deployed();
    // await uscs.registerProvider("UintSandbox", "", false);
    // const uscsId = await uscs.providerId();
    // console.log("USCS provider id:", uscsId.toString());

    // // compliant token
    // await deployer.deploy(
    //   SampleCompliantToken,
    //   ComplianceCoordinator.address,
    //   bscsId
    // );

    // // compliant token
    // await deployer.deploy(
    //   SampleCompliantToken2,
    //   ComplianceCoordinator.address,
    //   bscsId
    // );

    // // compliant token
    // await deployer.deploy(
    //   SampleCompliantToken3,
    //   ComplianceCoordinator.address,
    //   uscsId
    // );
  });
};
