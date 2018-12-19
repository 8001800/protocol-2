const chai = require("chai").use(require("chai-as-promised"));
const assert = chai.assert;

const IdentityToken = artifacts.require("IdentityToken");
const IdentityProvider = artifacts.require("IdentityProvider");
const ProviderRegistry = artifacts.require("ProviderRegistry");
const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const { promisify } = require("es6-promisify");

contract("RBAC Identity Provider", accounts => {
  let identityProvider = null;
  let identityToken = null;
  let providerRegistry = null;
  let annoDB = null;

  before(async () => {
    identityToken = await IdentityToken.deployed();
    providerRegistry = await ProviderRegistry.deployed();
    annoDB = await AnnotationDatabase.deployed();

    //Create identity provider
    identityProvider = await IdentityProvider.new(
      providerRegistry.address,
      identityToken.address,
      0
    );

    //Register identity provider
    await identityProvider.registerProvider("rbac", "", true);

    assert.equal(
      await providerRegistry.providerOwner(await identityProvider.providerId()),
      identityProvider.address
    );
  });

  it("add role and write annotation", async () => {
    const { logs: addRoleLogs } = await identityProvider.addAdmin(accounts[9]);

    //Write identity annotation
    await identityProvider.writeIdentityBytes32Field(
      accounts[2],
      1234,
      "0xdeadbeef",
      { from: accounts[9] }
    );

    const annotation = await identityToken.readBytes32Data(
      accounts[2],
      await identityProvider.providerId(),
      1234
    );

    assert.equal(
      "0xdeadbeef00000000000000000000000000000000000000000000000000000000",
      annotation[1]
    );
  });

  it("remove role and revoke writing access", async () => {
    const { logs: removeRoleLogs } = await identityProvider.removeAdmin(
      accounts[9]
    );
    await assert.isRejected(
      identityProvider.writeIdentityBytes32Field(
        accounts[2],
        1234,
        "0xdeadbeef",
        { from: accounts[9] }
      )
    );
  });
});
