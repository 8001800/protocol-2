const chai = require("chai").use(require("chai-as-promised"));
const assert = chai.assert;

const ProviderRegistry = artifacts.require("ProviderRegistry");
const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const IdentityProvider = artifacts.require("IdentityProvider");
const IdentityToken = artifacts.require("IdentityToken");
const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");
const ethInWei = 1000000000000000000;

contract("IdentityProvider", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let annoDb = null;
  let identityToken = null;
  let identityProvId = null;
  let identityProvVersion = null;

  let identityProvider = null;

  before(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    annoDb = await AnnotationDatabase.deployed();
    identityToken = await IdentityToken.deployed();

    //Register provider
    const { logs: regReciept } = await providerRegistry.registerProvider(
      "manual",
      "",
      accounts[0],
      true
    );

    identityProvId = regReciept[0].args.id;
    identityProvVersion = regReciept[0].args.version;
  });

  it("should update the identity if request exists", async () => {
    const version = await providerRegistry.latestProviderVersion(
      identityProvId
    );
    const owner = await providerRegistry.providerOwner(identityProvId);
    assert.equal(version.toNumber(), identityProvVersion.toNumber());
    assert.equal(owner, accounts[0]);

    const params = {
      providerId: identityProvId,
      providerVersion: version,
      providerOwner: owner,
      requestId: 201011,
      fieldId: 16,
      cost: 100 * ethInWei,
      expiry: 100,
      requester: accounts[3]
    };

    // Write data
    const { logs: writeLogs } = await annoDb.writeBytes32Field(
      identityToken.address,
      await identityToken.tokenOf(params.requester),
      params.providerId,
      params.fieldId,
      "0x1"
    );

    const data = await annoDb.bytes32Data(
      identityToken.address,
      await identityToken.tokenOf(params.requester),
      params.providerId,
      params.fieldId
    );

    assert(data[1].includes("1"), "Data should exist in identity provider");
  });

  it("should write attestations after update", async () => {
    // Create new identity provider with old ID
    identityProvider = await IdentityProvider.new(
      providerRegistry.address,
      identityToken.address,
      identityProvId
    );

    // Upgrade old provider in registry
    const { logs: updateProviderLogs } = await providerRegistry.upgradeProvider(
      identityProvId,
      "www.updatedProvider.com",
      identityProvider.address,
      true
    );

    assert.equal(updateProviderLogs[0].event, "ProviderInfoUpdate");
    assert.equal(updateProviderLogs[0].args.name, "manual");
    assert.equal(
      updateProviderLogs[0].args.version.toNumber(),
      identityProvVersion.toNumber() + 1
    );

    const id = await identityProvider.providerId();
    const version = await providerRegistry.latestProviderVersion(id);
    const owner = await providerRegistry.providerOwner(id);
    assert.equal(identityProvider.address, owner);
    assert.equal(version, updateProviderLogs[0].args.version.toNumber());

    //Request parameters
    const params = {
      providerId: id,
      providerVersion: version,
      providerOwner: owner,
      cost: 100 * ethInWei,
      requestId: "12345678",
      fieldId: "5678",
      value: "0xdeadbeef",
      expiry: 10,
      requester: accounts[3]
    };

    //Write attestation
    var result = await identityProvider.writeIdentityBytes32Field(
      params.requester,
      1234,
      "0x0f00000000000000000000000000000000000000000000000000000000000000"
    );

    var data = await identityToken.readBytes32Data(
      params.requester,
      params.providerId,
      1234
    );
    assert.equal(
      data[1],
      "0x0f00000000000000000000000000000000000000000000000000000000000000"
    );
  });
});
