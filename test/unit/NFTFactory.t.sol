// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/NFTFactory.sol";
import "../../src/NFTCollection1155.sol";
import "../../src/NFTCollection721.sol";

contract NFTFactoryTest is Test {
    NFTFactory public nftFactory;
    address public owner = address(1);
    address public admin = address(2);
    address public user = address(3);

    function setUp() public {
        nftFactory = new NFTFactory();
        nftFactory.initialize();
        nftFactory.addAdmin(admin);
    }

    function testSubmitProject() public {
        vm.prank(user);
        nftFactory.submitProject("Test Project");
        (string memory details, NFTFactory.ProjectStatus status) = nftFactory.submittedProjects(user);
        assertEq(details, "Test Project");
        assertEq(uint(status), uint(NFTFactory.ProjectStatus.Pending));
    }

    function testApproveProject() public {
        vm.prank(user);
        nftFactory.submitProject("Test Project");
        vm.prank(admin);
        nftFactory.approveProject(user);
        (, NFTFactory.ProjectStatus status) = nftFactory.submittedProjects(user); // Ignore the 'details' variable
        assertEq(uint(status), uint(NFTFactory.ProjectStatus.Approved));
    }

    function testRejectProject() public {
        vm.prank(user);
        nftFactory.submitProject("Test Project");
        vm.prank(admin);
        nftFactory.rejectProject(user);
        (, NFTFactory.ProjectStatus status) = nftFactory.submittedProjects(user); // Ignore the 'details' variable
        assertEq(uint(status), uint(NFTFactory.ProjectStatus.Rejected));
    }

    function testCreateERC1155Collection() public {
        vm.prank(user);
        nftFactory.submitProject("Test Project");
        vm.prank(admin);
        nftFactory.approveProject(user);

        vm.prank(user);
        nftFactory.createERC1155Collection("Test ERC1155", "T1155", "Test ERC1155 Collection", 100, 500);

        address collectionAddress = nftFactory.collectionOwners(address(nftFactory));
        assertTrue(collectionAddress != address(0));

        (, NFTFactory.ProjectStatus status) = nftFactory.submittedProjects(collectionAddress); // Ignore the 'details' variable
        assertEq(uint(status), uint(NFTFactory.ProjectStatus.Pending));
    }

    function testCreateERC721Collection() public {
        vm.prank(user);
        nftFactory.submitProject("Test Project");
        vm.prank(admin);
        nftFactory.approveProject(user);

        vm.prank(user);
        nftFactory.createERC721Collection("Test ERC721", "T721", "Test ERC721 Collection", 100, 500);

        address collectionAddress = nftFactory.collectionOwners(address(nftFactory));
        assertTrue(collectionAddress != address(0));

        (, NFTFactory.ProjectStatus status) = nftFactory.submittedProjects(collectionAddress); // Ignore the 'details' variable
        assertEq(uint(status), uint(NFTFactory.ProjectStatus.Pending));
    }
}
