// Starknet import
pub use starknet::{ContractAddress, EthAddress};
use core::num::traits::zero::Zero;

// Constants imports
use tamagotchi::constants;

// Helpers import
use tamagotchi::helpers::timestamp::Timestamp;

// Model
#[derive(Copy, Drop, Serde, IntrospectPacked, Debug)]
#[dojo::model]
pub struct Player {
    #[key]
    pub address: ContractAddress,
    pub world_coin_address: EthAddress,
    pub name: felt252,
    pub current_beast_id: u16,
    pub daily_streak: u16,
    pub total_points: u32,
    pub total_coins: u32,
    pub total_gems: u32,
    pub last_active_day: u32,
    pub creation_day: u32
}

// Traits Implementations
#[generate_trait]
pub impl PlayerImpl of PlayerTrait { 
    fn update_daily_streak(ref self: Player, current_timestamp: u64) {
        let current_day: u32 = Timestamp::unix_timestamp_to_day(current_timestamp);

        if current_day == self.last_active_day {
            return;
        }

        if current_day == self.last_active_day + 1 {
            self.daily_streak += 1;
        } else {
            self.daily_streak = 0;
        }

        self.last_active_day = current_day;
    }

    fn increase_total_points(ref self: Player, points: u32) {
        self.total_points += points;
    }

    fn increase_total_coins(ref self: Player, coins: u32) {
        self.total_coins += coins;
    }

    fn decrease_total_coins(ref self: Player, coins: u32) {
        self.total_coins -= coins;
    }

    fn increase_total_gems(ref self: Player, gems: u32) {
        self.total_gems += gems;
    }

    fn decrease_total_gems(ref self: Player, gems: u32) {
        self.total_gems -= gems;
    }

    fn gems_balance(ref self: Player) -> u32 {
        return self.total_gems;
    }

    fn coins_balance(ref self: Player) -> u32 {
        return self.total_coins;
    }

    fn set_name(ref self: Player, name: felt252) {
        self.name = name;
    }
}

#[generate_trait]
pub impl PlayerAssert of AssertTrait {
    #[inline(always)]
    fn assert_exists(self: Player) {
        assert(self.is_non_zero(), 'Player: Does not exist');
    }

    #[inline(always)]
    fn assert_not_exists(self: Player) {
        assert(self.is_zero(), 'Player: Already exist');
    }
}

pub impl ZeroablePlayerTrait of Zero<Player> {
    #[inline(always)]
    fn zero() -> Player {
        Player {
            address: constants::ZERO_ADDRESS(),
            world_coin_address: 0.try_into().unwrap(),
            name: 'player',
            current_beast_id: 0,
            total_points: 0,
            total_coins: 0,
            total_gems: 0,
            daily_streak: 0,
            last_active_day: 0,
            creation_day: 1,
        }
    }

    #[inline(always)]
    fn is_zero(self: @Player) -> bool {
       *self.address == constants::ZERO_ADDRESS()
    }

    #[inline(always)]
    fn is_non_zero(self: @Player) -> bool {
        !self.is_zero()
    }
}

// Tests
#[cfg(test)]
mod tests {
    use super::{Player, ZeroablePlayerTrait};
    use tamagotchi::constants;
    use starknet::{ContractAddress, contract_address_const};

    #[test]
    #[available_gas(1000000)]
    fn test_player_initialization() {
        // Use contract_address_const to create a mock address
        let mock_address: ContractAddress = contract_address_const::<0x123>();
        let initial_beast_id: u16 = 1;

        let player = Player {
            address: mock_address,
            world_coin_address: 0.try_into().unwrap(),
            name: 'Player',
            current_beast_id: initial_beast_id,
            total_points: 0,
            total_coins: 0,
            total_gems: 0,
            daily_streak: 0,
            last_active_day: 0,
            creation_day: 1,
        };

        assert_eq!(
            player.address, 
            mock_address, 
            "Player address should match the initialized address"
        );
        assert_eq!(
            player.current_beast_id, 
            initial_beast_id, 
            "Current beast ID should be 1"
        );
        assert_eq!(
            player.daily_streak, 
            0, 
            "Current beast ID should be 1"
        );
        assert_eq!(
            player.last_active_day, 
            0, 
            "Current beast ID should be 1"
        );
        assert_eq!(
            player.creation_day, 
            1, 
            "Current beast ID should be 1"
        );
    }

    #[test]
    #[available_gas(1000000)]
    fn test_player_initialization_zero_values() {
        let player: Player = ZeroablePlayerTrait::zero();

        assert_eq!(
            player.address, 
            constants::ZERO_ADDRESS(), 
            "Player address should match the initialized address"
        );
    }

    #[test]
    #[available_gas(1000000)]
    fn test_player_with_zero_beast() {
        let mock_address: ContractAddress = contract_address_const::<0x456>();
        
        let player = Player {
            address: mock_address,
            world_coin_address: 0.try_into().unwrap(),
            name: 'Player',
            current_beast_id: 0,
            total_points: 0,
            daily_streak: 0,
            total_coins: 0,
            total_gems: 0,
            last_active_day: 0,
            creation_day: 1,
        };

        assert_eq!(
            player.current_beast_id, 
            0, 
            "Initial beast ID should be 0 for new player"
        );
    }

    #[test]
    #[available_gas(1000000)]
    fn test_player_address_uniqueness() {
        let address1: ContractAddress = contract_address_const::<0x123>();
        let address2: ContractAddress = contract_address_const::<0x456>();

        let player1 = Player {
            address: address1,
            world_coin_address: 0.try_into().unwrap(),
            name: 'Player',
            current_beast_id: 1,
            total_points: 0,
            total_coins: 0,
            total_gems: 0,
            daily_streak: 0,
            last_active_day: 0,
            creation_day: 1,
        };

        let player2 = Player {
            address: address2,
            world_coin_address: 0.try_into().unwrap(),
            name: 'Player',
            current_beast_id: 2,
            total_points: 0,
            total_coins: 0,
            total_gems: 0,
            daily_streak: 0,
            last_active_day: 0,
            creation_day: 1,
        };

        assert!(
            player1.address != player2.address, 
            "Players should have unique addresses"
        );
    }
}
