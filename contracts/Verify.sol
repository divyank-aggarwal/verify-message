// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Verify is Ownable {
    mapping(string => address) public dataToAddress;
    event DataAdded(string data, address sender);

    constructor() {}

    function formMessageHash(string memory data)
        internal
        pure
        returns (bytes32)
    {
        bytes32 test = keccak256(abi.encodePacked(data));
        return keccak256(abi.encodePacked(data));
    }

    function hashMessage(bytes32 data) internal pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 test = keccak256(abi.encodePacked(prefix, data));
        return keccak256(abi.encodePacked(prefix, data));
    }

    function recoverAddress(bytes32 message, bytes memory signature)
        internal
        pure
        returns (address)
    {
        if (signature.length != 65) {
            revert("invalid signature length");
        }
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        return getSigner(message, v, r, s);
    }

    function getSigner(
        bytes32 message,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        require(
            uint256(s) <=
                0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "invalid signature 's' value"
        );
        require(v == 27 || v == 28, "invalid signature 'v' value");
        address signer = ecrecover(hashMessage(message), v, r, s);
        require(signer != address(0), "invalid signature");

        return signer;
    }

    function verifyData(string memory data, bytes memory signature) public {
        require(bytes(data).length > 0);
        bytes32 message = formMessageHash(data);
        require(
            owner() == recoverAddress(message, signature),
            "Invalid Signature!"
        );
        dataToAddress[data] = msg.sender;
        emit DataAdded(data, msg.sender);
    }
}
