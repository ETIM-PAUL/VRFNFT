// SPDX-License-Identifier: MIT

// An ERC1155 Contract that mints NFT based on attributes.
pragma solidity 0.8.19;

contract JOE_GAMING_NFT {
    //struct to contain nft attributes
    struct JOE_GAMER_ATTRIBUTES {
        uint gunSize;
        uint noOfBullets;
        uint noOfGrenade;
        uint gunType;
        uint combatUniformColor;
        uint noOfLives;
    }

    //struct to contain an nft holder information
    struct Minter {
        uint noOfMint;
        uint lastMint;
        uint lastMintTokenId;
    }

    //total mints supplied
    uint totalMints;

    //mapping of nft token id to its attributes
    mapping(uint => JOE_GAMER_ATTRIBUTES) gamingMinter;

    //mapping of nft holder to his information
    mapping(address => Minter) minterTokenId;

    //mapping to know if an address has minted joe gamer nft
    mapping(address => bool) hasMinted;

    function _Mint() external {}
}
