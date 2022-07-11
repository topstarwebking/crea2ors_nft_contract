// SPDX-License-Identifier: MIT
// Author: topstardev.703@gmail.com
pragma solidity >=0.8.0 <0.9.0;

interface ICrea2orsNFT {
  function transferNFT(uint256 id, uint256 amount, address from, address to) external;
}

contract Crea2ors_Manager {
  mapping(address => ICrea2orsNFT) collections;

  function addCollection(address newAddress) public {
    ICrea2orsNFT nftContract = ICrea2orsNFT(newAddress);
    collections[newAddress] = nftContract;
  }

  function transferNFT(address collectionAddress, address from, address to, uint256 id, uint256 amount) public {
    collections[collectionAddress].transferNFT(id, amount, from, to);
  }
}