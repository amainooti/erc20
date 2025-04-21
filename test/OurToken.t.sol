// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is Test {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;
    uint256 public constant BOB_STARTING_AMOUNT = 100 ether;
    uint256 public constant ALICE_STARTING_AMOUNT = 100 ether;

    event Transfer(address indexed from, address indexed to, uint256 value);

    OurToken public ourToken;
    DeployOurToken public deployer;
    address public bob;
    address public alice;

    function setUp() public {
        address owner = makeAddr("deployer");

        vm.prank(owner);
        ourToken = new OurToken(INITIAL_SUPPLY);

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        // impersonate deployer to transfer tokens
        vm.prank(owner);
        ourToken.transfer(bob, BOB_STARTING_AMOUNT);

        vm.prank(owner);
        ourToken.transfer(alice, ALICE_STARTING_AMOUNT);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY);
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testAllowances() public {
        vm.prank(bob);
        ourToken.approve(alice, 1000);

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, 500);

        assertEq(ourToken.balanceOf(alice), ALICE_STARTING_AMOUNT + 500);
        assertEq(ourToken.balanceOf(bob), BOB_STARTING_AMOUNT - 500);
    }

    function testTransferWorks() public {
        vm.prank(alice);
        ourToken.transfer(bob, 10 ether);

        assertEq(ourToken.balanceOf(bob), BOB_STARTING_AMOUNT + 10 ether);
        assertEq(ourToken.balanceOf(alice), ALICE_STARTING_AMOUNT - 10 ether);
    }

    function testTransferFailsIfInsufficientBalance() public {
        vm.expectRevert();
        ourToken.transfer(bob, 1 ether); // msg.sender is deployer now, and has only what's left
    }

    function testApproveAndAllowance() public {
        vm.prank(alice);
        ourToken.approve(bob, 50 ether);

        assertEq(ourToken.allowance(alice, bob), 50 ether);
    }

    function testTransferFromWithApproval() public {
        vm.prank(alice);
        ourToken.approve(bob, 20 ether);

        vm.prank(bob);
        ourToken.transferFrom(alice, bob, 20 ether);

        assertEq(ourToken.balanceOf(bob), BOB_STARTING_AMOUNT + 20 ether);
        assertEq(ourToken.balanceOf(alice), ALICE_STARTING_AMOUNT - 20 ether);
        assertEq(ourToken.allowance(alice, bob), 0);
    }

    function testTransferFromFailsWithoutEnoughAllowance() public {
        vm.prank(alice);
        ourToken.approve(bob, 5 ether);

        vm.prank(bob);
        vm.expectRevert();
        ourToken.transferFrom(alice, bob, 10 ether);
    }

    function testDecimalsIs18() public {
        assertEq(ourToken.decimals(), 18);
    }

    function testEventsAreEmitted() public {
        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, 1 ether);
        ourToken.transfer(bob, 1 ether);
    }

    function testCannotTransferToZeroAddress() public {
        vm.prank(alice);
        vm.expectRevert();
        ourToken.transfer(address(0), 1 ether);
    }

    function testCannotApproveToZeroAddress() public {
        vm.prank(alice);
        vm.expectRevert();
        ourToken.approve(address(0), 1 ether);
    }
}
