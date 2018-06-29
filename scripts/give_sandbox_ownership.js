const IdentityToken = artifacts.require("IdentityToken");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");

const NEW_OWNER = "0x8b932aa60c889e58d9b6174acb5d99c7af311366";

const main = async () => {
  const tok = await IdentityToken.deployed();
  console.log(await tok.annotationDatabase());

  const ip = await SandboxIdentityProvider.deployed();
  console.log(await ip.transferOwnership(NEW_OWNER));
};

module.exports = cb => {
  main()
    .then(res => cb(null, res))
    .catch(err => cb(err));
};
