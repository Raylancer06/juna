// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract JunaTokenSale is Ownable {
    using SafeERC20 for IERC20;

    // ERC-20 token being sold
    IERC20 public token;

    // Address where funds are collected
    address public wallet;

    // Listing fee in ETH
    uint256 public listingFee;

    // Mapping to track whether a vendor accepts a specific payment method
    mapping(address => mapping(string => bool)) public acceptedPaymentMethods;

    // Event triggered when a new token is listed for sale
    event TokenListed(address indexed vendor, uint256 listingPrice, string paymentMethod);

    // Event triggered when someone purchases tokens
    event TokenPurchased(address indexed buyer, uint256 amount, string paymentMethod);

    constructor(
        address _token,
        address _wallet,
        uint256 _listingFee
    ) {
        token = IERC20(_token);
        wallet = _wallet;
        listingFee = _listingFee;
    }

    // Function to list a new ERC-20 token for sale
    function listTokenForSale(uint256 _listingPrice, string memory _paymentMethod) external onlyOwner {
        require(_listingPrice >= listingFee, "Listing price must be greater than or equal to the listing fee");

        acceptedPaymentMethods[msg.sender][_paymentMethod] = true;

        emit TokenListed(msg.sender, _listingPrice, _paymentMethod);
    }

    // Function to purchase tokens
    function purchaseTokens(uint256 _amount, string memory _paymentMethod) external {
        require(acceptedPaymentMethods[msg.sender][_paymentMethod], "Invalid payment method");
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");

        // Perform the token transfer
        token.safeTransferFrom(msg.sender, wallet, _amount);

        emit TokenPurchased(msg.sender, _amount, _paymentMethod);
    }

    // Function to update the listing fee
    function setListingFee(uint256 _newListingFee) external onlyOwner {
        listingFee = _newListingFee;
    }
}
