import { ethers } from "ethers";
import * as Artifacts from "../build/contracts/Recruitment.json";

/**
 * @title Recruitment 
 * @author Edicha Joshua <mredichaj@gmail.com>
 * @description Connect with smart contract and interact with it
 */
class Recruitment {
    contractAddr = "0xcEC7c3CE6Fe7B176Cd6265b7F63114188294Dd9a";
    provider : ethers.providers.InfuraProvider;
    signer : ethers.Signer;
    contract : ethers.Contract;
    acct : string;

    /**
     * @constructor initialize provider with provided apiKey for Infura service
     */
    constructor(apiKey : string = "7cf4afd92a7d411986ec7b5f32182e31") {
        this.provider = new ethers.providers.InfuraProvider("goerli", apiKey);
    }

    /**
     * @description initialize signer and contract
     */
    async init() {
        if(!this.acct) {
            let accts = await this.provider.listAccounts();
            console.log(accts);

            this.acct = accts[0];

            this.signer = this.provider.getSigner(this.acct); // get signer

            this.contract = new ethers.Contract(this.contractAddr, Artifacts.abi, this.signer); // initialize contract

            console.log("Initialized contract: ", await this.contract.resolvedAddress);

        }
    }
}