// SPDX-License-Identifier: MIT
// Author: topstardev.703@gmail.com
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

interface ICrea2Crypto {
  function transfer(address to, uint tokens) external;
  function balanceOf(address addr) external returns (uint256);
  function transferFrom(address from , address to, uint tokens) external;
}

contract Crea2orsNFT is ERC1155, Ownable, EIP712 {
    uint256 public _currentTokenID = 0;
    string private _contractURI;
    uint256 private tokenLimit;
    string public name;
    string public symbol;
    ICrea2Crypto cr2Contract;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => address) public royaltyAddresses; //NFT creator not owner
    mapping(uint256 => uint256) public initialSupplies;
    mapping(uint256 => uint256) public curMintedSupplies;
    mapping(uint256 => uint256) public royaltyFees;
    mapping(uint256 => string) private metaDataUris;
    
    bool private constructed = false;
    string private constant SIGNING_DOMAIN = "LazyNFT-Voucher";
    string private constant SIGNATURE_VERSION = "1";

    struct Sig {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    struct NFTVoucher {
        uint256 tokenId;
        string metaUri;
        uint256 mintCount;
        uint256 mintPrice;
        uint256 initialSupply;
        uint256 royaltyFee;
        address royaltyAddress;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        uint256 totalLimit_,
        address cr2ContractAddress_
    ) ERC1155("") EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        constructed = true;
        tokenLimit = totalLimit_;
        name = name_;
        symbol = symbol_;
        cr2Contract = ICrea2Crypto(cr2ContractAddress_);
        emit ContractDeployed(msg.sender, contractURI_);

        setContractURI(contractURI_);
    }

    function getCurMintedSupply(uint256 tokenID) public view returns(uint256) {
        return curMintedSupplies[tokenID];
    }

    function init(string memory _name, string memory _symbol) public {
        require(!constructed, "ERC155 Tradeable must not be constructed yet");

        name = _name;
        symbol = _symbol;
    }

    function setContractURI(string memory contractURI_) public onlyOwner payable {
        _contractURI = contractURI_;

        emit ContractURIChanged(contractURI_);
    }

    function redeem(address redeemer, NFTVoucher memory voucher) public payable returns (uint256) {
        require(voucher.mintPrice < cr2Contract.balanceOf(redeemer), "insufficient funds");
        require(voucher.initialSupply <= 1000, "Initial supply cannot be more than 1000");
        require(_currentTokenID < tokenLimit, "Flushed nft total limit");
        require(voucher.mintCount != 0, "Can not mint Zero count");

        if (_currentTokenID == voucher.tokenId) {
            initialSupplies[voucher.tokenId] = voucher.initialSupply;
            royaltyAddresses[voucher.tokenId] = voucher.royaltyAddress;
            royaltyFees[voucher.tokenId] = voucher.royaltyFee;
            setURI(voucher.tokenId, voucher.metaUri);
            _currentTokenID++;
        } 
        require(curMintedSupplies[voucher.tokenId] + voucher.mintCount < initialSupplies[voucher.tokenId], "All minted!");
        _mint(redeemer, voucher.tokenId, voucher.mintCount, "");
        // when mint, transfer CREA2 token to NFT creator
        cr2Contract.transfer(voucher.royaltyAddress, voucher.mintCount);
        curMintedSupplies[voucher.tokenId] += voucher.mintCount;
        emit LazyMinted(voucher.tokenId);
        return voucher.tokenId;
    }

    //This is transfer function
    function transferNFT(uint256 _id, uint256 _amount, address from, address to, uint256 fund) public {
        require(_amount > 0, "Can not transfer zero NFT");
        require(fund < cr2Contract.balanceOf(to), "Insufficient fund of buyer");
        
        uint256 royalty = fund * royaltyFees[_id] / 100;
        // Send fee to contract owner
        cr2Contract.transferFrom(to, royaltyAddresses[_id], royalty);
        // Send money to seller
        cr2Contract.transferFrom(to, from, fund - royalty);
        // Send NFT to buyer
        safeTransferFrom(from, to, _id, _amount, "");
        emit NFTTransfered(_id, _amount, from, to);
    }

    function setURI(uint256 _id, string memory _uri) public payable {
        require(_exists(_id), "ERC1155#uri: NONEXISTENT_TOKEN");
        metaDataUris[_id] = _uri;
        emit TokenURIChanged(_id, _uri);
    }

    function uri(uint256 _id) public view override returns (string memory) {
        require(_exists(_id), "ERC1155#uri: NONEXISTENT_TOKEN");

        string memory _tokenURI = metaDataUris[_id];
        return _tokenURI;
    }

    function batchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public payable {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function burn(uint256 _id, uint256 _amount) public onlyOwner payable {
        require(_exists(_id), "ERC1155 #burn: NONEXISTENT_TOKEN");
        _burn(msg.sender, _id, _amount);
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function totalSupply(uint256 _id) public view returns (uint256) {
        return initialSupplies[_id];
    }

    function _exists(uint256 _id) internal view returns (bool) {
        return royaltyAddresses[_id] != address(0);
    }

    function _getNextTokenID() private view returns (uint256) {
        return _currentTokenID + 1;
    }

    function _incrementTokenTypeId() private {
        _currentTokenID++;
    }

    event ContractDeployed(address, string);
    event ContractURIChanged(string);
    event TokenURIChanged(uint256, string);
    event LazyMinted(uint256);
    event NFTTransfered(uint256, uint256, address, address);

}

//all finished
