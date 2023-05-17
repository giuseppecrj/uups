// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

// interfaces

// libraries

// contracts
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {ERC721URIStorageUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {CountersUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract OurUpgradeableNFT1 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    string public greeting;

    function initialize(string calldata _greeting) public initializer {
        __UUPSUpgradeable_init();
        __Ownable_init();

        greeting = _greeting;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}

contract OurUpgradeableNFT2 is OurUpgradeableNFT1, ERC721URIStorageUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIds;

    function reInitialize() public reinitializer(2) {
        __ERC721_init("OurUpgradeableNFT2", "OUN");
        __ERC721URIStorage_init();
    }

    function greetingNew() public pure returns (string memory) {
        return "New Upgradeable World!";
    }

    function safeMint(address to, string memory uri) public virtual onlyOwner {
        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
