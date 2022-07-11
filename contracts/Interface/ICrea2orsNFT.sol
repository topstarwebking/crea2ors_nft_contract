// SPDX-License-Identifier: MIT
// Author: topstardev.703@gmail.com
pragma solidity >=0.8.0 <0.9.0;

interface ICrea2orsNFT {
  function transferNFT(uint256 id, uint256 amount, address from, address to) external;
}