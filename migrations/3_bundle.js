const Bundle = artifacts.require("Bundle");

module.exports = async deployer => {
  await deployer.deploy(Bundle);
};
