const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const SandboxComplianceProvider = artifacts.require(
  "SandboxComplianceProvider"
);

const main = async () => {
  const ip = await SandboxIdentityProvider.deployed();
  const cp = await SandboxComplianceProvider.deployed();
  console.log("ip id:", (await ip.providerId()).toString());
  console.log("cp id:", (await cp.providerId()).toString());
};

module.exports = cb => {
  main()
    .then(res => cb(null, res))
    .catch(err => cb(err));
};
