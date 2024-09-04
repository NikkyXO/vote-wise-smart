import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const voteModule = buildModule("Vote3Module", (m) => {

    const vote = m.contract("Vote");

    return { vote };
});

export default voteModule;
