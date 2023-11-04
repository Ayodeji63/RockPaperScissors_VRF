.include: .env







runTestOnTestnet: 
	@forge test --fork-url $SEPOLIA_RPC_URL 