 // Paste this straight into VS Code as notes:
// THE MISSING PIECE DEPLOY
// SHARED CREATE3 faotries across all chains 
// then add to messenger and dpeloyer then u can deloy deterministic addresses acros chain 
// ```text
// AVENOR SAME-ADDRESS CROSS-CHAIN DEPLOYMENT
// ==========================================

// PROBLEM
// -------

// CREATE3 address depends on:

//     CREATE3 deployer address
//     +
//     salt

// Example:

// BASE:
//     CREATE3 deployer = 0xAAA
//     salt             = 123

//     deployed = 0x111

// ARBITRUM:
//     CREATE3 deployer = 0xBBB
//     salt             = 123

//     deployed = 0x222

// Even though:

//     salt == salt

// we have:

//     0xAAA != 0xBBB

// therefore:

//     0x111 != 0x222

// THIS IS WHAT MY OLD CODE DOES
// -----------------------------

// Base:

//     CREATE3FACTORY _factory = new CREATE3FACTORY();

// This could deploy:

//     0xAAA

// Arbitrum:

//     CREATE3FACTORY _factory = new CREATE3FACTORY();

// This could deploy:

//     0xBBB

// Then I use:

//     factory.deploy(salt, creationCode);

// on both chains.

// But the factories performing the CREATE3 are different.

// Therefore the resulting deterministic addresses are different.

// ==================================================
// FIX
// ==================================================

// I need ONE bootstrap deployer that exists at the SAME ADDRESS
// on every chain.

// Example:

// BASE:

//     universal deployer = 0x4e59...

// ARBITRUM:

//     universal deployer = 0x4e59...

// Then use the SAME:

//     universal deployer
//     salt
//     creationCode

// to deploy my CREATE3FACTORY.

// RESULT:

// BASE:

//     0x4e59...
//         |
//         | CREATE2
//         | salt = AVENOR_FACTORY_V1
//         |
//         v
//     CREATE3FACTORY = 0xABC

// ARBITRUM:

//     0x4e59...
//         |
//         | CREATE2
//         | same salt
//         |
//         v
//     CREATE3FACTORY = 0xABC

// NOW:

//     Base CREATE3 factory == Arbitrum CREATE3 factory

//     0xABC == 0xABC

// ==================================================
// THEN MY LAYERZERO SYSTEM STARTS
// ==================================================

// LayerZero does NOT need to bootstrap the first shared factory.

// The shared CREATE3 factory should already exist on both chains.

// BASE:

//     Test / Deployer
//         |
//         v

//     factory.factoryDeployed
//         =
//     0xABC

// ARBITRUM:

//     Create3FactoryMessenger
//         |
//         v

//     factory
//         =
//     0xABC

// Now Base can do:

//     0xABC.deploy(
//         salt,
//         creationCode
//     );

// Suppose result is:

//     0x777

// Base then sends through LayerZero:

//     salt
//     creationCode

// Arbitrum receives:

//     salt
//     creationCode

// Arbitrum does:

//     0xABC.deploy(
//         SAME salt,
//         SAME creationCode
//     );

// Result:

//     0x777

// Therefore:

//     BASE:
//         deterministic contract = 0x777

//     ARBITRUM:
//         deterministic contract = 0x777

// ==================================================
// IMPORTANT
// ==================================================

// The important equation is:

//     SAME CREATE3 DEPLOYER
//             +
//     SAME SALT
//             =
//     SAME CREATE3 ADDRESS

// NOT:

//     same creationCode
//         +
//     same salt
//         =
//     same address

// The CREATE3 deployer address matters.

// ==================================================
// MY OLD FLOW
// ==================================================

// BASE

//     new CREATE3FACTORY()
//             |
//             v
//          0xAAA
//             |
//             | CREATE3
//             v
//          0x111

// ARBITRUM

//     new CREATE3FACTORY()
//             |
//             v
//          0xBBB
//             |
//             | CREATE3
//             v
//          0x222

// BAD:

//     0xAAA != 0xBBB

// therefore:

//     0x111 != 0x222

// ==================================================
// NEW FLOW
// ==================================================

// BASE

//     Universal deterministic deployer
//             |
//             | CREATE2
//             v
//          0xABC
//     Shared CREATE3FACTORY
//             |
//             | CREATE3
//             v
//          0x777

// ARBITRUM

//     Universal deterministic deployer
//             |
//             | CREATE2
//             v
//          0xABC
//     Shared CREATE3FACTORY
//             |
//             | CREATE3
//             v
//          0x777

// GOOD:

//     CREATE3 factory:
//         Base = 0xABC
//         Arb  = 0xABC

//     final contract:
//         Base = 0x777
//         Arb  = 0x777

// ==================================================
// WHAT IF A NEW CHAIN DOES NOT HAVE THE UNIVERSAL
// DEPLOYER?
// ==================================================

// Example:

//     NEW CHAIN

//     cast code 0x4e59...

// returns:

//     0x

// Then the universal deployer does not exist there.

// I must bootstrap/install the deterministic deployment proxy
// on that chain first.

// After that:

//     NEW CHAIN:

//         0x4e59...
//             |
//             | same CREATE2 salt/code
//             v
//         0xABC

// Now Avenor can use:

//         0xABC

// as its CREATE3 factory on that chain too.

// ==================================================
// AVENOR CHAIN ONBOARDING
// ==================================================

// When adding a new chain:

// 1. Check universal deterministic deployer.

// 2. If missing:
//        bootstrap universal deployer.

// 3. Deploy Avenor CREATE3FACTORY using:
//        same deployer
//        same salt
//        same bytecode

// 4. Verify:
//        Avenor CREATE3FACTORY == expected address

// 5. Deploy Avenor LayerZero Messenger.

// 6. messenger.setFactory(
//        SHARED_CREATE3_FACTORY
//    );

// 7. Configure LayerZero peer.

// 8. Base/hub sends deployment instruction.

// 9. Remote messenger receives:
//        salt
//        creationCode

// 10. Remote shared CREATE3 factory deploys contract.

// 11. Resulting contract address matches every other chain.

// ==================================================
// ALSO FIX MY SALT
// ==================================================

// CURRENT:

//     keccak256(
//         abi.encodePacked(
//             msg.sender,
//             num
//         )
//     );

// Better:

//     keccak256(
//         abi.encodePacked(
//             "AVENOR_FACTORY",
//             num
//         )
//     );

// Reason:

//     msg.sender can change.

// For cross-chain deterministic deployments I want the salt
// to be explicitly identical and predictable.

// ==================================================
// FINAL ARCHITECTURE
// ==================================================

//              UNIVERSAL DEPLOYER
//                  0x4e59...
//                     |
//                     |
//           same salt + same bytecode
//                     |
//                     v

//              AVENOR CREATE3
//                  0xABC
//              SAME EVERYWHERE
//                     |
//                     |
//               CREATE3 salts
//                     |
//                     v

//                  VAULTS
//                  0x777
//              SAME EVERYWHERE

// LayerZero's job:

//     tell remote chains WHAT to deploy.

// CREATE3's job:

//     make the deployment deterministic.

// Universal CREATE2 deployer's job:

//     make Avenor's CREATE3 factory itself
//     have the same address on every chain.
// ```
