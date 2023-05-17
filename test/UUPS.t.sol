// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

//interfaces

//libraries
import {console} from "forge-std/console.sol";

//contracts
import {TestUtils} from "./utils/TestUtils.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../src/UUPS.sol";

contract UUPSTest is TestUtils {
    OurUpgradeableNFT1 public oldContract;
    OurUpgradeableNFT2 public upgradedContract;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function setUp() external {
        address nftImplementation = address(new OurUpgradeableNFT1());

        address nftAddress = _deployERC1967Proxy(
            nftImplementation,
            abi.encodeCall(
                OurUpgradeableNFT1(nftImplementation).initialize,
                ("hello world")
            )
        );

        oldContract = OurUpgradeableNFT1(nftAddress);
    }

    function test_greeting() external {
        assertEq(oldContract.greeting(), "hello world");
    }

    function _initUpgrade() internal {
        address nftImplementation = address(new OurUpgradeableNFT2());

        UUPSUpgradeable(address(oldContract)).upgradeToAndCall(
            nftImplementation,
            abi.encodeCall(
                OurUpgradeableNFT2(nftImplementation).reInitialize,
                ()
            )
        );

        upgradedContract = OurUpgradeableNFT2(address(oldContract));
    }

    function test_upgrade() external {
        _initUpgrade();

        assertEq(upgradedContract.greeting(), "hello world");
        assertEq(upgradedContract.greetingNew(), "New Upgradeable World!");
        assertEq(upgradedContract.name(), "OurUpgradeableNFT2");
    }

    function test_mint() external {
        _initUpgrade();

        address receiver = _randomAddress();

        vm.expectEmit(true, true, true, false, address(upgradedContract));
        emit Transfer(address(0), receiver, 0);

        upgradedContract.safeMint(receiver, "test");

        assertEq(upgradedContract.balanceOf(receiver), 1);
        assertEq(upgradedContract.tokenURI(0), "test");
        assertEq(upgradedContract.ownerOf(0), receiver);
    }

    function test_revertMintNotOwner() external {
        _initUpgrade();

        address receiver = _randomAddress();

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(receiver);
        upgradedContract.safeMint(receiver, "test");
    }

    // --------------------------
    // Internal
    // --------------------------

    function _deployERC1967Proxy(
        address implementation,
        bytes memory data
    ) public returns (address) {
        ERC1967Proxy proxy = new ERC1967Proxy(implementation, data);
        address proxyAddress = address(proxy);
        vm.label(proxyAddress, "ERC1967 Proxy");
        return proxyAddress;
    }
}
