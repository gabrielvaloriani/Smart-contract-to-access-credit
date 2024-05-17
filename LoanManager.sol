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
        uint startTime = block.timestamp;
        uint endTime = startTime + (_loanPeriod * 1 days);

        Loan memory newLoan = Loan(payable(msg.sender), _borrower, _amount, _interestRate, _loanPeriod, startTime, endTime, false, true);

        loans[_borrower].push(newLoan);
    }

    // Function to get the interest rate of a loan
    function getInterestRate() external view returns (uint) {
        require(hasActiveLoan(msg.sender), "The loan for this user does not exist.");
        return loans[msg.sender][loans[msg.sender].length - 1].interestRate;
    }

    // Function to get the interest amount of a loan
    function getInterestAmount() external view returns (uint) {
        require(hasActiveLoan(msg.sender), "The loan for this user does not exist.");
        Loan storage userLoan = loans[msg.sender][loans[msg.sender].length - 1];
        return FinancialLibrary.calculateInterest(userLoan.amount, userLoan.interestRate, userLoan.loanPeriod);
    }

    // Function to get the end time of a loan
    function getLoanEndTime() external view returns (uint) {
        require(hasActiveLoan(msg.sender), "The loan for this user does not exist.");
        return loans[msg.sender][loans[msg.sender].length - 1].endTime;
    }

    // Function to get the status of a loan
    function getLoanStatus() external view returns (string memory) {
        require(hasActiveLoan(msg.sender), "The loan for this user does not exist.");
        Loan storage userLoan = loans[msg.sender][loans[msg.sender].length - 1];
        if (userLoan.isActive) {
            if (block.timestamp < userLoan.endTime && !userLoan.isPaid) {
                return "active";
            } else if (block.timestamp >= userLoan.endTime && !userLoan.isPaid) {
                return "expired";
            } else if (userLoan.isPaid) {
                return "paid";
            }
        }
        return "undefined state";
    }

    // Function to allow users to repay a loan
    function repayLoan() external payable {
        require(hasActiveLoan(msg.sender), "The loan for this user does not exist.");
        Loan storage userLoan = loans[msg.sender][loans[msg.sender].length - 1];
        uint penalty = 0;
        if (block.timestamp > userLoan.endTime) {
            penalty = FinancialLibrary.calculatePenalty(userLoan.amount, userLoan.endTime, block.timestamp);
        }
        require(msg.value >= userLoan.amount + penalty, "The payment amount is not sufficient.");
        require(!userLoan.isPaid, "The loan has already been paid.");

        userLoan.lender.transfer(msg.value);
        userLoan.isPaid = true;
    }

    // Function to cancel a loan
    function cancelLoan() external {
        require(hasActiveLoan(msg.sender), "The loan for this user does not exist.");
        Loan storage userLoan = loans[msg.sender][loans[msg.sender].length - 1];
        require(!userLoan.isPaid, "The loan has already been paid.");

        userLoan.isActive = false;
    }

    // Function to get loan information
    function getLoanDetails() external view returns (address, address, uint, uint, uint, uint, uint, bool, bool) {
        require(hasActiveLoan(msg.sender), "The loan for this user does not exist.");
        Loan storage userLoan = loans[msg.sender][loans[msg.sender].length - 1];
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
        require(hasActiveLoan(msg.sender), "The loan for this user does not exist.");
        Loan storage userLoan = loans[msg.sender][loans[msg.sender].length - 1];
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
