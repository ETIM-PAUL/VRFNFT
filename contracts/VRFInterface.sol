// SPDX-License-Identifier: MIT

// An ERC1155 Contract that mints NFT based on attributes.
pragma solidity 0.8.19;

struct RequestStatus {
    bool fulfilled; // whether the request has been successfully fulfilled
    bool exists; // whether a requestId exists
    uint256[] randomWords;
}

interface VRFInterface {
    function requestRandomWords() external view returns (uint256 requestId);

    function lastRequestId() external view returns (uint256 requestId);

    function owner() external view returns (address);

    function s_requests(uint) external view returns (RequestStatus memory);

    function getRequestStatus(
        uint
    ) external view returns (bool fulfilled, uint256[] memory);
}
