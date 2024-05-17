// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

library FinancialLibrary {
    function calculatePenalty(uint _amount, uint _endTime, uint _paymentTime) external pure returns (uint) {
        if (_paymentTime > _endTime) {
            uint overdueDays = (_paymentTime - _endTime) / (1 days);
            uint penaltyRate = 1; 
            return (_amount * penaltyRate * overdueDays) / 100;
        } else {
            return 0;
        }
    }

    function calculateInterest(uint _amount, uint _interestRate, uint _loanPeriod) external pure returns (uint) {
        return (_amount * _interestRate * _loanPeriod) / 100;
    }
}
