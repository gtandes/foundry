// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/NFTCollection1155.sol";

contract NFTCollection1155Test is Test {
    NFTCollection1155 public nftCollection1155;
    address public owner = address(1);
    address public user = address(2);

    function setUp() public {
        nftCollection1155 = new NFTCollection1155();
        nftCollection1155.initialize(
            "Test Collection",
            "TC",
            "Test Description",
            100,
            owner,
            500
        );
    }

    function testInitialize() public {
        assertEq(nftCollection1155.name(), "Test Collection");
        assertEq(nftCollection1155.symbol(), "TC");
        assertEq(nftCollection1155.description(), "Test Description");
        assertEq(nftCollection1155.maxSupply(), 100);
    }

    function testMint() public {
        vm.startPrank(owner);
        nftCollection1155.mint(user, 1, 10, "", "ipfs://tokenURI1");
        vm.stopPrank();

        assertEq(nftCollection1155.totalMinted(), 10);
        assertEq(nftCollection1155.uri(1), "ipfs://tokenURI1");
    }

    function testMintExceedMaxSupply() public {
        vm.startPrank(owner);
        vm.expectRevert("NFTCollection1155: Exceeds max supply");
        nftCollection1155.mint(user, 1, 101, "", "ipfs://tokenURI1");
        vm.stopPrank();
    }

    function testMintBatch() public {
        vm.startPrank(owner);
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 10;
        amounts[1] = 20;

        string[] memory uris = new string[](2);
        uris[0] = "ipfs://tokenURI1";
        uris[1] = "ipfs://tokenURI2";

        nftCollection1155.mintBatch(user, ids, amounts, "", uris);
        vm.stopPrank();

        assertEq(nftCollection1155.totalMinted(), 30);
        assertEq(nftCollection1155.uri(1), "ipfs://tokenURI1");
        assertEq(nftCollection1155.uri(2), "ipfs://tokenURI2");
    }

    function testSetTokenSalePrice() public {
        vm.startPrank(owner);
        nftCollection1155.setTokenSalePrice(1, 10 ether);
        vm.stopPrank();

        assertEq(nftCollection1155.tokenSalePrice(1), 10 ether);
    }

    function testSetTokenForSale() public {
        vm.startPrank(owner);
        nftCollection1155.setTokenForSale(
            1,
            true,
            block.timestamp,
            block.timestamp + 1 days
        );
        vm.stopPrank();

        assertTrue(nftCollection1155.tokenForSale(1));
    }

    function testIsTokenForSale() public {
        vm.startPrank(owner);
        nftCollection1155.setTokenForSale(
            1,
            true,
            block.timestamp,
            block.timestamp + 1 days
        );
        vm.stopPrank();

        assertTrue(nftCollection1155.isTokenForSale(1));
    }

    function testSupportsInterface() public {
        assertTrue(
            nftCollection1155.supportsInterface(type(IERC165).interfaceId)
        );
        assertTrue(
            nftCollection1155.supportsInterface(type(IERC1155).interfaceId)
        );
        assertTrue(
            nftCollection1155.supportsInterface(type(IERC2981).interfaceId)
        );
    }
}
