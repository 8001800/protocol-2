const chai = require("chai").use(require("chai-as-promised"));
const assert = chai.assert;

const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const AnnotationDatabase = artifacts.require("AnnotationDatabase");
const IdentityToken = artifacts.require("IdentityToken");
const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");
const ethInWei = 1000000000000000000;

contract("IdentityProvider", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let annoDb = null;
  let identityToken = null;
  let aba = null;
  let kernel = null;
  let identityProvId = null;
  let identityProvVersion = null;

  before(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    aba = await AbacusToken.deployed();
    kernel = await AbacusKernel.deployed();
    annoDb = await AnnotationDatabase.deployed();
    identityToken = await IdentityToken.deployed();

    //Distribute tokens
    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1));
    await aba.transfer(accounts[3], 10000*ethInWei);
    await aba.approve(
      kernel.address, 
      new BigNumber(2).pow(256).minus(1),
      {
        from: accounts[3]
      }
    );
    await aba.transfer(accounts[9], await aba.balanceOf(accounts[0]));

    //Register provider
    const {logs: regReciept} = await providerRegistry.registerProvider(
      "manual", 
      "", 
      accounts[0],
      true
    )

    identityProvId = regReciept[0].args.id;
    identityProvVersion = regReciept[0].args.version;
  });

  it("should update the identity if request exists", async () => {
    const version = await providerRegistry.latestProviderVersion(identityProvId);
    const owner = await providerRegistry.providerOwner(identityProvId);
    assert.equal(version.toNumber(), identityProvVersion.toNumber());
    assert.equal(owner, accounts[0]);

    const params = {
      providerId: identityProvId,
      providerVersion: version,
      providerOwner: owner,
      requestId: 201011,
      fieldId: 16,
      cost: 100*ethInWei,
      expiry: 100,
      requester: accounts[3]
    };

    // Make a request
    const { logs: requestServiceLogs } = await kernel.requestAsyncService(
      params.providerId,
      params.cost,
      params.requestId,
      params.expiry,
      {
        from: params.requester
      }
    );
    
    assert.equal(requestServiceLogs.length, 1);
    assert.equal(requestServiceLogs[0].event, "ServiceRequested");
    assert.equal(requestServiceLogs[0].args.providerId.toNumber(), params.providerId);
    assert.equal(requestServiceLogs[0].args.providerVersion.toNumber(), params.providerVersion);
    assert.equal(requestServiceLogs[0].args.requester, params.requester);
    assert.equal(requestServiceLogs[0].args.cost.toNumber(), params.cost);
    assert.equal(requestServiceLogs[0].args.requestId.toNumber(), params.requestId);
    
    const escrowed = await aba.balanceOf(kernel.address);
    assert.equal(escrowed, params.cost);

    const escrowId = requestServiceLogs[0].args.escrowId;
    var escrow = await kernel.escrows(escrowId);
    assert.equal(escrow[0].toNumber(), 0);
    assert.equal(escrow[1], params.requester);
    assert.equal(escrow[2], params.providerOwner);
    assert.equal(escrow[3].toNumber(), params.cost);
    assert.equal(escrow[4].toNumber(), params.expiry);
    assert.equal(escrow[5].toNumber(), 0);
    
    // Manual identity provider accept service through kernel
    const { logs: acceptServiceLogs } = await kernel.acceptAsyncServiceRequest(
      params.providerId,
      params.requester,
      params.requestId
    );

    assert.equal(acceptServiceLogs[0].event, "ServiceRequestAccepted");
    assert.equal(acceptServiceLogs[0].args.providerId.toNumber(), params.providerId);
    assert.equal(acceptServiceLogs[0].args.requester, params.requester);
    assert.equal(acceptServiceLogs[0].args.requestId.toNumber(), params.requestId);

    escrow = await kernel.escrows(escrowId);
    assert.equal(escrow[0], 1);
    assert.equal(escrow[5], acceptServiceLogs[0].blockNumber);
    
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

    // Signal service was completed via the Abacus Kernel
    const { logs: completeServiceLogs } = await kernel.onAsyncServiceCompleted(
      params.providerId,
      params.requester,
      params.requestId
    );

    assert.equal(completeServiceLogs[0].event, "ServicePerformed");
    assert.equal(completeServiceLogs[0].args.providerId.toNumber(), params.providerId);
    assert.equal(completeServiceLogs[0].args.requester, params.requester);
    assert.equal(completeServiceLogs[0].args.requestId.toNumber(), params.requestId);

    escrow = await kernel.escrows(escrowId);
    assert.equal(escrow[0], 2);

    // Check if identity provider recieved payment
    const balance = await aba.balanceOf(params.providerOwner);
    assert.equal(balance.toNumber(), params.cost);
  });
});
