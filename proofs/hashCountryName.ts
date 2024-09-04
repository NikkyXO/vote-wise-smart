// const keccak256 = require('keccak');
import { keccak256 } from "web3-utils";
import { MODULUS, PRIME_MODULUS } from "./constant";

// Prime modulus for ZoKrates field (2^254 - 127)



export function hashCountryName(countryName: string):  bigint {
    // Hash the string 
    const hash = keccak256(countryName);
    console.log(`Original hash of '${countryName}': ${hash}`);
    
    // Convert the hash to a BigInt
    const sanitizedHash = hash.startsWith('0x') ? hash : `0x${hash}`;
  
  // Convert the hash to a BigInt
  const hashBigInt = BigInt(hash);
  
    
    // Reduce the hash modulo the prime field size
    // const reducedHash = hashBigInt % 18446744073709551615n;
    const reducedHash = hashBigInt % 18446744073709551615n
    console.log({ reducedHash });
    return reducedHash;
}

hashCountryName('Nigerian');

// Original hash of 'Nigerian': 0x97b7ce94075626ed89e4a8a9fb7835587d9d33f05a2d26f9f0e17c6d3e97b22f
// { reducedHash: 10383936915116340591n }
