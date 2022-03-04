pragma solidity 0.6.2;



contract PermissionRegistry {


    struct Item {
        string id;
        string description;
    }


    mapping(uint256  /* item index */ => mapping(uint256 /* permission */ => mapping(address /* user address */ => bool /* is granted ?*/))) private permissions; // 1= view permission, 2= edit permission, 3= grant permission
  
    Item[] public items;

    constructor() public {
        Item memory item  =  Item({
            id: "",
            description: ""
        });
        items.push(item);
    }
       
    function createItem(string memory _id, string memory _description) public returns(bool){
        uint256 index =  itemsLength();
        Item memory item  =  Item({
            id: _id,
            description: _description
        });
        items.push(item);
        permissions[index][1][msg.sender] = true;
        permissions[index][2][msg.sender] = true;
        permissions[index][3][msg.sender] = true;
        return true;
    }

    function grantPermissions(string memory _id, address _user, uint256 _permission) public {
        require(_permission >= 1 && _permission <= 3, "grantPermissions: permission integer not allowed.");
        require(_user != address(0), "grantPermissions: user zero address not allowed.");
        uint256 index = getIndex(_id);
        require(index > 0, "grantPermissions: id doesn't exist.");
        require(checkUserPermission(index, 3, msg.sender), "grantPermissions: user isn't granted.");
        permissions[index][_permission][_user] = true;
    }

    function checkUserPermission(uint256 index, uint256 permission, address user) private view returns(bool){
        return permissions[index][permission][user];
    }

    function getIndex(string memory _id) private view returns(uint256){
        for(uint256 i = 0; i < itemsLength(); i++) {
            Item memory item = items[i];
            if(keccak256(abi.encodePacked(_id)) == keccak256(abi.encodePacked(item.id))) return i;
        }
        return 0;
    }

    function editItem(string memory _id, string memory _description) public returns(bool){
        uint256 index = getIndex(_id);
        require(index > 0, "editItem: id doesn't exist.");
        require(checkUserPermission(index, 2, msg.sender), "editItem: user isn't allowed to edit.");
        Item storage item = items[index];
        item.description = _description;
        return true;
    }

    function hasPermission(string memory _id, address _user, uint256 _permission) public view returns(bool){
        uint256 index = getIndex(_id);
        require(index > 0, "hasPermission: id doesn't exist.");
        return checkUserPermission(index, _permission, _user);
    }

    function getPermissions(string memory _id, address _user) public view returns(bool[] memory) {
        bool[] memory boolPermList = new bool[](3);
        for(uint256 i = 0; i < 3; i++){
            boolPermList[i] = hasPermission(_id, _user, i + 1);
        }
        return boolPermList;
    }

    function itemsLength() public view returns(uint256) {
        return items.length;
    }
}
