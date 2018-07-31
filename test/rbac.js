const chai = require("chai").use(require("chai-as-promised"));
const assert = chai.assert;

const IdentityToken = artifacts.require("IdentityToken");
const IdentityProvider = artifacts.require("IdentityProvider");
const ProviderRegistry = artifacts.require("ProviderRegistry");
const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const AbacusKernel = artifacts.require("AbacusKernel");
const { promisify } = require("es6-promisify");

contract("RBAC Identity Provider", accounts => {
  let identityProvider = null;
  let identityToken = null;
  let providerRegistry = null;
  let annoDB = null;
  let kernel = null;

  before(async () => {
    identityToken = await IdentityToken.deployed();
    providerRegistry = await ProviderRegistry.deployed();
    kernel = await AbacusKernel.deployed();
    annoDB = await AnnotationDatabase.deployed();

    //Create identity provider
    identityProvider = await IdentityProvider.new(
      identityToken.address,
      kernel.address,
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
    assert.equal(addRoleLogs[0].event, "RoleAdded");
    assert.equal(addRoleLogs[0].args.addr, accounts[9]);
    assert.equal(addRoleLogs[0].args.roleName, "admin");
    assert.equal(await identityProvider.hasRole(accounts[9], "admin"), true);

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
    assert.equal(removeRoleLogs[0].event, "RoleRemoved");
    assert.equal(removeRoleLogs[0].args.addr, accounts[9]);
    assert.equal(removeRoleLogs[0].args.roleName, "admin");

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