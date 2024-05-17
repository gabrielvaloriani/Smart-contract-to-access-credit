# Smart-contract-to-access-credit

---

### Table of Contents

- [Description](#description)
- [How To Use](#how-to-use)
- [Technical Choices](#technical-choice)
- [API Reference](#api-reference)
- [Author Info](#author-info)

---

## Description

This smart contract was developed for a startup aiming to create a peer-to-peer lending platform, facilitating access to credit without the need for traditional financial intermediaries. The LoanManager contract, implemented in Solidity, serves as the backbone of the lending platform, offering various features to manage loans between users.

### Key Features:

- **User Address and Loan Tracking:** The contract tracks the addresses of users participating in loans and records the associated loan details, including amounts, interest rates, loan periods, start and end dates, and loan statuses.

- **Interest Rate Display:** Users can access the interest rates applied to their loans, providing transparency and clarity regarding borrowing costs.

- **Loan Management:** Users can create, view, and manage loans, including initiating new loans, repaying existing loans, and cancelling active loans.

- **Loan Status Monitoring:** The contract enables users to monitor the status of their loans, distinguishing between active, expired, and paid-off loans.

- **Penalty Management:** In case of late loan repayments, the contract calculates and applies penalties, ensuring fair and transparent consequences for missed deadlines.

- **Gas Optimization:** The contract code is optimized for gas efficiency, utilizing efficient data structures and algorithms to minimize transaction costs for users.

- **Security Measures:** Security checks are implemented throughout the contract to authenticate user actions and protect against unauthorized access or misuse of loan functionalities.

## How To Use

To test the project locally:

- Clone the repository to your local machine.
- Open the project in Remix or your preferred Solidity development environment.
- Compile and deploy the LoanManager contract to an Ethereum test network.
- Interact with the contract using Remix's interface or through custom scripts, testing various loan functionalities such as creating, repaying, and cancelling loans.

For detailed instructions on deploying and interacting with the contract, refer to the project documentation or consult with the developer.

## Technical Choice

Solidity Development
The LoanManager contract was implemented using the Solidity programming language, which is compatible with the Ethereum development environment.
Solidity was chosen for its ability to create smart contracts on the Ethereum blockchain, enabling secure and transparent management of loans among users.

Gas Optimization
During the development of the contract, particular attention was paid to optimizing gas costs for transactions. Efficient data structures such as mappings were used to manage user loans in order to minimize transaction execution costs on the blockchain.

Security Measure
To ensure loan security and protect users from unauthorized access or improper use of loan features, security checks were implemented throughout the contract.
These checks verify the authenticity of user actions and protect against potential vulnerabilities or cyber attacks.

Network Deployment
The LoanManager contract was tested and deployed on an Ethereum test network, such as the Goerli or Ropsten network.
The contract address published on this network can be found in the README.md file of the repository.

Deployed Contract Address
The address of the LoanManager contract published on an Ethereum test network is 0x3bfca3b3a91859781d427127dc665265a3443d6e. Users can interact with the contract using this address to access the loan functionalities offered by the platform.

### API Reference

```solidity
// Example function to retrieve the interest rate of a loan
function getInterestRate() external view returns (uint) {
    require(hasActiveLoan(msg.sender), "The loan for this user does not exist.");
    return loans[msg.sender][loans[msg.sender].length - 1].interestRate;
}
```

## Author info:

Connect with me on social media:

Twitter - @GabrielValorianiFranco

Linkedin - GabrielValorianiFranco
