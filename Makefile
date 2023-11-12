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

ifeq ($(findstring --network polygon,$(ARGS)),--network polygon)
	NETWORK_ARGS := --rpc-url $(POLYGON_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(POLYGON_API_KEY) -vvvv
endif



deployCharacter: 
	@forge script script/DeployCharacterNft.s.sol:DeployCharacterNft $(NETWORK_ARGS) --legacy

deployRPC:
	@forge script script/DeployRPC.s.sol:DeployRPC $(NETWORK_ARGS) --legacy

mintCharacter:
	@forge script script/Interactions.s.sol:MintCharacter $(NETWORK_ARGS) --legacy

mintCharacter2Pol:
	@forge script script/Interactions.s.sol:MintCharacter --rpc-url $(POLYGON_RPC_URL) --private-key $(PRIVATE_KEY_2) --broadcast --verify --etherscan-api-key $(POLYGON_API_KEY) -vvvv --legacy
mintCharacter1Pol:
	@forge script script/Interactions.s.sol:MintCharacter --rpc-url $(POLYGON_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(POLYGON_API_KEY) -vvvv --legacy
mintCharacter2Sep:
	@forge script script/Interactions.s.sol:MintCharacter --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY_2) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
joinGameSep:
		cast send 0xa0a0cC0895e0d9DC74F4cD5Eb4497C7983f1d2B0 "joinGame(uint256, uint256)" 0 0 --value 0.01ether --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) 
joinGameSep2:
		cast send 0xa0a0cC0895e0d9DC74F4cD5Eb4497C7983f1d2B0 "joinGame(uint256, uint256)" 2 1 --value 0.01ether --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY_2) 		

joinGamePol:
		cast send 0xedDEFe3ab42cBE8B1d2a530eDfDfA0B9b3b1b3db "joinGame(uint256, uint256)" 0 0 --value 0.01ether --rpc-url $(POLYGON_RPC_URL) --private-key $(PRIVATE_KEY) --legacy
joinGamePol2:
		cast send 0xedDEFe3ab42cBE8B1d2a530eDfDfA0B9b3b1b3db "joinGame(uint256, uint256)" 2 1 --value 0.01ether --rpc-url $(POLYGON_RPC_URL) --private-key $(PRIVATE_KEY_2) --legacy 	

resetGame:
		cast send 0xf19e27cd8f1ff98BD66D258BD17BFD31A020dd5e "resetGameState()" --rpc-url $(POLYGON_RPC_URL) --private-key $(PRIVATE_KEY) --legacy 	
performUpkeep:
		cast send 0xf19e27cd8f1ff98BD66D258BD17BFD31A020dd5e "performUpkeep(bytes)" "0x" --rpc-url $(POLYGON_RPC_URL) --private-key $(PRIVATE_KEY) --legacy 	
checkUpkeep:
		cast send 0xf19e27cd8f1ff98BD66D258BD17BFD31A020dd5e "checkUpkeep(bytes)" "0x" --rpc-url $(POLYGON_RPC_URL) --private-key $(PRIVATE_KEY) --legacy 	

# performUpkeep: 
# 	@forge script script/Interactions.s.sol:PerformUpkeep $(NETWORK_ARGS)

# fulfillRandomWords:
# 	@forge script script/Interactions.s.sol:FulfillRandomWords $(NETWORK_ARGS)
# checkUpkeep: 
# 	@forge script script/Interactions.s.sol:CheckUpKeep $(NETWORK_ARGS)

# flipMoodNft:
# 	@forge script script/Interactions.s.sol:FlipMoodNft $(NETWORK_ARGS)

# RPC: 0xedDEFe3ab42cBE8B1d2a530eDfDfA0B9b3b1b3db
# CharacterNFT: 0x6f0e277F02989C9bc8a1d1118a5E1768c4919Ef5

