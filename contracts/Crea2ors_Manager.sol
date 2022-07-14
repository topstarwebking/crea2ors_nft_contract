// SPDX-License-Identifier: MIT
// Author: topstardev.703@gmail.com
pragma solidity >=0.8.0 <0.9.0;

interface ICrea2orsNFT {
  function transferNFT(uint256 id, uint256 amount, address from, address to, uint256 fund) external;
}

interface ICrea2Crypto {
  function approve(address spender, uint256 fund) external;
}

contract Crea2ors_Manager {
  mapping(address => ICrea2orsNFT) collections;
  ICrea2Crypto cr2Contract;

  constructor(address cr2ContractAddress) {
    cr2Contract = ICrea2Crypto(cr2ContractAddress);
  }

    // add new collection to nft collection list
    function addCollection(address newAddress) public {
        ICrea2orsNFT nftContract = ICrea2orsNFT(newAddress);
        collections[newAddress] = nftContract;
    }

  function transferNFT(address collectionAddress, address from, address to, uint256 id, uint256 amount, uint256 fund) public {
    cr2Contract.approve(address(this), fund);
    collections[collectionAddress].transferNFT(id, amount, from, to, fund);
  }
}
