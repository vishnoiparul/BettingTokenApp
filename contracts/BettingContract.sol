pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "../zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

contract BaitToken is MintableToken {
    string public constant name = "Betting Token";
    string public constant symbol = "BETS";
    uint public constant decimals = 18;
    uint public INITIAL_SUPPLY = 10000 * (10 ** decimals);
    address bettingFundWallet;
    uint i = 0;

    struct Bets {
        uint id;
        bytes32 instance_id;
        address user_address;
        string status;
        uint256 raisedBet;
    }
    
    mapping(uint => Bets) betsRaised;

    struct Users {
        address user_address;
        bytes32[] instances;
    }
    
    mapping(address => Users) userBetting;

    modifier onlyAdmin {
        require(bettingFundWallet == msg.sender);
        _;
    }

    constructor() public {
        bettingFundWallet = msg.sender;
        mint(bettingFundWallet,INITIAL_SUPPLY);
    }

    function addUser(address _user) public{
        balances[_user] = 10000;
    }

    function createBets(bytes32 i_id,address w_id,uint _amount,string _status) public {

        require(_amount > 1000);
        require(_amount < 5000);
        require(balances[w_id] > _amount);

        //Checking if user has already registered for bait or not
        bytes32[] storage iArray = userBetting[w_id].instances;
        for(uint k = 0;k < iArray.length;k++){
            if(iArray[k] == i_id) {
                revert();
            }
        }
        userBetting[w_id].instances.push(i_id);

        betsRaised[i].id = i;
        betsRaised[i].instance_id = i_id;
        betsRaised[i].user_address = w_id;  
        betsRaised[i].raisedBet = _amount;
        betsRaised[i].status = _status;

        transferFrom(w_id, bettingFundWallet, _amount);
    }

    uint[] fetch_id;
    
    function getBet(bytes32 i_id) private {
        for(uint _i = 0;_i < i ;_i++){
            if( betsRaised[_i].instance_id == i_id){
                fetch_id.push(betsRaised[_i].id);
            }
        }
    }
    
    function distribute(bytes32 i_id,string result) public onlyAdmin {
        
        fetch_id = new uint[](0);
        getBet(i_id);
        for(uint _k = 0;_k < fetch_id.length;_k++){
            uint _id = fetch_id[_k];
            if(keccak256(betsRaised[_id].status) == keccak256(result)){
                transfer(betsRaised[_id].user_address,(betsRaised[_id].raisedBet)*2);
                // betsRaised[_id].user_address.transfer(betsRaised[_id].raisedBet*1 ether);
            }
        }
        
    }
    
    function getUser(bytes32 i_id) public onlyAdmin returns(
        uint,
        uint[],
        bytes32[],
        address[],
        uint[],
        string[]
    ) {
        fetch_id = new uint[](0);
        getBet(i_id);
        bytes32[] memory ins_a = new bytes32[](fetch_id.length);
        uint[] memory id_a = new uint[](fetch_id.length);
        address[] memory wid_a = new address[](fetch_id.length);
        uint[] memory amt_a = new uint[](fetch_id.length);
        string[] memory sts_a = new string[](fetch_id.length);
        uint k = 0;
        for(uint _k = 0;_k < fetch_id.length;_k++){
            uint _id = fetch_id[_k];
            id_a[k] = betsRaised[_id].id;
            ins_a[k] = (betsRaised[_id].instance_id);
            wid_a[k] = betsRaised[_id].user_address;
            amt_a[k] = (betsRaised[_id].raisedBet);
            sts_a[k] = (betsRaised[_id].status);
            k++;
        }
        return(k,id_a,ins_a,wid_a,amt_a,sts_a);
    }
}