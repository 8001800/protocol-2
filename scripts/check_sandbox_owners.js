const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");

const ADMINS = [
  "0xb55af10efbb5fa1b75f55451922779633567f4fc",
  "0x2f0f76691c32ed8ce47500211372fbd61e9b59fe",
  "0x51e4fa3d1f84a7da2c0f24736c746b965ff7b0cb"
];

const main = async () => {
  const ip = await SandboxIdentityProvider.deployed();
  for (var i = 0; i < ADMINS.length; i++) {
    console.log(await ip.hasRole(ADMINS[i], "admin"));
  }
};

module.exports = cb => {
  main()
    .then(res => cb(null, res))
    .catch(err => cb(err));
};
