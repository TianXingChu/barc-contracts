pragma solidity ^0.4.19;

contract BitAuYellowPages {

    enum EntryStatus {
        NOT_CONFIRMED, CONFIRMED, DENIED, DEACTIVED
    }

    enum PartnerType {
        Auditor, Institution
    }

    struct Entry {
        bytes10 ipfsHash;
        PartnerType pt;
        EntryStatus status;
        address addr;
        uint pointer;
    }

    address public approver;

    // partners
    mapping(address => Entry) entryMap;
    address[] public entryList;

    // to be confirmed
    mapping(address => Entry) tbcEntryMap;
    address[] public tbcEntryList;

    function BitAuYellowPages() public {
        approver = msg.sender;
    }

    function _copyTbcEntry(address _addr) internal {
        entryMap[_addr].ipfsHash = tbcEntryMap[_addr].ipfsHash;
        entryMap[_addr].pt = tbcEntryMap[_addr].pt;
        entryMap[_addr].status = tbcEntryMap[_addr].status;
        entryMap[_addr].addr = _addr;
        entryMap[_addr].pointer = entryList.push(msg.sender) - 1;
    }

    function _deleteEntry(address _addr) internal {
        uint rowToDelete = entryMap[_addr].pointer;
        address entryToMove = entryList[entryList.length - 1];
        entryList[rowToDelete] = entryToMove;
        entryMap[entryToMove].pointer = rowToDelete;
        entryList.length--;
    }

    function _deleteTbcEntry(address _addr) internal {
        uint rowToDelete = tbcEntryMap[_addr].pointer;
        address entryToMove = tbcEntryList[tbcEntryList.length - 1];
        tbcEntryList[rowToDelete] = entryToMove;
        tbcEntryMap[entryToMove].pointer = rowToDelete;
        tbcEntryList.length--;
    }

    function isEntry(address _addr) public constant returns (bool isIndeed) {
        if (entryList.length == 0) return false;
        return entryList[entryMap[_addr].pointer] == _addr;
    }

    function isTbcEntry(address _addr) public constant returns (bool isIndeed) {
        if (tbcEntryList.length == 0) return false;
        return tbcEntryList[tbcEntryMap[_addr].pointer] == _addr;
    }

    function newTbcEntry(bytes10 _ipfsHash, PartnerType _type) public {
        require(!isEntry(msg.sender));
        require(!isTbcEntry(msg.sender));
        tbcEntryMap[msg.sender].ipfsHash = _ipfsHash;
        tbcEntryMap[msg.sender].pt = _type;
        tbcEntryMap[msg.sender].status = EntryStatus.NOT_CONFIRMED;
        tbcEntryMap[msg.sender].addr = msg.sender;
        tbcEntryMap[msg.sender].pointer = tbcEntryList.push(msg.sender) - 1;
    }

    function deleteTbcEntry(address _addr) public {
        require(isTbcEntry(_addr));
        require(msg.sender == approver || msg.sender == _addr);

        _deleteTbcEntry(_addr);
    }

    function approveTbcEntry(address _addr) public {
        require(msg.sender == approver);
        require(isTbcEntry(_addr));
        require(tbcEntryMap[_addr].status == EntryStatus.NOT_CONFIRMED);

        _copyTbcEntry(_addr);
        _deleteTbcEntry(_addr);
        entryMap[_addr].status = EntryStatus.CONFIRMED;
    }

    function denyTbcEntry(address _addr) public {
        require(msg.sender == approver);
        require(isTbcEntry(_addr));
        require(tbcEntryMap[_addr].status == EntryStatus.NOT_CONFIRMED);

        tbcEntryMap[_addr].status = EntryStatus.DENIED;
    }

    function deactiveTbcEntry(address _addr) public {
        require(isEntry(_addr));
        require(entryMap[_addr].status == EntryStatus.CONFIRMED);
        require(msg.sender == approver || msg.sender == _addr);

        entryMap[_addr].status = EntryStatus.DEACTIVED;
    }

    function reactiveEntry(address _addr) public {
        require(isEntry(_addr));
        require(entryMap[_addr].status == EntryStatus.DEACTIVED);
        require(msg.sender == approver);

        entryMap[_addr].status = EntryStatus.CONFIRMED;
    }

    function deleteEntry(address _addr) public {
        require(isEntry(_addr));
        require(entryMap[_addr].status == EntryStatus.DEACTIVED);
        require(msg.sender == approver);

        _deleteEntry(_addr);
    }

}