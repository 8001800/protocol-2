const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityToken = artifacts.require("IdentityToken");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");

const SampleCompliantToken = artifacts.require("SampleCompliantToken");

const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const BooleanSandboxComplianceStandard = artifacts.require(
  "BooleanSandboxComplianceStandard"
);
const UintSandboxComplianceStandard = artifacts.require(
  "UintSandboxComplianceStandard"
);

const AccreditedUSCS = artifacts.require("AccreditedUSCS");
const AccreditedUSToken = artifacts.require("AccreditedUSToken");
const OutsideUSCS = artifacts.require("OutsideUSCS");
const OutsideUSToken = artifacts.require("OutsideUSToken");
const WhitelistCS = artifacts.require("WhitelistCS");
const WhitelistToken = artifacts.require("WhitelistToken");

const main = async () => {
  const addresses = {
    AnnotationDatabase: AnnotationDatabase.address,
    ProviderRegistry: ProviderRegistry.address,
    ComplianceCoordinator: ComplianceCoordinator.address,
    IdentityToken: IdentityToken.address,
    AbacusToken: AbacusToken.address,
    AbacusKernel: AbacusKernel.address,
    SampleCompliantToken: SampleCompliantToken.address,
    SandboxIdentityProvider: SandboxIdentityProvider.address,
    BooleanSandboxComplianceStandard: BooleanSandboxComplianceStandard.address,
    UintSandboxComplianceStandard: UintSandboxComplianceStandard.address,

    AccreditedUSCS: AccreditedUSCS.address,
    AccreditedUSToken: AccreditedUSToken.address,
    OutsideUSCS: OutsideUSCS.address,
    OutsideUSToken: OutsideUSToken.address,
    WhitelistCS: WhitelistCS.address,
    WhitelistToken: WhitelistToken.address
  };

  console.log(JSON.stringify(addresses));

  //   console.log("\n");

  //   console.log(`
  // export PROV_ADDRESS=${SandboxIdentityProvider.address}
  // export TOKEN_ADDRESS=${IdentityToken.address}
  //   `);
};

module.exports = cb => {
  main()
    .then(res => cb(null, res))
    .catch(err => cb(err));
};
