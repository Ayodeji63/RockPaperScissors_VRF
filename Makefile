-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
DEFAULT_ANVIL_KEY_2 := 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install Cyfrin/foundry-devops@0.0.11 --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit && forge install openzeppelin/openzeppelin-contracts@v4.8.3 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network anvil,$(ARGS)),--network anvil)
	NETWORK_ARGS := --rpc-url $(ANVIL_RPC_URL) --private-key $(DEFAULT_ANVIL_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif



deployCharacter: 
	@forge script script/DeployCharacterNft.s.sol:DeployCharacterNft $(NETWORK_ARGS)

deployRPC:
	@forge script script/DeployRPC.s.sol:DeployRPC $(NETWORK_ARGS)

mintCharacter:
	@forge script script/Interactions.s.sol:MintCharacter ${NETWORK_ARGS}

mintCharacter2:
	@forge script script/Interactions.s.sol:MintCharacter --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY_2) --broadcast
mintCharacter2Sep:
	@forge script script/Interactions.s.sol:MintCharacter --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY_2) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
joinGameSep:
		cast send 0x5f62f6BC74EeC53a828490bE1c1b14EE0634C85d "joinGame(uint256, uint256)" 0 0 --value 0.01ether --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) 
joinGameSep2:
		cast send 0x5f62f6BC74EeC53a828490bE1c1b14EE0634C85d "joinGame(uint256, uint256)" 2 1 --value 0.01ether --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY_2) 		
joinGame:
	cast send 0x68B1D87F95878fE05B998F19b66F4baba5De1aed "joinGame(uint256, uint256)" 0 0 --value 0.01ether --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) 

joinGame2:
	cast send 0x68B1D87F95878fE05B998F19b66F4baba5De1aed "joinGame(uint256, uint256)" 0 1 --value 0.01ether --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY_2) 

mintMoodWithCast:
	cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "mintNft()" --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) 
 
flipMoodNftWithCast:
	cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "flipMood(uint256)" 0 --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) 

performUpkeep: 
	@forge script script/Interactions.s.sol:PerformUpkeep $(NETWORK_ARGS)

fulfillRandomWords:
	@forge script script/Interactions.s.sol:FulfillRandomWords $(NETWORK_ARGS)
checkUpkeep: 
	@forge script script/Interactions.s.sol:CheckUpKeep $(NETWORK_ARGS)

flipMoodNft:
	@forge script script/Interactions.s.sol:FlipMoodNft $(NETWORK_ARGS)

# RPC: 0x5f62f6BC74EeC53a828490bE1c1b14EE0634C85d
# CharacterNFT: 0x5f62f6BC74EeC53a828490bE1c1b14EE0634C85d

