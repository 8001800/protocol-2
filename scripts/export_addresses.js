const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityToken = artifacts.require("IdentityToken");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");

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
    SandboxIdentityProvider: SandboxIdentityProvider.address,

    AccreditedUSCS: AccreditedUSCS.address,
    AccreditedUSToken: AccreditedUSToken.address,
    OutsideUSCS: OutsideUSCS.address,
    OutsideUSToken: OutsideUSToken.address,
    WhitelistCS: WhitelistCS.address,
    WhitelistToken: WhitelistToken.address
  };

  console.log(JSON.stringify(addresses));
};

module.exports = cb => {
  main()
    .then(res => cb(null, res))
    .catch(err => cb(err));
};
