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
     * @dev Stores a mapping of provider id to the latest provider info.
     */
    mapping (uint256 => ProviderInfo) providers;

    /**
     * @dev The id of next provider registered. This ensures that provider ids are unique.
     */
    uint256 nextProviderId = 0;

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
    ) external
    {
        uint256 providerId = nextProviderId++;
        providers[providerId] = ProviderInfo({
            id: providerId,
            name: name,
            metadata: metadata,
            owner: owner,
            version: 1
        });
        ProviderInfoUpdate({
            id: providerId,
            name: name,
            metadata: metadata,
            owner: owner,
            version: 1
        });
    }

    /**
     * @dev Upgrades a provider, changing its metadata and owner.
     *
     * @param metadata See ProviderInfo docs.
     * @param owner See ProviderInfo docs.
     */
    function upgradeProvider(
        string metadata,
        address owner
    ) external returns (bool)
    {
        uint256 providerId = nextProviderId++;
        ProviderInfo storage info = providers[providerId];
        // Check if the provider existed
        if (info.version == 1) {
            return false;
        }

        // Check if the provider is authorized to be upgraded by sender
        if (msg.sender != info.owner) {
            return false;
        }
        uint256 nextVersion = info.version + 1;

        // Check if we're allowed.
        providers[providerId] = ProviderInfo({
            id: providerId,
            name: info.name,
            metadata: metadata,
            owner: owner,
            version: nextVersion
        });
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
     * @dev Adjacency matrix, where address is the constituent (one who trusts),
     * uint256 is the trustee (provider id of one who is trusted), and the last
     * uint256 is the version of the provider trusted.
     * A zero version represents lack of trust.
     */
    mapping (address => mapping(uint256 => uint256)) public trustMatrix;

    /**
     * @dev Writes that msg.sender trusts a provider.
     *
     * @param providerId The id of the provider to trust.
     */
    function trustProvider(uint256 providerId) external {
        trustMatrix[msg.sender][providerId] = providers[providerId].version;
    }

    /**
     * @dev Untrusts a provider.
     *
     * @param providerId The id of the provider to untrust.
     */
    function untrustProvider(uint256 providerId) external {
        trustMatrix[msg.sender][providerId] = 0;
    }

    /**
     * @dev Returns the owner of a provider.
     *
     * @param providerId The id of the provider to look up.
     */
    function providerOwner(uint256 providerId) view external returns (address) {
        return providers[providerId].owner;
    }

}