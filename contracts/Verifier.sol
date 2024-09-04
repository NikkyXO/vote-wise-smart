// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x15cd1a2013b0ec065b8c5e4bd4944e8891fbd4479aaceea93fb2c46e92b426d5), uint256(0x1ca30177e79603543a0e44fa1184e216b815df87f2aab6bf2a233befd4092dd9));
        vk.beta = Pairing.G2Point([uint256(0x2003706b41ab9a64eff7019b2428fc9c715dfdbcdcf5fb0bda2b626a3951ca1f), uint256(0x131a92936c7cab4f39f831289e1babeb48693d747a8210f92000a139b1635084)], [uint256(0x208cd8ac670ffcb390413b064f9934cc37659b00570209e84aea2d96b0b66745), uint256(0x1c4cf2f441bac7fe061755f999d1699a02881c04638d1bbf898d9244db56499d)]);
        vk.gamma = Pairing.G2Point([uint256(0x0c771d0aa5f68cea8784adcdc15274a25411835f731da3f7a1471799cb90a23f), uint256(0x13a2112b81218c3ea174c7dcfcaaa66afdaa77e04214cb4714bd74b8998d6898)], [uint256(0x19d04869de9b014869abb9a4ddacc8b92f03344ddd51a49cd2ebf19857676ec2), uint256(0x0fab1dbac7f5d0caf4f59f930d3d395b688b1ff3f8affb21096cf8fbf41419d1)]);
        vk.delta = Pairing.G2Point([uint256(0x299721dc4a868d279999740dfdc990a52e157233515af3b797373642bff1f460), uint256(0x0e2e0ca9f45c472d7a1746557645eb77b8093fa7fc159650d2b952982ad8291d)], [uint256(0x07fd243a9ce450f0f4609c036ee79ddc536140ed76573ae197264f379aeb9ad7), uint256(0x28b0e752717361414dce9dce133d50a4169e013be3408d948760b0085aff0793)]);
        vk.gamma_abc = new Pairing.G1Point[](7);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1cc08e08bd7a0a1b40495db9aac1d787aff1d0182c6c8c0678bcc5eeebdcdc64), uint256(0x1121c9800a4da5a17ec4b304101bc3973b8c293d1f31cf59b752926295334e9d));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x10430b0234cfe0cc00427e9eb253ee19fdb92b5d2bf900bb8bbfa6cc6b2ed7dc), uint256(0x2e15b6111bb679598adde0f7c4ad623b7d820a65db507034bd7b21c743425649));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x19d928e65f9218a6b3bf9a255a88a5fbc921c40597723126a43fa16b38e72cd5), uint256(0x1bb42e8ca087f9766a6d7d5f504829b172422711a1961385341f464772b9d844));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x152bf2e76327f9875708699d5b9336bafb237bf58a1729817c79788059cc0568), uint256(0x225a9fba2c5214de10bc9a0c167e48b926acde6d5b96696fc77443024886ac98));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x20bdee67a83870d180108071ca3768191b2b64bd3bafc852d883adda0662524c), uint256(0x2c9e9de6c762e9f49dff458c0f4766611b258c25723b9d0a3b3d109e88a78173));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x11e0e0a45ae930685ae3584779201b0b1a63f4b443a88c57e81684feb0e12322), uint256(0x2103eb8e265ec7ea64f0e168db5a924d932389d2d726072546797c363b02efb8));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x139ba62755b4d57950475c44183cb397aeafd8a07d730d67601a768cc7f07e6e), uint256(0x0d5d1e00d002345a5a86a6aa05dc7b5c9bd6ba535f2f17aebe29d24b19754216));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[6] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](6);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
