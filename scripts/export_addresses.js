const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityToken = artifacts.require("IdentityToken");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");

const SampleCompliantToken = artifacts.require("SampleCompliantToken");
const SampleCompliantToken2 = artifacts.require("SampleCompliantToken2");
const SampleCompliantToken3 = artifacts.require("SampleCompliantToken3");

const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const BooleanSandboxComplianceStandard = artifacts.require(
  "BooleanSandboxComplianceStandard"
);
const UintSandboxComplianceStandard = artifacts.require(
  "UintSandboxComplianceStandard"
);

const main = async () => {
  const addresses = {
    AnnotationDatabase: AnnotationDatabase.address,
    ProviderRegistry: ProviderRegistry.address,
    ComplianceCoordinator: ComplianceCoordinator.address,
    IdentityToken: IdentityToken.address,
    AbacusToken: AbacusToken.address,
    AbacusKernel: AbacusKernel.address,
    SampleCompliantToken: SampleCompliantToken.address,
    SampleCompliantToken2: SampleCompliantToken2.address,
    SampleCompliantToken3: SampleCompliantToken3.address,
    SandboxIdentityProvider: SandboxIdentityProvider.address,
    BooleanSandboxComplianceStandard: BooleanSandboxComplianceStandard.address,
    UintSandboxComplianceStandard: UintSandboxComplianceStandard.address
  };

  console.log(JSON.stringify(addresses));

  console.log("\n");

  console.log(`
export PROV_ADDRESS=${SandboxIdentityProvider.address}
export TOKEN_ADDRESS=${IdentityToken.address}
  `);
};

module.exports = cb => {
  main()
    .then(res => cb(null, res))
    .catch(err => cb(err));
};
