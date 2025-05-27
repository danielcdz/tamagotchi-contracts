// Imports
use tamagotchi::interfaces::vrf::{IVrfProviderDispatcher, IVrfProviderDispatcherTrait};
use starknet::{ContractAddress, get_block_timestamp, get_caller_address, contract_address_const};
use core::poseidon::poseidon_hash_span;
use tamagotchi::interfaces::vrf::Source;

// VRF provider address 
const VRF_PROVIDER_ADDRESS: felt252 = 0x051fea4450da9d6aee758bdeba88b2f665bcbf549d2c61421aa724e9ac0ced8f;

#[derive(Copy, Drop, Serde)]
pub struct Random {
    pub seed: felt252,
    pub nonce: usize,
}

// Implementation of VRF Trait
#[generate_trait]
pub impl RandomVRF of RandomTrait {
    fn new_vrf() -> Random {
        let player_address: ContractAddress = get_caller_address();
        let vrf_provider = IVrfProviderDispatcher {  contract_address: contract_address_const::<VRF_PROVIDER_ADDRESS>() };
        let seed: felt252 = vrf_provider.consume_random(Source::Nonce(player_address));
  
        Random { seed, nonce: 0 }
    }

    /// Generate a random seed using the VRF provider and caller address.
    ///
    /// Uses the VRF provider to consume randomness based on the caller's address.
    ///
    /// Returns:
    ///     u256
    ///         A random seed value to be used in further randomness generation.
    fn seed(ref self: Random) -> u256 {
        let player_address: ContractAddress = get_caller_address();
        let vrf_provider = IVrfProviderDispatcher {  contract_address: contract_address_const::<VRF_PROVIDER_ADDRESS>() };
        let random_value: felt252 = vrf_provider.consume_random(Source::Nonce(player_address));
        return random_value.into();
    }

    /// Generate a random value within a specified max_value.
    ///
    /// Args:
    ///     seed: u256
    ///         random seed
    ///     salt: u128
    ///         to update the seed
    ///     max_value: u8
    ///         The max_value of possible values
    ///         i.e output will be from 0 to max_value - 1.
    ///
    /// Returns:
    ///     u8
    ///         A random value within the specified max_value.
    fn get_random_u8(ref self: Random, max_value: u8) -> u8 {
        let seed = self.seed();
        let salt = get_block_timestamp();
        let value: u256 = poseidon_hash_span(array![seed.low.into(), seed.high.into(), salt.into()].span()).into();
        let max_value: u256 = max_value.into();
        return (value % max_value).try_into().unwrap();
    }
}

