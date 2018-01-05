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
        PartnerType type;
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

    function BitAuYellowPages() {
        approver = msg.sender;
    }

    function isEntry(address _addr) public constant returns (bool isIndeed) {
        if (entryList.length == 0) return false;
        return entryList[entryMap[_addr].pointer] == _addr;
    }

    function isTbcEntry(address _addr) public constant returns (bool isIndeed) {
        if (tbcEntryList.length == 0) return false;
        return tbcEntryList[tbcEntryMap[_addr].pointer] == _addr;
    }

    function newTbcEntry(bytes10 _ipfsHash, PartnerType _type) public returns (uint pointer){
        // think about change msg.sender to tx.origin
        require(!isEntry(msg.sender));
        require(!isTbcEntry(msg.sender));
        tbcEntryMap[msg.sender].ipfsHash = _ipfsHash;
        tbcEntryMap[msg.sender].type = _type;
        tbcEntryMap[msg.sender].status = EntryStatus.NOT_CONFIRMED;
        tbcEntryMap[msg.sender].addr = msg.sender;
        tbcEntryMap[msg.sender].pointer = tbcEntryList.push(msg.sender).length - 1;
        return tbcEntryList.length;
    }

    function copyTbcEntity(address _tbcAddress) internal {
        require(!isEntry(_tbcAddress));
        entryMap[_tbcAddress].ipfsHash = tbcEntryMap[_tbcAddress].ipfsHash;
        entryMap[_tbcAddress].type = tbcEntryMap[_tbcAddress].type;
        entryMap[_tbcAddress].status = tbcEntryMap[_tbcAddress].status;
        entryMap[_tbcAddress].addr = _tbcAddress;
        entryMap[_tbcAddress].pointer = entryList.push(msg.sender).length - 1;
    }

    function approveEntry(address _addr) public {
        require(msg.sender == approver);
        require(isTbcEntry(_addr));
        require(tbcEntryMap[_addr].status == EntryStatus.NOT_CONFIRMED);
        deleteTbcEntry(_addr);
        copyTbcEntity(_addr);
        entryMap[msg.sender].status = EntryStatus.CONFIRMED;
    }

    function denyEntry(address _addr) public {
        require(msg.sender == approver);
        require(isTbcEntry(_addr));
        require(tbcEntryMap[_addr].status == EntryStatus.NOT_CONFIRMED);
        tbcEntryMap[_addr].status = EntryStatus.DENIED;
    }

    function deactiveEntry(address _addr) public {
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

        uint rowToDelete = entryMap[_addr].pointer;
        address entryToMove = entryList[entryList.length - 1];
        entryList[rowToDelete] = entryToMove;
        entryMap[entryToMove].pointer = rowToDelete;
        entryList.length--;
    }

    function deleteTbcEntry(address _addr) public {
        require(isTbcEntry(_addr));
        require(tbcEntryMap[_addr].status == EntryStatus.DENIED);
        require(msg.sender == approver || msg.sender == _addr);

        uint rowToDelete = tbcEntryMap[_addr].pointer;
        address entryToMove = tbcEntryList[tbcEntryList.length - 1];
        tbcEntryList[rowToDelete] = entryToMove;
        tbcEntryMap[entryToMove].pointer = rowToDelete;
        tbcEntryList.length--;
    }

}