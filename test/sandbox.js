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
    annoDb = await AnnotationDatabase.deployed();
    identityToken = await IdentityToken.deployed();
    
    provider = await SandboxIdentityProvider.new(
      kernel.address,
      aba.address,
      identityToken.address,
      0
    );

    //Register provider
    const regReciept = await provider.registerProvider("Sandbox", "", true); 
  });

  it("distribute ABA tokens", async () => {
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
      cost: 100*ethInWei,
      requestId: "12345678",
      fieldId:"1234",
      value: "0xdeadbeef",
      expiry: 10,
      owner: ownerAdd,
      requester: accounts[3]
    }

    const requestService = await kernel.requestAsyncService(
      params.providerId,
      params.cost,
      params.requestId,
      params.expiry,
      {
        from: params.requester
      }
    );

    assert.equal(requestService.logs[0].event, "ServiceRequested");
    assert.equal(requestService.logs[0].args.providerId.toNumber(), params.providerId);
    assert.equal(requestService.logs[0].args.providerVersion.toNumber(), params.providerVersion);
    assert.equal(requestService.logs[0].args.requester, params.requester);
    assert.equal(requestService.logs[0].args.cost.toNumber(), params.cost);
    assert.equal(requestService.logs[0].args.requestId.toNumber(), params.requestId); 

    const escrowId = requestService.logs[0].args.escrowId;
    const escrowed = await aba.balanceOf(kernel.address);
    assert.equal(escrowed, params.cost);

    var escrow = await kernel.escrows(escrowId);
    assert.equal(escrow[0].toNumber(), 0);
    assert.equal(escrow[1], params.requester);
    assert.equal(escrow[2], params.owner);
    assert.equal(escrow[3].toNumber(), params.cost);
    assert.equal(escrow[4].toNumber(), params.expiry);
    assert.equal(escrow[5].toNumber(), 0);

    const acceptService = await provider.acceptServiceRequest(
      params.requester,
      params.requestId
    );
    
    const acceptServiceEvents = await promisify(cb => 
      kernel
        .ServiceRequestAccepted({}, {fromBlock: acceptService.receipt.blockNumber, toBlock: "latest"})
        .get(cb)
    )();

    assert.equal(acceptServiceEvents[0].event, "ServiceRequestAccepted");
    assert.equal(acceptServiceEvents[0].args.providerId.toNumber(), params.providerId);
    assert.equal(acceptServiceEvents[0].args.requester, params.requester);
    assert.equal(acceptServiceEvents[0].args.requestId.toNumber(), params.requestId);

    escrow = await kernel.escrows(escrowId);
    assert.equal(escrow[0], 1);
    assert.equal(escrow[5], acceptService.receipt.blockNumber);

    const result = await provider.writeBytesFieldForService(
      params.requester,
      params.requestId,
      params.fieldId,
      params.value
    );

    const performServiceEvents = await promisify(cb => 
      kernel
        .ServicePerformed({}, {fromBlock: result.receipt.blockNumber, toBlock: "latest"})
        .get(cb)
    )();

    assert.equal(performServiceEvents[0].event, "ServicePerformed");
    assert.equal(performServiceEvents[0].args.providerId.toNumber(), params.providerId);
    assert.equal(performServiceEvents[0].args.requester, params.requester);
    assert.equal(performServiceEvents[0].args.requestId.toNumber(), params.requestId);

    escrow = await kernel.escrows(escrowId);
    assert.equal(escrow[0].toNumber(), 2);

    const data = await annoDb.bytesData(
      identityToken.address,
      await identityToken.tokenOf(accounts[3]),
      await provider.providerId(),
      params.fieldId
    );

    assert.equal(data[1], params.value);

    const providerBalance = await aba.balanceOf(provider.address);
    assert.equal(providerBalance.toNumber(), params.cost);

    await provider.withdrawBalance(providerBalance);
    const walletBalance = await aba.balanceOf(accounts[0]);
    assert.equal(walletBalance.toNumber(), params.cost);
  });

  it("should not write bytes field if request not accepted, let escrow expire", async () => {
    const id = await provider.providerId();
    const version = await providerRegistry.latestProviderVersion(id);
    const ownerAdd = await providerRegistry.providerOwner(id);
    assert.equal(provider.address, ownerAdd);

    //Request parameters
    const params = {
      providerId: id,
      providerVersion: version, 
      cost: 1*ethInWei,
      requestId: "901234567",
      fieldId:"5678",
      value: "0xbeefbeef",
      expiry: 10,
      owner: ownerAdd,
      requester: accounts[3]
    }

    const requestService = await kernel.requestAsyncService(
      params.providerId,
      params.cost,
      params.requestId,
      params.expiry,
      {
        from: params.requester
      }
    );
    
    assert.equal(requestService.logs[0].event, "ServiceRequested");
    assert.equal(requestService.logs[0].args.providerId.toNumber(), params.providerId);
    assert.equal(requestService.logs[0].args.providerVersion.toNumber(), params.providerVersion);
    assert.equal(requestService.logs[0].args.requester, params.requester);
    assert.equal(requestService.logs[0].args.cost.toNumber(), params.cost);
    assert.equal(requestService.logs[0].args.requestId.toNumber(), params.requestId); 

    const escrowId = requestService.logs[0].args.escrowId;
    const escrowed = await aba.balanceOf(kernel.address);
    assert.equal(escrowed, params.cost);

    var escrow = await kernel.escrows(escrowId);
    assert.equal(escrow[0].toNumber(), 0);
    assert.equal(escrow[1], params.requester);
    assert.equal(escrow[2], params.owner);
    assert.equal(escrow[3].toNumber(), params.cost);
    assert.equal(escrow[4].toNumber(), params.expiry);
    assert.equal(escrow[5].toNumber(), 0);
    
    await assert.isRejected(
      provider.writeBytesFieldForService(
        params.requester,
        params.requestId,
        params.fieldId,
        params.value
      )
    )

    //passblocks
    var count = 0;
    while(count <= params.expiry) {
      await web3.eth.sendTransaction(
        {
          value: 1,
          from: accounts[0],
          to: accounts[1]
        }
      );
      count++;
    }

    const revokeRequest = await kernel.revokeAsyncServiceRequest(
      params.requestId,
      { from : params.requester }
    );

    const revokeRequestEvents = await promisify(cb => 
      kernel
        .ServiceRequestRevokedByCancel({}, {fromBlock: 0, toBlock: "latest"})
        .get(cb)
    )();

    assert.equal(revokeRequestEvents[0].event, "ServiceRequestRevokedByCancel");
    assert.equal(revokeRequestEvents[0].args.requestId.toNumber(), params.requestId);

    const revokeTransferEvents = await promisify(cb => 
      aba
        .Transfer({}, {fromBlock: revokeRequest.receipt.blockNumber, toBlock: "latest"})
        .get(cb)
    )();

    assert.equal(revokeTransferEvents[0].args.from, kernel.address);
    assert.equal(revokeTransferEvents[0].args.to, params.requester);
    assert.equal(revokeTransferEvents[0].args.value, params.cost);

    escrow = await kernel.escrows(escrowId);
    assert.equal(escrow[0].toNumber(), 3);
  })

  it("operational failure, cancel payment in escrow ", async () => {
    const id = await provider.providerId();
    const version = await providerRegistry.latestProviderVersion(id);
    const ownerAdd = await providerRegistry.providerOwner(id);
    assert.equal(provider.address, ownerAdd);

    //Request parameters
    const params = {
      providerId: id,
      providerVersion: version, 
      cost: 5*ethInWei,
      requestId: "01234567",
      fieldId:"9012",
      value: "0xmeatbeef",
      expiry: 5,
      owner: ownerAdd,
      requester: accounts[3]
    }

    const requestService = await kernel.requestAsyncService(
      params.providerId,
      params.cost,
      params.requestId,
      params.expiry,
      {
        from: params.requester
      }
    );
    
    assert.equal(requestService.logs[0].event, "ServiceRequested");
    assert.equal(requestService.logs[0].args.providerId.toNumber(), params.providerId);
    assert.equal(requestService.logs[0].args.providerVersion.toNumber(), params.providerVersion);
    assert.equal(requestService.logs[0].args.requester, params.requester);
    assert.equal(requestService.logs[0].args.cost.toNumber(), params.cost);
    assert.equal(requestService.logs[0].args.requestId.toNumber(), params.requestId); 

    const escrowId = requestService.logs[0].args.escrowId;
    const escrowed = await aba.balanceOf(kernel.address);
    assert.equal(escrowed, params.cost);

    var escrow = await kernel.escrows(escrowId);
    assert.equal(escrow[0].toNumber(), 0);
    assert.equal(escrow[1], params.requester);
    assert.equal(escrow[2], params.owner);
    assert.equal(escrow[3].toNumber(), params.cost);
    assert.equal(escrow[4].toNumber(), params.expiry);
    assert.equal(escrow[5].toNumber(), 0);

    const acceptService = await provider.acceptServiceRequest(
      params.requester,
      params.requestId
    );

    const acceptServiceEvents = await promisify(cb => 
      kernel
        .ServiceRequestAccepted({}, {fromBlock: acceptService.receipt.blockNumber, toBlock: "latest"})
        .get(cb)
    )();

    assert.equal(acceptServiceEvents[0].event, "ServiceRequestAccepted");
    assert.equal(acceptServiceEvents[0].args.providerId.toNumber(), params.providerId);
    assert.equal(acceptServiceEvents[0].args.requester, params.requester);
    assert.equal(acceptServiceEvents[0].args.requestId.toNumber(), params.requestId);

    escrow = await kernel.escrows(escrowId);
    assert.equal(escrow[0], 1);
    assert.equal(escrow[5], acceptService.receipt.blockNumber);
  
    //passblocks
    var count = 0;
    while(count <= params.expiry) {
      await web3.eth.sendTransaction(
        {
          value: 1,
          from: accounts[0],
          to: accounts[1]
        }
      );
      count++;
    }
    
    const revokeRequest = await kernel.revokeAsyncServiceRequest(
      params.requestId,
      { from : params.requester }
    );
    
    const revokeRequestEvents = await promisify(cb => 
      kernel
        .ServiceRequestRevokedByExpiry({}, {fromBlock: 0, toBlock: "latest"})
        .get(cb)
    )();

    assert.equal(revokeRequestEvents[0].event, "ServiceRequestRevokedByExpiry");
    assert.equal(revokeRequestEvents[0].args.requestId.toNumber(), params.requestId);

    const revokeTransferEvents = await promisify(cb => 
      aba
        .Transfer({}, {fromBlock: revokeRequest.receipt.blockNumber, toBlock: "latest"})
        .get(cb)
    )();

    assert.equal(revokeTransferEvents[0].args.from, kernel.address);
    assert.equal(revokeTransferEvents[0].args.to, params.requester);
    assert.equal(revokeTransferEvents[0].args.value, params.cost);

    escrow = await kernel.escrows(escrowId);
    assert.equal(escrow[0].toNumber(), 4);
  })

  it("should reject duplicate requestId ", async () => {
    const id = await provider.providerId();
    const version = await providerRegistry.latestProviderVersion(id);
    const ownerAdd = await providerRegistry.providerOwner(id);
    assert.equal(provider.address, ownerAdd);

    //Request parameters
    const params = {
      providerId: id,
      providerVersion: version, 
      cost: 256*ethInWei,
      requestId: "12345678",
      fieldId:"8765",
      value: "0xyourbeef",
      expiry: 213,
      owner: ownerAdd,
      requester: accounts[3]
    }

    await assert.isRejected(
      kernel.requestAsyncService(
        params.providerId,
        params.cost,
        params.requestId,
        params.expiry,
        { from: params.requester}
      )
    )
  })
});
