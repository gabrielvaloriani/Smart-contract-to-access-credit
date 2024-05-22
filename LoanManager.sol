// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./FinancialLibrary.sol";

contract LoanManager {

    // Structure to represent a loan
    struct Loan {
        address payable lender;
        address borrower;
        uint amount;
        uint interestRate;
        uint loanPeriod;
        uint startTime;
        uint endTime;
        bool isPaid;
        bool isActive;
    }

    // Map to track users' addresses and their loans
    mapping(address => Loan[]) public loans;

    // Function to create a new loan
    function createLoan(address _borrower, uint _amount, uint _interestRate, uint _loanPeriod) external {
        require(_amount > 0, "Loan amount must be greater than zero.");
        require(_loanPeriod > 0, "Loan period must be greater than zero.");
        
        uint startTime = block.timestamp;
        uint endTime = startTime + (_loanPeriod * 1 days);

        Loan memory newLoan = Loan(payable(msg.sender), _borrower, _amount, _interestRate, _loanPeriod, startTime, endTime, false, true);

        loans[_borrower].push(newLoan);
    }

    // Internal function to get the active loan of a user
    function _getActiveLoan(address _user) internal view returns (Loan storage) {
        require(hasActiveLoan(_user), "The loan for this user does not exist.");
        return loans[_user][loans[_user].length - 1];
    }

    // Function to get the interest rate of a loan
    function getInterestRate() external view returns (uint) {
        return _getActiveLoan(msg.sender).interestRate;
    }

    // Function to get the interest amount of a loan
    function getInterestAmount() external view returns (uint) {
        Loan storage userLoan = _getActiveLoan(msg.sender);
        return FinancialLibrary.calculateInterest(userLoan.amount, userLoan.interestRate, userLoan.loanPeriod);
    }

    // Function to get the end time of a loan
    function getLoanEndTime() external view returns (uint) {
        return _getActiveLoan(msg.sender).endTime;
    }

    // Function to get the status of a loan
    function getLoanStatus() external view returns (string memory) {
        Loan storage userLoan = _getActiveLoan(msg.sender);
        if (block.timestamp < userLoan.endTime && !userLoan.isPaid) {
            return "active";
        } else if (block.timestamp >= userLoan.endTime && !userLoan.isPaid) {
            return "expired";
        } else if (userLoan.isPaid) {
            return "paid";
        }
        return "undefined state";
    }

    // Function to allow users to repay a loan
    function repayLoan() external payable {
        Loan storage userLoan = _getActiveLoan(msg.sender);
        uint penalty = 0;
        if (block.timestamp > userLoan.endTime) {
            penalty = FinancialLibrary.calculatePenalty(userLoan.amount, userLoan.endTime, block.timestamp);
        }
        require(msg.value >= userLoan.amount + penalty, "The payment amount is not sufficient.");
        require(!userLoan.isPaid, "The loan has already been paid.");

        uint excessPayment = msg.value - (userLoan.amount + penalty);
        if (excessPayment > 0) {
            payable(msg.sender).transfer(excessPayment);
        }

        userLoan.lender.transfer(userLoan.amount + penalty);
        userLoan.isPaid = true;
    }

    // Function to cancel a loan
    function cancelLoan() external {
        Loan storage userLoan = _getActiveLoan(msg.sender);
        require(!userLoan.isPaid, "The loan has already been paid.");

        userLoan.isActive = false;
    }

    // Function to get loan information
    function getLoanDetails() external view returns (address, address, uint, uint, uint, uint, uint, bool, bool) {
        Loan storage userLoan = _getActiveLoan(msg.sender);
        return (
            userLoan.lender,
            userLoan.borrower,
            userLoan.amount,
            userLoan.interestRate,
            userLoan.loanPeriod,
            userLoan.startTime,
            userLoan.endTime,
            userLoan.isActive,
            userLoan.isPaid
        );
    }

    // Function to get the penalty amount for a late loan
    function getPenaltyAmount() external view returns (uint) {
        Loan storage userLoan = _getActiveLoan(msg.sender);
        require(block.timestamp > userLoan.endTime && !userLoan.isPaid, "The loan has not yet come due or been paid.");

        uint penalty = FinancialLibrary.calculatePenalty(userLoan.amount, userLoan.endTime, block.timestamp);
        return penalty;
    }

    // Function to check if the user has an active loan
    function hasActiveLoan(address _user) internal view returns (bool) {
        uint loanCount = loans[_user].length;
        if (loanCount == 0) {
            return false;
        }
        Loan storage userLoan = loans[_user][loanCount - 1];
        return userLoan.isActive;
    }
}
