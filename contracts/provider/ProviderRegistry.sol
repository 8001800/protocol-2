pragma solidity ^0.4.19;

/**
 * @title ProviderRegistry
 * @dev Registry for providers of some service, e.g. identity or compliance.
 * 
 * The registry contains functions for self-amendment (i.e. version upgrades)
 * and a mechanism to gauge trust of individual providers.
 */
contract ProviderRegistry {
    /**
     * @dev Event emitted whenever a provider is added or changed.
     *
     * @param id See ProviderInfo docs.
     * @param name See ProviderInfo docs.
     * @param metadata See ProviderInfo docs.
     * @param owner See ProviderInfo docs.
     * @param version See ProviderInfo docs.
     */
    event ProviderInfoUpdate(
        uint256 id,
        string name,
        string metadata,
        address owner,
        uint256 version
    );

    /**
     * @dev Represents a provider of some sort of service.
     */
    struct ProviderInfo {
        /**
         * @dev The unique id of the provider.
         */
        uint256 id;
        /**
         * @dev The name of the provider. Immutable.
         */
        string name;
        /**
         * @dev Any metadata needed for the provider. Commonly an IPFS hash.
         */
        string metadata;
        /**
         * @dev The owner of the provider. Can be a smart contract.
         */
        address owner;
        /**
         * @dev The latest version of the provider.
         */
        uint256 version;
    }

    /**
     * @dev Stores a mapping of provider id => provider version => provider info.
     */
    mapping (uint256 => mapping (uint256 => ProviderInfo)) public providers;

    /**
     * @dev The latest version of a provider.
     */
    mapping (uint256 => uint256) public latestProviderVersion;

    /**
     * @dev The id of next provider registered. This ensures that provider ids are unique.
     */
    uint256 nextProviderId = 1;

    /**
     * @dev Registers a new provider.
     *
     * @param name See ProviderInfo docs.
     * @param metadata See ProviderInfo docs.
     * @param owner See ProviderInfo docs.
     */
    function registerProvider(
        string name,
        string metadata,
        address owner
    ) external returns (uint256)
    {
        uint256 providerId = nextProviderId++;
        providers[providerId][1] = ProviderInfo({
            id: providerId,
            name: name,
            metadata: metadata,
            owner: owner,
            version: 1
        });
        latestProviderVersion[providerId] = 1;
        ProviderInfoUpdate({
            id: providerId,
            name: name,
            metadata: metadata,
            owner: owner,
            version: 1
        });
        return providerId;
    }

    function getLatestProvider(
        uint256 providerId
    ) view private returns (ProviderInfo storage)
    {
        return providers[providerId][latestProviderVersion[providerId]];
    }

    function latestProvider(
        uint256 providerId
    ) view external returns (uint256, string, string, address, uint256, bool)
    {
        ProviderInfo storage info = getLatestProvider(providerId);
        return (
            info.id,
            info.name,
            info.metadata,
            info.owner,
            info.version,
            bytes(info.metadata).length > 0
        );
    }

    /**
     * @dev Upgrades a provider, changing its metadata and owner.
     *
     * @param providerId See ProviderInfo docs.
     * @param metadata See ProviderInfo docs.
     * @param owner See ProviderInfo docs.
     */
    function upgradeProvider(
        uint256 providerId,
        string metadata,
        address owner
    ) external returns (bool)
    {
        ProviderInfo storage info = getLatestProvider(providerId);
        // Check if the provider existed
        if (info.version == 1) {
            return false;
        }

        // Check if the provider is authorized to be upgraded by sender
        if (msg.sender != info.owner) {
            return false;
        }
        uint256 nextVersion = info.version + 1;

        providers[providerId][nextVersion] = ProviderInfo({
            id: providerId,
            name: info.name,
            metadata: metadata,
            owner: owner,
            version: nextVersion
        });
        latestProviderVersion[providerId] = nextVersion;
        ProviderInfoUpdate({
            id: providerId,
            name: info.name,
            metadata: metadata,
            owner: owner,
            version: nextVersion
        });
        return true;
    }

    /**
     * @dev Returns the owner of a provider.
     *
     * @param providerId The id of the provider to look up.
     */
    function providerOwner(uint256 providerId) view external returns (address) {
        return getLatestProvider(providerId).owner;
    }

}