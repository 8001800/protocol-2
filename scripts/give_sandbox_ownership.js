const IdentityToken = artifacts.require("IdentityToken");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");

const NEW_OWNER = "0xe107f91ef6b35436cd4a61eb76c74206db444e82";

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
