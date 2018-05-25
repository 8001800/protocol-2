const chai = require("chai").use(require("chai-as-promised"));
const assert = chai.assert;

const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const Bundle = artifacts.require("Bundle");
const BigNumber = require("bignumber.js");

contract("Bundle", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let bundle = null;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    bundle = await Bundle.deployed();
  });

  it("should create bundle", async () => {
    const params = {
      uri: "Asuna",
      complianceProviderId: 0
    };

    // Create Bundle
    const { logs } = await bundle.create( params.uri, params.complianceProviderId);

    assert.equal(logs.length, 2);
    assert.equal(logs[1].event, "Create");
    assert.equal(logs[1].args.bundleId.toNumber(), 1);
  });

});
