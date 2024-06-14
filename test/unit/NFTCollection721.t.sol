// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/NFTCollection721.sol";

contract NFTCollection721Test is Test {
    NFTCollection721 public nftCollection721;
    address public owner = address(1);
    address public user = address(2);

    function setUp() public {
        nftCollection721 = new NFTCollection721();
        nftCollection721.initialize("Test Collection", "TC", "Test Description", 100, owner, 500);
        vm.prank(owner);
        nftCollection721.transferOwnership(owner);
    }

    function testInitialize() public {
        assertEq(nftCollection721.name(), "Test Collection");
        assertEq(nftCollection721.symbol(), "TC");
        assertEq(nftCollection721.description(), "Test Description");
        assertEq(nftCollection721.maxSupply(), 100);
    }

    function testMint() public {
        vm.prank(owner);
        nftCollection721.mint(user, 1, "ipfs://tokenURI1");

        assertEq(nftCollection721.totalMinted(), 1);
        assertEq(nftCollection721.tokenURI(1), "ipfs://tokenURI1");
        assertEq(nftCollection721.ownerOf(1), user);
    }

    function testMintExceedMaxSupply() public {
        vm.startPrank(owner);
        for (uint256 i = 0; i < 100; i++) {
            nftCollection721.mint(user, i, "ipfs://tokenURI");
        }
        vm.expectRevert("NFTCollection721: Exceeds max supply");
        nftCollection721.mint(user, 101, "ipfs://tokenURI101");
        vm.stopPrank();
    }

    function testSetTokenSalePrice() public {
        vm.prank(owner);
        nftCollection721.mint(user, 1, "ipfs://tokenURI1");

        vm.prank(owner);
        nftCollection721.setTokenSalePrice(1, 10 ether);

        assertEq(nftCollection721.tokenSalePrice(1), 10 ether);
    }

    function testSetTokenForSale() public {
        vm.prank(owner);
        nftCollection721.mint(user, 1, "ipfs://tokenURI1");

        vm.prank(owner);
        nftCollection721.setTokenForSale(1, true, block.timestamp, block.timestamp + 1 days);

        assertTrue(nftCollection721.tokenForSale(1));
        assertEq(nftCollection721.listingStartTime(1), block.timestamp);
        assertEq(nftCollection721.listingEndTime(1), block.timestamp + 1 days);
    }

    function testIsTokenForSale() public {
        vm.prank(owner);
        nftCollection721.mint(user, 1, "ipfs://tokenURI1");

        vm.prank(owner);
        nftCollection721.setTokenForSale(1, true, block.timestamp, block.timestamp + 1 days);

        assertTrue(nftCollection721.isTokenForSale(1));

        vm.warp(block.timestamp + 2 days);

        assertFalse(nftCollection721.isTokenForSale(1));
    }

    function testSupportsInterface() public {
        assertTrue(nftCollection721.supportsInterface(type(IERC165).interfaceId));
        assertTrue(nftCollection721.supportsInterface(type(IERC721).interfaceId));
        assertTrue(nftCollection721.supportsInterface(type(IERC2981).interfaceId));
    }
}
