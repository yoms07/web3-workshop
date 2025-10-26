# Introduction to Web3 Development

Welcome! This repository accompanies the "Introduction to Web3 Development" workshop. It’s a minimal, end‑to‑end project that takes you from a Solidity smart contract to a React frontend that interacts with it through a wallet. The goal is to give you a friendly, practical starting point for building on Ethereum and compatible networks.

## What You’ll Learn
- How a simple smart contract is written in Solidity and tested.
- How Hardhat compiles, tests, and deploys contracts locally or to a testnet.
- How to call contract functions from scripts and from a web app.
- How to connect a wallet (MetaMask) to read state and send transactions.
- How token‑style flows (e.g., mint and burn) work conceptually.

## Repository Structure
- `hardhat/` — Smart contract development workspace.
  - Contains Solidity contracts, TypeScript tests, configuration, and a deployment module (Ignition). Start here to write, test, and deploy contracts.
- `frontend/` — React app that talks to your deployed contract.
  - Uses Wagmi and Viem for wallet connections and contract interactions. Start here to build UI, read contract state, and trigger transactions from the browser.

## Technologies Used
- **Solidity** — Language for writing smart contracts.
- **Hardhat** — Developer tooling for compile, test, and deployment.
- **Hardhat Ignition** — Structured deployment modules to manage contract deployment.
- **React** — UI framework for building the frontend.
- **Wagmi + Viem** — Libraries for wallet connections and typed contract calls.
- **MetaMask** — Browser wallet used to sign transactions.

## Typical Flow
- **Write & deploy the contract with Hardhat**: Implement a simple contract, run tests, and deploy to a local network or testnet.
- **Interact via script and frontend**: Call functions from a script (for quick checks), then wire the same calls into the React UI to read/write contract state.
- **Connect wallet to mint/burn tokens**: Use MetaMask to connect, approve transactions, and perform token‑like actions (mint/burn) or similar state‑changing operations.

## Explore and Modify
This project is meant to be tinkered with:
- Swap the sample contract for your own (ERC‑20/721 or a custom idea).
- Add new functions, events, or tests and redeploy.
- Extend the UI to display more state, handle errors, and show transaction status.
- Try different networks, experiment with gas, and observe how transactions confirm.

Use this repo as your sandbox. Break things, learn why, and build something you’re proud of. Enjoy exploring Web3!
