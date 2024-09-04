import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const VOTEADRESS = "0x0C20E45A25D7D1BB64586bE21EAe645069999835";
const votefactoryModule = buildModule("VotingFactory3Module", (m) => {

    const votingFactory = m.contract("VotingFactory", [VOTEADRESS]);

    return { votingFactory };
});

export default votefactoryModule;

// Successfully verified contract "contracts/VoteFactory.sol:VotingFactory" for network lisk-sepolia:
//   - https://sepolia-blockscout.lisk.com//address/0x284049B3Dd6e4d5f9a159F1c0816e6A5D4C78E9d#code
