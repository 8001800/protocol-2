const chai = require("chai").use(require("chai-as-promised"));
const assert = chai.assert;

const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
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
  let provider = null;

  beforeEach(async () => {
    provider = await SandboxIdentityProvider.new(
      providerRegistry.address,
      identityToken.address,
      0
    );

    //Register provider
    const regReciept = await provider.registerProvider("Sandbox", "", true);
  });

  before(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    annoDb = await AnnotationDatabase.deployed();
    identityToken = await IdentityToken.deployed();
  });

  it("should write bytes field", async () => {
    const id = await provider.providerId();
    const version = await providerRegistry.latestProviderVersion(id);
    const ownerAdd = await providerRegistry.providerOwner(id);
    assert.equal(provider.address, ownerAdd);

    //Request parameters
    const params = {
      providerId: id,
      providerVersion: version,
      cost: 100 * ethInWei,
      requestId: "12345678",
      fieldId: "5678",
      value: "0xdeadbeef",
      expiry: 10,
      owner: ownerAdd,
      requester: accounts[3]
    };

    //Write final attestation
    result = await provider.writeIdentityBytesFieldForService(
      params.requester,
      params.fieldId,
      params.value
    );

    data = await annoDb.bytesData(
      identityToken.address,
      await identityToken.tokenOf(params.requester),
      await provider.providerId(),
      params.fieldId
    );

    assert.equal(data[1], params.value);
  });
});
