// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3} from "solmate/utils/CREATE3.sol";

import {ICREATE3FACTORY} from "./ICREATE3FACTORY.sol";

//key takeaway account must be fresh nonce at 0 , nonce is the amount of transactions a wallet has 
/**
 * "COmpleted first test dpeloyment of Create3Factory we plan on launching a
 *  factory on all chains for our product. THepurpose of this factory
 *  isto allow or  determiistic addresses all across evm it makes thigns
 * simpler as we only have the same address for all vaults on all chains
 * in comparison to a regular dpeloyment all addresses are different as we
 *  add more chains on evm the list will grow insanely large and will cost more
 *  to execute transactions in vaults"
 */

/// @title Factory for deploying contracts to deterministic addresses via CREATE3
/// @author zefram.eth
/// @notice Enables deploying contracts using CREATE3. Each deployer (msg.sender) has
/// its own namespace for deployed addresses.
contract CREATE3FACTORY is ICREATE3FACTORY {
    // 1. deterministic salt helper
    function getSalt(
        //produces the ame salt everywhere
        string memory namespace,
        uint256 id
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(namespace, id));
    } //////

    //for deploying initial factorys universally:
    function deployUniversal(
        //call this on arbitrum and base to dpeloy the initial factory with the same address
        string memory namespace,
        uint256 id,
        bytes memory creationCode
    ) external returns (address deployed) {
        bytes32 salt = getSalt(namespace, id);

        deployed = deploy(salt, creationCode);
    } //
    function deploy(
        bytes32 salt,
        bytes memory creationCode
    ) public payable override returns (address deployed) {
        // hash salt with the deployer address to give each deployer its own namespace
        return CREATE3.deploy(salt, creationCode, msg.value);
    }

    function getDeployed(
        address deployer,
        bytes32 salt
    ) public view override returns (address deployed) {
        // hash salt with the deployer address to give each deployer its own namespace
        return CREATE3.getDeployed(salt);
    }
}



/*
final approach to problem 
============================================================
AVENOR UNIVERSAL CREATE3 FACTORY FLOW
============================================================

THE PROBLEM
-----------

Right now I am doing:

BASE:

    CREATE3FACTORY factory = new CREATE3FACTORY();

    Result:
        factory = 0xAAA


ARBITRUM:

    CREATE3FACTORY factory = new CREATE3FACTORY();

    Result:
        factory = 0xBBB


The addresses are different because normal `new` uses CREATE.

Then if I do:

BASE:

    0xAAA.deploy(SALT, creationCode)
        ↓
    contract = 0x111


ARBITRUM:

    0xBBB.deploy(SAME_SALT, creationCode)
        ↓
    contract = 0x222


Even though the salt is the same, the CREATE3 factories
have different addresses.

Therefore:

    0x111 != 0x222


============================================================
THE FIX
============================================================

I need to deploy CREATE3FACTORY itself through a deployer
that ALREADY has the same address on both chains.

For example:

    Universal Bootstrap Deployer:

    0x4e59b44847b379578588920cA78FbF26c0B4956C


This address must have code on BOTH chains.


============================================================
STEP 1 - CHECK BOOTSTRAP DEPLOYER
============================================================

BASE:

cast code \
0x4e59b44847b379578588920cA78FbF26c0B4956C \
--rpc-url wss://base-sepolia-rpc.publicnode.com


ARBITRUM:

cast code \
0x4e59b44847b379578588920cA78FbF26c0B4956C \
--rpc-url wss://arbitrum-sepolia-rpc.publicnode.com


Both should return bytecode.

NOT:

    0x


============================================================
STEP 2 - CHOOSE ONE PERMANENT SALT
============================================================

Example:

bytes32 salt =
    keccak256("AVENOR_CREATE3_FACTORY_V1");


IMPORTANT:

Use EXACTLY the same salt on every chain.


============================================================
STEP 3 - GET MY CREATE3FACTORY BYTECODE
============================================================

bytes memory creationCode =
    type(CREATE3FACTORY).creationCode;


This must also be EXACTLY the same on every chain.


============================================================
STEP 4 - DEPLOY THROUGH BOOTSTRAP
============================================================

DO NOT DO:

    CREATE3FACTORY factory =
        new CREATE3FACTORY();


INSTEAD DO:

address bootstrap =
    0x4e59b44847b379578588920cA78FbF26c0B4956C;


bytes32 salt =
    keccak256("AVENOR_CREATE3_FACTORY_V1");


bytes memory creationCode =
    type(CREATE3FACTORY).creationCode;


bytes memory data =
    abi.encodePacked(
        salt,
        creationCode
    );


(bool success,) =
    bootstrap.call(data);


require(
    success,
    "FACTORY_DEPLOY_FAILED"
);


============================================================
WHAT HAPPENS ON BASE
============================================================

Bootstrap:

    0x4e59...

Inputs:

    salt =
        keccak256("AVENOR_CREATE3_FACTORY_V1")

    creationCode =
        CREATE3FACTORY creationCode


Result:

    CREATE3FACTORY = 0xABC


============================================================
WHAT HAPPENS ON ARBITRUM
============================================================

Bootstrap:

    0x4e59...

SAME inputs:

    salt =
        keccak256("AVENOR_CREATE3_FACTORY_V1")

    creationCode =
        SAME CREATE3FACTORY creationCode


Result:

    CREATE3FACTORY = 0xABC


THEREFORE:

    Base CREATE3FACTORY:
        0xABC

    Arbitrum CREATE3FACTORY:
        0xABC


SAME ADDRESS.


============================================================
WHY THIS WORKS
============================================================

CREATE2 address depends on:

    bootstrap deployer address
            +
    salt
            +
    keccak256(creationCode)


BASE:

    bootstrap = 0x4e59
    salt      = X
    code      = Y

ARBITRUM:

    bootstrap = 0x4e59
    salt      = X
    code      = Y


Therefore:

    factory address = SAME


============================================================
STEP 5 - GIVE BASE CONTRACT THE FACTORY
============================================================

Once I know the resulting address:

    SHARED_FACTORY = 0xABC


Base:

deployer.setNativeFactory(
    ICREATE3FACTORY(
        SHARED_FACTORY
    )
);


============================================================
STEP 6 - GIVE ARBITRUM MESSENGER THE SAME FACTORY
============================================================

Arbitrum:

messenger.setFactory(
    ICREATE3FACTORY(
        SHARED_FACTORY
    )
);


Now:

    Base deployer factory
        =
    0xABC


    Arbitrum messenger factory
        =
    0xABC


============================================================
STEP 7 - NOW MY LAYERZERO FLOW WORKS
============================================================

BASE:

    bytes32 vaultSalt =
        keccak256("AVENOR_VAULT_1");


    address deployed =
        factory.deploy(
            vaultSalt,
            vaultCreationCode
        );


Suppose:

    deployed = 0x777


Then LayerZero sends:

    vaultSalt
    vaultCreationCode


============================================================
ARBITRUM RECEIVES MESSAGE
============================================================

Messenger receives:

    vaultSalt
    vaultCreationCode


Then:

    address deployed =
        factory.deploy(
            vaultSalt,
            vaultCreationCode
        );


Remember:

    factory = 0xABC


So:

BASE:

    0xABC
      +
    vaultSalt
      ↓

    0x777


ARBITRUM:

    0xABC
      +
    SAME vaultSalt
      ↓

    0x777


============================================================
FINAL ARCHITECTURE
============================================================


                    BASE
                     |
                     |
              Bootstrap 0x4e59
                     |
                     | CREATE2
                     |
                     v
             CREATE3FACTORY
                  0xABC
                     |
                     | CREATE3
                     |
                     v
                  Vault
                  0x777



                 ARBITRUM
                     |
                     |
              Bootstrap 0x4e59
                     |
                     | CREATE2
                     |
                     v
             CREATE3FACTORY
                  0xABC
                     |
                     | CREATE3
                     |
                     v
                  Vault
                  0x777


============================================================
ROLE OF EACH PART
============================================================

BOOTSTRAP DEPLOYER:

    Makes CREATE3FACTORY itself have the
    same address across chains.


CREATE3FACTORY:

    Makes Avenor contracts/vaults have
    the same address across chains.


LAYERZERO:

    Sends the deployment instruction:

        salt
        creationCode

    from the hub chain to remote chains.


MESSENGER:

    Receives LayerZero message and calls:

        factory.deploy(
            salt,
            creationCode
        );


============================================================
MOST IMPORTANT RULE
============================================================

DO NOT:

    Base:
        new CREATE3FACTORY()

    Arbitrum:
        new CREATE3FACTORY()


DO:

    Base:
        SAME_BOOTSTRAP
            ↓
        CREATE3FACTORY 0xABC


    Arbitrum:
        SAME_BOOTSTRAP
            ↓
        CREATE3FACTORY 0xABC


THEN:

    SAME CREATE3 FACTORY
            +
    SAME SALT
            =
    SAME CONTRACT ADDRESS


============================================================
CHAIN ONBOARDING
============================================================

Every time Avenor supports a new chain:

    1. Check if bootstrap deployer exists.

    2. If it exists:

        use it.

    3. Deploy Avenor CREATE3FACTORY with:

        SAME bootstrap
        SAME salt
        SAME creationCode

    4. Verify CREATE3FACTORY address
       equals expected Avenor factory address.

    5. Deploy LayerZero messenger.

    6. messenger.setFactory(
           SHARED_CREATE3_FACTORY
       );

    7. Configure LayerZero peers.

    8. Chain is ready.

    9. Future vault deployments can be
       controlled cross-chain through LayerZero.


============================================================
SHORT VERSION
============================================================

0x4e59 SAME BOOTSTRAP
        ↓
same salt + same factory bytecode
        ↓
0xABC SAME CREATE3FACTORY
        ↓
same vault salt
        ↓
0x777 SAME VAULT


The bootstrap solves the factory address problem.

CREATE3 solves the vault address problem.

LayerZero coordinates everything cross-chain.
============================================================
*/
```
