import * as fs from 'fs/promises';

initialize().then(async (zokratesProvider) => {
    const source = await fs.readFile("./eligibility.zok", "utf8");
  
    // compilation
    const artifacts = zokratesProvider.compile(source);
    console.log({ artifacts });
  
    // computation
    const { witness, output } = zokratesProvider.computeWitness(artifacts, ["2"]);
    console.log({ witness, output });
  
    // run setup
    const keypair = zokratesProvider.setup(artifacts.program);
    console.log({ keypair });
  
    // generate proof
    const proof = zokratesProvider.generateProof(
      artifacts.program,
      witness,
      keypair.pk
    );
    console.log({ proof });
  
    // export solidity verifier
    const verifier = zokratesProvider.exportSolidityVerifier(keypair.vk);
  
    // or verify off-chain
    const isVerified = zokratesProvider.verify(keypair.vk, proof);
  });