const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");

const newOwner = "0x7378668ce54914b2df322fba26003cd48bdf95da";

const main = async () => {
  const sip = await SandboxIdentityProvider.deployed();
  await sip.transferOwnership(newOwner);
  console.log("Ownership transferred.");
};

module.exports = cb => {
  main()
    .then(res => cb(null, res))
    .catch(err => cb(err));
};
