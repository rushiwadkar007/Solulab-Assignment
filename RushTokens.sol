// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";
import "./CrowdsaleRushTokens.sol";


contract RushTokens is IERC20, CrowdsaleRushTokens{
    
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    
    
     /*
     * NOTE: state variables - Use properly. They cost high gas fees.
     * @name = name of the token
     * @symbole = symbol of the token
     * @totalDecimals = Decimal digits.
     * @founder = msg.sender is the founder of the token.
     * @totalSuppply = Fixed TOken supply which is fixed from constructor.
     */
     
    string public name = "RUSH";
    string public tokenSymbol = "RSHT";
    uint8 public totalDecimals = 18;
    uint public override totalSupply;
    address public founder;
    uint256 public investerMinCap = 2000000000000000; //0.02 Ether
    uint256 public investerMaxCAp = 5000000000000000000000;
    
    
    
    enum CrowdsaleStage{PreSale, SeedSale, FinalSale}
    
    CrowdsaleStage public stage = CrowdsaleStage.PreSale;
    
    mapping(address=>uint) initialSupply;
    mapping(address => uint) public _balances;
    mapping(address => uint256) contributions;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    
    event TokenTransfer(address indexed from, address indexed to, uint256 value);
    event ApproveTokenTransfer(address indexed owner, address indexed spender, uint256 amount);
    
    constructor(uint256 _rate, address _wallet, ERC20 _token) CrowdsaleRushTokens(_rate, _wallet, _token){
        
        totalSupply = 10000000;
        founder = msg.sender;
        initialSupply[founder] = totalSupply;
    }
    
    modifier onlyOwner(address _owner){
        founder = _owner;
        _;
    }
    
    function getUserContributions(address _beneficiary) public view returns(uint256){
        return contributions[_beneficiary];
    }
    
    function setCrowdSaleStage(uint _stage) public onlyOwner(msg.sender){
        if(uint(CrowdsaleStage.PreSale) == _stage){
            stage = CrowdsaleStage.PreSale;
            
        }
        else if(uint(CrowdsaleStage.SeedSale) == _stage){
            stage = CrowdsaleStage.SeedSale;
            
        }
        else{
            stage = CrowdsaleStage.FinalSale;
            
        }
        if(stage == CrowdsaleStage.PreSale){
            rate = 500;
        }
        else if( stage == CrowdsaleStage.SeedSale){
            rate = 200;
        }
        else{
            rate;
        }
    }
    
    function _preValidatePurchasing(address _beneficiary, uint _weiAmount) internal{
        super._preValidatePurchase(_beneficiary, _weiAmount);
        uint256 _existingContribution = contributions[_beneficiary];
        uint256 _newContribution = _existingContribution.add(_weiAmount);
        require(_newContribution >= investerMinCap && _newContribution <= investerMinCap);
        contributions[_beneficiary] = _newContribution;
    }
    
    function balanceOf(address account) public view override returns (uint256){
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool){
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view  override returns (uint256){
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool){
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
        
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit ApproveTokenTransfer(owner, spender, amount);
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    
}