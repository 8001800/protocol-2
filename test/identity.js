const chai = require("chai").use(require("chai-as-promised"));
const assert = chai.assert;

const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const SampleCompliantToken = artifacts.require("SampleCompliantToken");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const IdentityToken = artifacts.require("IdentityToken");
const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");

contract("IdentityCoordinator", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let annoDb = null;
  let identityToken = null;
  let aba = null;
  let kernel = null;
  let identityProvider = null;
  let nextId = 100;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    aba = await AbacusToken.deployed();
    kernel = await AbacusKernel.deployed();
    annoDb = await AnnotationDatabase.deployed();
    identityToken = await IdentityToken.deployed();

    identityProvider = await SandboxIdentityProvider.deployed();

    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1));
  });

  it("should update the identity if request exists", async () => {
    const params = {
      providerId: await identityProvider.providerId(),
      requestId: 201011,
      fieldId: 16,
      cost: 0
    };

    // Make a request
    const { logs: requestCheckLogs } = await kernel.requestService(
      params.providerId,
      params.cost,
      params.requestId
    );
    assert.equal(requestCheckLogs.length, 1);
    assert.equal(requestCheckLogs[0].event, "ServiceRequested");

    // Write data
    const { logs: writeLogs } = await identityProvider.writeBytes32Field(
      accounts[0],
      params.requestId,
      params.fieldId,
      "0x1"
    );

    const data = await annoDb.bytes32Data(
      identityToken.address,
      await identityToken.tokenOf(accounts[0]),
      params.providerId,
      params.fieldId
    );

    assert(data[1].includes("1"), "Data should exist in identity provider");
  });

  it("should not update the identity if no request", async () => {
    const params = {
      providerId: await identityProvider.providerId(),
      requestId: 201005,
      fieldId: 11,
      cost: 0
    };

    await assert.isRejected(
      identityProvider.writeBytes32Field(
        accounts[0],
        params.requestId,
        11,
        "0x1"
      )
    );
  });
});
