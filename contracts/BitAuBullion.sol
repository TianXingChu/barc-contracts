pragma solidity ^0.4.19;

contract BitAuBullion {

    enum BullionStatus {
        // TODO: more status to be added
        NOT_PASS_AUDIT, ACTIVED, CASTED, ORDERED_OUT
    }

    // ipfs file identifier, see https://ethereum.stackexchange.com/questions/17094/how-to-store-ipfs-hash-using-bytes
    /*struct Multihash {
        bytes32 hash;
        uint8 hashFunction;
        uint8 size;
    }*/

    struct Bullion {
        bytes10 ipfsHash;
        BullionStatus status;
        address holdBy;
        // the serial number (which must not comprise of more than eleven digits or characters) see more http://www.lbma.org.uk/assets/market/gdl/GD_Rules_15_Final%2020160816.pdf
        // if sn's length is not 11, right padded with space(' ').
        bytes11 sn;
        uint32 coinQuantity;
        uint pointer;
    }

    // sn mapped bullion entity
    mapping(bytes11 => Bullion) private bullionMap;
    bytes11[] public snList;

    function isBullion(bytes11 _sn) public constant returns (bool isIndeed) {
        if (snList.length == 0) return false;
        return equals(snList[bullionMap[_sn].pointer], _sn);
    }

    function newBullion(bytes10 _ipfsHash, bytes11 _sn, uint32 _bacQuantity) public returns (uint pointer) {
        require(!isBullion(_sn));
        bullionMap[_sn].ipfsHash = _ipfsHash;
        bullionMap[_sn].status = BullionStatus.NOT_PASS_AUDIT;
        bullionMap[_sn].holdBy = this;
        bullionMap[_sn].sn = _sn;
        bullionMap[_sn].coinQuantity = _bacQuantity;
        bullionMap[_sn].pointer = snList.push(_sn) - 1;
        return snList.length - 1;
    }

    function deleteBullion(bytes11 _sn) public returns (uint index) {
        require(isBullion(_sn));
        // TODO: status limit should be considered again
        require(bullionMap[_sn].status != BullionStatus.ACTIVED);
        uint rowToDelete = bullionMap[_sn].pointer;
        bytes11 snToMove = snList[snList.length - 1];
        snList[rowToDelete] = snToMove;
        bullionMap[snToMove].pointer = rowToDelete;
        snList.length--;
        return rowToDelete;
    }

    function getBullion(bytes11 _sn) public constant returns (bytes10 ipfsHash, BullionStatus status, address holdBy, uint32 bacQuantity) {
        require(isBullion(_sn));
        return (
        bullionMap[_sn].ipfsHash,
        bullionMap[_sn].status,
        bullionMap[_sn].holdBy,
        bullionMap[_sn].coinQuantity);
    }

    function equals(bytes11 _a, bytes11 _b) private pure returns (bool isEqual){
        if (_a.length != _b.length) {
            return false;
        }
        for (uint i = 0; i < _a.length; i++) {
            if (_a[i] != _b[i]) {
                return false;
            }
        }
        return true;
    }

}