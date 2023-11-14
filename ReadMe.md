# Rock-Paper-Scissors Game and CharacterNFT

## About

Welcome to the Rock-Paper-Scissors (RPC) Game and CharacterNFT projects! This repository hosts a decentralized version of the classic Rock-Paper-Scissors game, enhanced with Chainlink's Verifiable Random Function (VRF) for unpredictability and fairness. Additionally, the CharacterNFT system introduces a unique concept of gaming characters represented as NFTs, each evolving based on players' achievements in the RPC game.

## Getting Started

### Requirements

Make sure you have the following tools installed:

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [foundry](https://getfoundry.sh/)

### Quickstart

Clone the repository and build the project:

```bash
git clone https://github.com/Ayodeji63/RockPaperScissors_VRF.git
forge build
```

### Updates

Stay updated with the latest changes:

- For openzeppelin-contracts, install version 4.8.3 using:

```bash
forge install openzeppelin/openzeppelin-contracts@v4.8.3 --no-commit
```

### Usage

#### Start a Local Node

```bash
make anvil
```

#### Deploy to Polygon (customize for other networks)

```bash
make deployRPC ARGS="--network polygon"
```

### Testing

Explore the four test tiers:

1. Unit
2. Integration
3. Forked
4. Staging

Run the tests:

```bash
forge test
```

#### Test Coverage

```bash
forge coverage
```

### Deployment to Testnet or Mainnet

1. Set up environment variables in a `.env` file:

```bash
PRIVATE_KEY=
SEPOLIA_RPC_URL=
OWNER_ADDRESS=
ETHERSCAN_API_KEY=
PRIVATE_KEY_2=
POLYGON_RPC_URL=
POLYGON_API_KEY=
```

2. Get testnet ETH from [faucets.chain.link](https://faucets.chain.link/).

3. Deploy to Polygon:

```bash
make deploy ARGS="--network polygon"
```

#### Mint Characters and Join the Game

Use the provided commands in the make file:

- Mint Character for Player 1:

```bash
make mintCharacter1Pol
```

- Mint Character for Player 2:

```bash
make mintCharacter2Pol
```
- Note: Before running joinGamePol, ensure you've updated the RPC address in the make file, you see this while deploying the RPC or check the `broadcast` folder. This ensures that users are joining the game with the most recent RPC contract address.

- Player 1 Joins the Game:

```bash
make joinGamePol
```

- Player 2 Joins the Game:

```bash
make joinGamePol2
```

### Estimate Gas

Estimate gas costs:

```bash
forge snapshot
```

### Formatting

Run code formatting:

```bash
forge fmt
```

### Slither

Check for vulnerabilities:

```bash
slither :; slither . --config-file slither.config.json
```

## Connect with Us

Feel free to connect with the project creator and follow their blockchain adventures:

[![Olusanya Ayodeji Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/Ayodeji7111)
[![Olusanya Ayodeji YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/channel/UCZcXA_0j_0zeo-4bKZCHOZQ)
[![Olusanya Ayodeji Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/olusanya-ayodeji-3284ba241/)

Thank you for exploring the exciting world of blockchain gaming and decentralized finance with us! If you have any questions or suggestions, don't hesitate to reach out. Happy coding and gaming! 🚀🎮