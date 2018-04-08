const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const IdentityDatabase = artifacts.require("IdentityDatabase");
const SampleCompliantToken = artifacts.require("SampleCompliantToken");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const BooleanIdentityProvider = artifacts.require("BooleanIdentityProvider");
const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const ethInWei = 1000000000000000000;

contract("Sandbox", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let identityCoordinator = null;
  let identityDatabase = null;
  let aba = null;
  let kernel = null;
  let provider = null;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    identityCoordinator = await IdentityCoordinator.deployed();
    identityDatabase = await IdentityDatabase.deployed();
    aba = await AbacusToken.deployed();
    kernel = await AbacusKernel.deployed();
    provider = await SandboxIdentityProvider.deployed();

    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1));
    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1), {
      from: accounts[3]
    });
  });

  it("should write bytes field", async () => {
    const requestId = "12345678";
    const fieldId = "1234";
    const value = "0xdeadbeef";

    await identityCoordinator.requestVerification(3, 0, requestId, 10, {
      from: accounts[0]
    });

    const result = await provider.writeBytesField(
      accounts[0],
      requestId,
      fieldId,
      value
    );

    const data = await identityDatabase.bytesData(
      await provider.providerId(),
      accounts[0],
      fieldId
    );
    assert.equal(data, value);
  });
});
