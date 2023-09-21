// SPDX-License-Identifier: MIT

// An ERC1155 Contract that mints NFT based on attributes.
pragma solidity 0.8.19;

import "./VRFInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract JOE_GAMING_NFT is ERC721URIStorage, VRFConsumerBaseV2 {
    event RequestSent(uint256 requestId, uint32 numWords);
    event NFT_MINTED(JOE_NFT_MINTER, JOE_GAMER_ATTRIBUTES);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    using Strings for uint256;

    VRFCoordinatorV2Interface immutable COORDINATOR;

    uint64 immutable s_subscriptionId;

    bytes32 immutable s_keyHash;

    uint32 constant CALLBACK_GAS_LIMIT = 2500000;

    uint16 constant REQUEST_CONFIRMATIONS = 3;

    uint32 constant NUM_WORDS = 2;

    address s_owner;

    // uint256[] public requestIds;
    uint256 public lastRequestId;

    uint256 internal constant MAX_CHANCE_VALUE = 100;

    //customized error
    error Gamer_VALUE_OUT_OF_RANGE();

    //struct to contain nft attributes
    enum JOE_GAMER_ATTRIBUTES {
        BadGamer,
        SlowGamer,
        TopGamer,
        LegendGamer,
        CombatGamer,
        NoGamer
    }

    //struct to contain an nft holder information
    struct JOE_NFT_MINTER {
        address minterAddress;
        uint mintTime;
    }

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests;

    //total mints supplied
    uint mintTracker;

    //mapping of nft token id to its attributes
    mapping(uint => JOE_GAMER_ATTRIBUTES) gamingMinter;

    //mapping of nft holder to his information
    mapping(uint => JOE_NFT_MINTER) public minterDetails;

    string[6] internal s_nftTokenUri;

    // Constructor with all the paremeter needed for Chainlink VRF and UriStorage NFTs
    constructor(
        string[6] memory _uris
    )
        VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D)
        ERC721("Joe Gaming NFT", "JFT")
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D
        );
        s_keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
        s_owner = msg.sender;
        s_subscriptionId = 14204;
        s_nftTokenUri = _uris;
    }

    function requestRandomWords() external returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            REQUEST_CONFIRMATIONS,
            CALLBACK_GAS_LIMIT,
            NUM_WORDS
        );

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });

        lastRequestId = requestId;
        emit RequestSent(requestId, NUM_WORDS);
        return requestId;
    }

    // Fulfill Chainlink Randomness Request

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function mintNFT()
        external
        returns (bool success, JOE_GAMER_ATTRIBUTES nftGamer)
    {
        //get tokenId status
        RequestStatus memory _request = s_requests[lastRequestId];

        // mint NFT
        uint256 newItemId = mintTracker;

        uint256 moddedRng = _request.randomWords[0] % 6;
        nftGamer = JOE_GAMER_ATTRIBUTES(moddedRng + 1);

        JOE_NFT_MINTER storage _minterDetails = minterDetails[lastRequestId];
        _minterDetails.minterAddress = msg.sender;
        _minterDetails.mintTime = block.timestamp;

        gamingMinter[mintTracker] = nftGamer;

        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, s_nftTokenUri[uint8(nftGamer)]);

        success = true;
        mintTracker += 1;
        emit NFT_MINTED(_minterDetails, nftGamer);
        return (success, nftGamer);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    function tokenURI(
        uint256 token_ID
    ) public view virtual override returns (string memory) {
        require(_exists(token_ID), "Doesn't Exist");

        string memory baseURI = _baseURI(uint8(gamingMinter[token_ID]));
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(
                        s_nftTokenUri[uint8(gamingMinter[token_ID])]
                    )
                )
                : "";
    }

    function _baseURI(uint index) public view returns (string memory) {
        return s_nftTokenUri[index];
    }
}
