

**Smart Contract Design Guidelines:**

1. **Contract Initialization:**
   - Define the necessary initial parameters, such as Chainlink VRF configuration, game state, and NFT settings.
   
2. **Data Structures:**
   - Define structures for storing game data, including player choices, game results, and dynamic NFT attributes.
   
3. **Chainlink VRF Integration:**
   - Import the Chainlink VRF contract and set up the necessary configuration, including the VRF contract address, keyHash, and fee.

4. **Game State Management:**
   - Create state variables to manage the game's state, such as the current game ID, player addresses, and the game result.

5. **Game Entry:**
   - Allow players to enter the game by submitting their choice (Rock, Paper, or Scissors) and the required fee.

6. **Random Outcome Request:**
   - After both players have entered the game, initiate a Chainlink VRF request to obtain a random number.

7. **Random Outcome Mapping:**
   - Define a mapping that translates the random number into a game outcome. For example:
     - If randomNumber < 0.33, the outcome is Rock.
     - If 0.33 <= randomNumber < 0.66, the outcome is Paper.
     - If 0.66 <= randomNumber, the outcome is Scissors.

8. **Game Outcome Determination:**
   - Use the mapped random outcome to determine the winner based on the player choices.

9. **NFT Minting:**
   - Mint dynamic NFTs for the winning player, incorporating the outcome into the NFT's attributes (e.g., visual representation of the choice).

10. **Game Result Update:**
    - Update the game state with the result, including the winner and the associated NFT ID.

**Computation Flow:**

1. Players A and B join the game by submitting their choices and the required fees.

2. The smart contract initiates a Chainlink VRF request to obtain a random number.

3. Chainlink VRF responds with a random number.

4. The smart contract maps the random number to a game outcome (Rock, Paper, or Scissors).

5. The smart contract determines the winner based on the mapped outcome and the player choices.

6. The winning player is awarded a dynamic NFT representing the game outcome.

7. The game state is updated with the result, including the winner and NFT ID.

8. Players can query the game's outcome and collect their NFTs.

This guideline outlines the key components of the smart contract and the sequence of actions that occur when players participate in the game. It introduces randomness through Chainlink VRF while ensuring transparency and fairness in the game's outcome. Players can collect dynamic NFTs as a reward for winning.

**install**
> forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit