// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Test} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
contract OurTokenTest is Test {

    OurToken public ourToken;
    DeployOurToken public deployer;
    function setUp() public {

    }
}
