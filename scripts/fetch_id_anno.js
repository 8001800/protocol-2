const IdentityToken = artifacts.require("IdentityToken");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");

const main = async () => {
  const tok = await IdentityToken.deployed();
  console.log(await tok.annotationDatabase());

  const ip = await SandboxIdentityProvider.deployed();
  console.log(await ip.writeBytes32Field(tok.address, 42, "0xdeadbeef"));
};

module.exports = cb => {
  main()
    .then(res => cb(null, res))
    .catch(err => cb(err));
};
