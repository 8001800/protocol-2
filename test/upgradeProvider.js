const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const DelegateCS = artifacts.require("DelegateCS");
const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");

contract("Upgrade Providers", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
  });

  it("Register and upgrade compliance standard", async () => {
    const standard = await DelegateCS.new(
      providerRegistry.address,
      0,
      0,
      complianceCoordinator.address
    );

    const name = "Whitelist";
    var metaData = "old";

    const regReceipt = await standard.registerProvider(name, metaData, false);
    const id = await standard.providerId();
    const owner = await providerRegistry.providerOwner(id);

    const standardProviderInfo = await providerRegistry.latestProvider(id);
    assert.equal(standardProviderInfo[0].toNumber(), id.toNumber());
    assert.equal(standardProviderInfo[1], name);
    assert.equal(standardProviderInfo[2], metaData);
    assert.equal(standardProviderInfo[3], owner);
    assert.equal(standardProviderInfo[4].toNumber(), 1);

    const newStandard = await DelegateCS.new(
      providerRegistry.address,
      id,
      id,
      complianceCoordinator.address
    );

    metaData = "new";
    const upgradeReciept = await standard.performUpgrade(
      metaData,
      standard.address,
      false
    );
    const newId = await newStandard.providerId();
    const newOwner = await providerRegistry.providerOwner(newId);

    const newProviderInfo = await providerRegistry.latestProvider(newId);
    assert.equal(newProviderInfo[0].toNumber(), newId.toNumber());
    assert.equal(newProviderInfo[1], name);
    assert.equal(newProviderInfo[2], metaData);
    assert.equal(newProviderInfo[3], newOwner);
    assert.equal(newProviderInfo[4].toNumber(), 2);
  });
});
