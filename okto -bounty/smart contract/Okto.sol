// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract Okto {
    struct CrowdFunding {
        string img;
        uint256 amount;
        string description;
        address victimAddress;
        uint256 amountReceieved;
    }

    mapping(address => CrowdFunding) public addressToVictim;

    event FundRaised(address indexed creator, string img, uint256 amount, string description, address victimAddress);
    event Donated(address indexed donor, address indexed victimAddress, uint256 amount);
    event DebugCrowdFunding(address indexed victimAddress, uint256 amountReceieved, uint256 amount);

    function raiseFund(string memory img, uint256 amount, string memory description, address victimAddress) external {
        CrowdFunding memory newCrowdFunding;

        newCrowdFunding.img = img;
        newCrowdFunding.amount = amount;
        newCrowdFunding.description = description;
        newCrowdFunding.victimAddress = victimAddress;
        newCrowdFunding.amountReceieved = 0;
        addressToVictim[msg.sender] = newCrowdFunding;

        emit FundRaised(msg.sender, img, amount, description, victimAddress);
    }

    function donate(address payable victimAddress, uint256 amount) external payable {
        require(amount > 0, "enter a valid amount");
        CrowdFunding storage victim = addressToVictim[victimAddress];
//
        emit DebugCrowdFunding(victimAddress, victim.amountReceieved, victim.amount);

        if (victim.amountReceieved >= victim.amount) {
            revert("sufficient amount reached!");
        } else {
            (bool success, ) = victimAddress.call{value: amount,gas: 30000}("");
            require(success, "Transfer failed");

            victim.amountReceieved += amount;
            emit Donated(msg.sender, victimAddress, amount);
        }
    }

    function getCrowdFundingDetails(address victimAddress) external view returns (string memory img, uint256 amount, string memory description, address victim, uint256 amountReceieved) {
        CrowdFunding storage cf = addressToVictim[victimAddress];
        return (cf.img, cf.amount, cf.description, cf.victimAddress, cf.amountReceieved);
    }
}