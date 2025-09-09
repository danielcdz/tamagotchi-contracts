// Starknet imports
use starknet::{EthAddress};

// Interface definition
#[starknet::interface]
pub trait IPlayer<T> {
    // ------------------------- Player methods -------------------------
    fn spawn_player(ref self: T);
    fn update_player_daily_streak(ref self: T);
    fn update_player_total_points(ref self: T, points: u32);
    fn update_player_total_coins(ref self: T, coins: u32);
    fn update_player_total_gems(ref self: T, gems: u32);
    fn update_player_minigame_highest_score(ref self: T, points: u32, minigame_id: u16);
    fn add_or_update_food_amount(ref self: T, food_id: u8, amount: u8, price: u32);
    fn emit_player_push_token(ref self: T, token: ByteArray);
    fn set_player_name(ref self: T, name: felt252) -> bool;
    fn set_world_coin_address(ref self: T, address: EthAddress);
    fn purchase_with_gems(ref self: T, gems: u32) -> bool;
}

#[dojo::contract]
pub mod player {
    // Local import
    use super::{IPlayer};

    // Starknet imports
    use starknet::{get_block_timestamp, ContractAddress, EthAddress};
    
    // Model imports
    #[allow(unused_imports)]
    use tamagotchi::models::beast::{Beast, BeastTrait};
    use tamagotchi::models::player::{Player, PlayerAssert, PlayerTrait};
    use tamagotchi::models::food::{Food, FoodTrait};
    use tamagotchi::models::highest_score::{HighestScore};

    // Events imports
    use tamagotchi::events::push::{PushToken};

    // Store import
    use tamagotchi::store::{StoreTrait};

    // Dojo Imports
    #[allow(unused_imports)]
    use dojo::model::{ModelStorage};
    #[allow(unused_imports)]
    use dojo::event::EventStorage;

    // Constants imports
    use tamagotchi::constants;

    // Constructor
    fn dojo_init(ref self: ContractState) {}

    // Implementation of the interface methods
    #[abi(embed_v0)]
    impl PlayerImpl of IPlayer<ContractState> {
        // ------------------------- Player methods -------------------------
        fn spawn_player(ref self: ContractState) {
            let mut world = self.world(@"tamagotchi");
            let store = StoreTrait::new(world);

            store.new_player();
        }

        fn set_player_name(ref self: ContractState, name: felt252) -> bool {
            let mut world = self.world(@"tamagotchi");
            let store = StoreTrait::new(world);
            
            let mut player: Player = store.read_player();
            player.assert_exists();
            
            if player.gems_balance() >= constants::CHANGE_NAME_FEE {
                player.decrease_total_gems(constants::CHANGE_NAME_FEE);
                player.set_name(name);
                store.write_player(@player);
                return true;
            }
            
            return false;
        }

        fn set_world_coin_address(ref self: ContractState, address: EthAddress) {

            let mut world = self.world(@"tamagotchi");
            let store = StoreTrait::new(world);

            let mut player: Player = store.read_player();
            player.assert_exists();

            player.set_world_coin_address(address);
            store.write_player(@player);
        }

        fn update_player_daily_streak(ref self: ContractState) {
            let mut world = self.world(@"tamagotchi");
            let store = StoreTrait::new(world);

            let current_timestamp = get_block_timestamp();

            let mut player: Player = store.read_player();
            player.assert_exists();

            player.update_daily_streak(current_timestamp);

            store.write_player(@player);
        }

        fn update_player_total_points(ref self: ContractState, points: u32) {
            let mut world = self.world(@"tamagotchi");
            let store = StoreTrait::new(world);

            let mut player: Player = store.read_player();
            player.assert_exists();

            player.increase_total_points(points);

            store.write_player(@player);
        }

        fn update_player_total_coins(ref self: ContractState, coins: u32) {
            let mut world = self.world(@"tamagotchi");
            let store = StoreTrait::new(world);

            let mut player: Player = store.read_player();
            player.assert_exists();

            player.increase_total_coins(coins);

            store.write_player(@player);
        }

        fn update_player_total_gems(ref self: ContractState, gems: u32) {
            let mut world = self.world(@"tamagotchi");
            let store = StoreTrait::new(world);

            let mut player: Player = store.read_player();
            player.assert_exists();

            player.increase_total_gems(gems);

            store.write_player(@player);
        }

        fn update_player_minigame_highest_score(ref self: ContractState, points: u32, minigame_id: u16) {
            let mut world = self.world(@"tamagotchi");
            let store = StoreTrait::new(world);

            let mut highest_score: HighestScore = store.read_highest_score(minigame_id);

            if points > highest_score.score {
                highest_score.score = points;
                store.write_new_highest_score(@highest_score);
            }
        }

        fn add_or_update_food_amount(ref self: ContractState, food_id: u8, amount: u8, price: u32) { 
            let mut world = self.world(@"tamagotchi");
            let store = StoreTrait::new(world);

            let mut player: Player = store.read_player();
            player.assert_exists();

            if player.coins_balance() >= price {
                player.decrease_total_coins(price);

                // Read the current food model using the provided ID
                let mut food: Food = store.read_food(food_id);

                if food.amount == 0 {
                    // If the food does not exist, create a new one
                    store.new_food(food_id, amount);
                } else {
                    // If the food already exists, update the amount
                    food.update_food_total_amount(amount);
                    store.write_food(@food);
                }

                store.write_player(@player);
            }
        }

        fn emit_player_push_token(ref self: ContractState, token: ByteArray) {
            let mut world = self.world(@"tamagotchi");
            let store = StoreTrait::new(world);

            let mut player: Player = store.read_player();
            player.assert_exists();

            let player_address: ContractAddress = player.address;

            world.emit_event(@PushToken { player_address, token });
        }

        fn purchase_with_gems(ref self: ContractState, gems: u32) -> bool {
            let mut world = self.world(@"tamagotchi");
            let store = StoreTrait::new(world);

            let mut player: Player = store.read_player();
            player.assert_exists();

            if player.gems_balance() >= gems {

                player.decrease_total_gems(gems);

                store.write_player(@player);

                return true;
            } 

            return false;
        }

    }
}
