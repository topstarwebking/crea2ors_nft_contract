// SPDX-License-Identifier: MIT
// Author: gentlesmile918@gmail.com
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "hardhat/console.sol";

contract Crea2orsNFT is ERC1155, Ownable, EIP712 {
    uint256 private _currentTokenID = 0;
    string private _contractURI;
    uint256 private tokenLimit;
    string public name;
    string public symbol;

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
        uint256 minPrice;
        uint256 initialSupply;
        uint256 royaltyFee;
        address royaltyAddress;
        Sig signature;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        uint256 totalLimit_
    ) ERC1155("") EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        constructed = true;
        tokenLimit = totalLimit_;
        name = name_;
        symbol = symbol_;
        emit ContractDeployed(msg.sender, contractURI_);

        setContractURI(contractURI_);
    }

    function init(string memory _name, string memory _symbol) public {
        require(!constructed, "ERC155 Tradeable must not be constructed yet");

        name = _name;
        symbol = _symbol;
    }

    function _verify(NFTVoucher memory voucher) internal view returns(address) {
        bytes32 digest = _hash(voucher);
        return ecrecover(digest, voucher.signature.v, voucher.signature.r, voucher.signature.s);
    }

    function _hash(NFTVoucher memory voucher) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32", 
            keccak256(bytes(voucher.metaUri))
        ));
    }

    function setContractURI(string memory contractURI_) public onlyOwner payable {
        _contractURI = contractURI_;

        emit ContractURIChanged(contractURI_);
    }

    // function mintAndTransfer(LibERC1155LazyMint.NFTVoucher memory data, address to, uint256 _amout) public override virtual {
    //     address minter = msg.sender;
    //     require(_amount > 0, "incorrect amount");

    //     if (initialSupplies[data.tokenId] == 0) {
    //         require(minter == data.creators[0].account, "tokenID incorrect");
    //         require(data.supply > 0, "supply incorrect");
    //         require(data.creators.length == data.signature.length, "invalid Data");

    //         bytes32 hash = LibERC1155LazyMint.hash(data);
    //         for (uint i = 0; i < data.creators.length; i++) {
    //             address creator = data.creators[i].account;
    //             if (creator != minter) {

    //             }
    //         }

    //         initialSupplies[data.tokenId] = data.supply;
    //         _saveSupply(data.tokenId, data.supply);
    //         _saveRoyalties(data.tokenId, data.royalties);
    //         _saveCreators(data.tokenId, data.creators);
    //         _setTokenURI(data.tokenId, data.tokenURI);
    //     }

    //     mint(data.tokenId, data.supply, "");
    // }

    function redeem(address redeemer, NFTVoucher memory voucher) public payable returns (uint256) {
        address signer = _verify(voucher);
        console.log("signer %s",  signer);
        require(signer);
        require(voucher.initialSupply <= 1000, "Initial supply cannot be more than 1000");
        // uint256 _id = _getNextTokenID();
        // require(_id <= tokenLimit, "Flushed nft total limit");
        // require(msg.value >= voucher.minPrice * voucher.initialSupply, "Insufficient funds to redeem");
        // require(curMintedSupplies[voucher.tokenId] + voucher.mintCount > initialSupplies[voucher.tokenId], "All minted!");
        // setURI(voucher.tokenId, voucher.metaUri);
        // if (voucher.initialSupply != 0)
        //     _mint(redeemer, voucher.tokenId, voucher.mintCount, "");
        // uint256[] memory idArray = new uint256[](1);
        // idArray[0] = voucher.tokenId;
        // uint256[] memory mintCntArray = new uint256[](1);
        // mintCntArray[0] = voucher.mintCount;
        // if (initialSupplies[voucher.tokenId] == 0) {
        //     initialSupplies[voucher.tokenId] = voucher.initialSupply;
        //     royaltyAddresses[voucher.tokenId] = voucher.royaltyAddress;
        //     royaltyFees[voucher.tokenId] = voucher.royaltyFee;
        // }
        // curMintedSupplies[voucher.tokenId] += voucher.mintCount;

        return voucher.tokenId;
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
}
