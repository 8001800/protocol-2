const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const BooleanIdentityProvider = artifacts.require("BooleanIdentityProvider");
const BooleanIdentityComplianceStandard = artifacts.require(
  "BooleanIdentityComplianceStandard"
);

module.exports = async deployer => {
  const identityProvider = await deployer.deploy(
    BooleanIdentityProvider,
    IdentityCoordinator.address,
    0
  );
  await identityProvider.registerProvider("Boolean", "");
  const providerId = await identityProvider.providerId();
  console.log("Identity provider id:", providerId.toString());

  const cs = await deployer.deploy(
    BooleanIdentityComplianceStandard,
    IdentityCoordinator.address,
    providerId
  );
  const csId = await cs.providerId();
  console.log("CS provider id:", csId.toString());
};
