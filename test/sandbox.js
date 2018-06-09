const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const IdentityToken = artifacts.require("IdentityToken");
const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const ethInWei = 1000000000000000000;

contract("Sandbox", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let annoDb = null;
  let identityToken = null;
  let aba = null;
  let kernel = null;
  let provider = null;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    aba = await AbacusToken.deployed();
    kernel = await AbacusKernel.deployed();
    provider = await SandboxIdentityProvider.deployed();
    annoDb = await AnnotationDatabase.deployed();
    identityToken = await IdentityToken.deployed();

    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1));
  });

  it("should write bytes field", async () => {
    const id = await provider.providerId();

    const params = {
      providerId: id,
      cost: 0,
      requestId: "12345678",
      fieldId: "1234",
      value: "0xdeadbeef",
      expiry: 50
    }

    await kernel.requestAsyncService(
      params.providerId,
      params.cost,
      params.requestId,
      params.expiry,
      { from: accounts[3] }
    );

    const result = await provider.writeBytesField(
      accounts[3],
      params.fieldId,
      params.value
    );

    const data = await annoDb.bytesData(
      identityToken.address,
      await identityToken.tokenOf(accounts[3]),
      await provider.providerId(),
      params.fieldId
    );
    assert.equal(data[1], params.value);
  });
});
