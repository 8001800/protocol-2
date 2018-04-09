const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const IdentityDatabase = artifacts.require("IdentityDatabase");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");

const BooleanIdentityProvider = artifacts.require("BooleanIdentityProvider");
const BooleanIdentityComplianceStandard = artifacts.require(
  "BooleanIdentityComplianceStandard"
);
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
    await deployer.deploy(IdentityCoordinator, ProviderRegistry.address);
    await deployer.deploy(IdentityDatabase, ProviderRegistry.address);
    await deployer.deploy(AbacusToken);
    await deployer.deploy(
      AbacusKernel,
      AbacusToken.address,
      ProviderRegistry.address,
      ComplianceCoordinator.address,
      IdentityCoordinator.address
    );
    const compliance = await ComplianceCoordinator.deployed();
    await compliance.setKernel(AbacusKernel.address);

    const identity = await IdentityCoordinator.deployed();
    await identity.setKernel(AbacusKernel.address);

    // bool identity provider
    await deployer.deploy(
      BooleanIdentityProvider,
      IdentityDatabase.address,
      IdentityCoordinator.address,
      0
    );
    const identityProvider = await BooleanIdentityProvider.deployed();
    await identityProvider.registerProvider("Boolean", "", true);
    const identityProviderId = await identityProvider.providerId();
    console.log("Identity provider id:", identityProviderId.toString());
    console.log("Identity provider address:", identityProvider.address);

    // Sandbox identity provider
    await deployer.deploy(
      SandboxIdentityProvider,
      IdentityDatabase.address,
      IdentityCoordinator.address,
      0
    );
    const sip = await SandboxIdentityProvider.deployed();
    await sip.registerProvider("SandboxIdentity", "", false);

    // bool compliance standard
    await deployer.deploy(
      BooleanIdentityComplianceStandard,
      IdentityDatabase.address,
      ProviderRegistry.address,
      0,
      identityProviderId
    );
    const bics = await BooleanIdentityComplianceStandard.deployed();
    await bics.registerProvider("BooleanIdentity", "", false);
    const bicsId = await bics.providerId();
    console.log("BICS provider id:", bicsId.toString());

    // bool compliance standard
    await deployer.deploy(
      BooleanSandboxComplianceStandard,
      IdentityDatabase.address,
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
      IdentityDatabase.address,
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
      bicsId
    );

    // compliant token
    await deployer.deploy(
      SampleCompliantToken2,
      ComplianceCoordinator.address,
      bscsId
    );

    // compliant token
    await deployer.deploy(
      SampleCompliantToken3,
      ComplianceCoordinator.address,
      uscsId
    );
  });
};
