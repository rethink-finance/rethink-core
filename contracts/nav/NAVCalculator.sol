pragma solidity ^0.8.17;

import "./NAVLiquid.sol";
import "./NAVIlliquid.sol";
import "./NAVComposable.sol";
import "./NAVNft.sol";

contract NAVCalculator is NAVLiquid, NAVIlliquid, NAVComposable, NAVNft {}