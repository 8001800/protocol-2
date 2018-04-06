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
    console.log(IdentityDatabase.address, IdentityCoordinator.address);
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

    // bool compliance standard
    await deployer.deploy(
      BooleanIdentityComplianceStandard,
      IdentityDatabase.address,
      ProviderRegistry.address,
      0,
      identityProviderId
    );
    const cs = await BooleanIdentityComplianceStandard.deployed();
    await cs.registerProvider("BooleanIdentity", "", false);
    const csId = await cs.providerId();
    console.log("CS provider id:", csId.toString());
    console.log("CS address:", cs.address);

    // compliant token
    await deployer.deploy(
      SampleCompliantToken,
      ComplianceCoordinator.address,
      csId
    );

    await deployer.deploy(
      SandboxIdentityProvider,
      IdentityDatabase.address,
      IdentityCoordinator.address,
      0
    );
  });
};
