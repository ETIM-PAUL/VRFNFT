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

    VRFCoordinatorV2Interface immutable COORDINATOR;

    uint64 immutable s_subscriptionId;

    bytes32 immutable s_keyHash;

    uint32 constant CALLBACK_GAS_LIMIT = 2500000;

    uint16 constant REQUEST_CONFIRMATIONS = 3;

    uint32 constant NUM_WORDS = 6;

    uint256[] public s_randomWords;

    uint256 public requestId;

    address s_owner;

    // uint256[] public requestIds;
    uint256 public lastRequestId;

    mapping(uint => address) public mappedIdToSender;

    uint256 internal constant MAX_CHANCE_VALUE = 100;

    //customized error
    error Gamer_VALUE_OUT_OF_RANGE();

    //struct to contain nft attributes
    enum JOE_GAMER_ATTRIBUTES {
        gunSize,
        noOfBullets,
        noOfGrenade,
        gunType,
        combatUniformColor,
        noOfLives
    }

    //struct to contain an nft holder information
    struct JOE_NFT_MINTER {
        address minterAddress;
        uint mintTime;
    }

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256 randomWord;
    }

    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    //total mints supplied
    uint mintTracker;

    //mapping of nft token id to its attributes
    mapping(uint => JOE_GAMER_ATTRIBUTES) gamingMinter;

    //mapping of nft holder to his information
    mapping(uint => JOE_NFT_MINTER) minterDetails;

    //mapping to know if an address has minted joe gamer nft
    mapping(address => bool) hasMinted;

    string[] internal s_nftTokenUri;

    // Constructor with all the paremeter needed for Chainlink VRF and UriStorage NFTs
    constructor(
        uint64 subscriptionId,
        address vrfCoordinator,
        bytes32 keyHash,
        string[1] memory _baseuri
    ) VRFConsumerBaseV2(vrfCoordinator) ERC721("Joe Gaming NFT", "JFT") {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_keyHash = keyHash;
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
        s_nftTokenUri = _baseuri;
    }

    function requestRandomWords() external returns (uint) {
        requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            REQUEST_CONFIRMATIONS,
            CALLBACK_GAS_LIMIT,
            NUM_WORDS
        );

        s_requests[requestId] = RequestStatus({
            randomWord: 0,
            exists: true,
            fulfilled: false
        });

        lastRequestId = requestId;

        mappedIdToSender[requestId] = msg.sender;
        emit RequestSent(requestId, NUM_WORDS);

        return requestId;
    }

    // Fulfill Chainlink Randomness Request

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory randomWords
    ) internal override {
        // require(mappedIdToSender[_requestId], "invalid request id");
        address nftOwner = mappedIdToSender[_requestId];

        uint256 newItemId = mintTracker;
        mintTracker = mintTracker + 1;

        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
        JOE_GAMER_ATTRIBUTES nftGamer = getGamerFromModdedRng(moddedRng);

        // mint NFT
        _safeMint(nftOwner, mintTracker);
        _setTokenURI(newItemId, s_nftTokenUri[uint(nftGamer)]);

        //update minter details
        JOE_NFT_MINTER storage _minterDetails = minterDetails[_requestId];
        _minterDetails.minterAddress = msg.sender;
        _minterDetails.mintTime = block.timestamp;

        //confirm that an address has mint an NFT
        hasMinted[msg.sender] = true;

        //struct for minter
        emit NFT_MINTED(_minterDetails, nftGamer);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256 randomWord) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWord);
    }

    // Get Gamer from Modded RNG
    function getGamerFromModdedRng(
        uint256 moddedRng
    ) public pure returns (JOE_GAMER_ATTRIBUTES) {
        uint256 totalSum = 0;
        uint256[6] memory changeArray = getChanceArray();
        for (uint256 i = 0; i < changeArray.length; i++) {
            if (moddedRng >= totalSum && moddedRng < changeArray[i]) {
                return JOE_GAMER_ATTRIBUTES(i);
            }
            totalSum += changeArray[i];
        }
        revert Gamer_VALUE_OUT_OF_RANGE();
    }

    // Get the Change to get a specific Gamer
    function getChanceArray() public pure returns (uint256[6] memory) {
        return [20, 6, 8, 20, 50, MAX_CHANCE_VALUE];
    }

    function tokenURI(
        uint256 token_ID
    ) public view virtual override returns (string memory) {
        require(_exists(token_ID), "Doesn't Exist");

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI)) : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return s_nftTokenUri[0];
    }
}
