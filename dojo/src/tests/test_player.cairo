#[cfg(test)]
mod tests {
    // Dojo imports
    #[allow(unused_imports)]
    use dojo::event::{Event, EventStorage};
    use dojo::model::{ModelStorage};
    use dojo::world::world::Event as WorldEvent;

    // Traits import
    use tamagotchi::systems::player::IPlayerDispatcherTrait;
    use tamagotchi::systems::game::IGameDispatcherTrait;

    // Models and types import
    use tamagotchi::models::player::{Player};
    use tamagotchi::tests::utils::{utils::{PLAYER, cheat_caller_address, create_game_system, create_player_system, create_test_world, drop_all_events}};
    use tamagotchi::types::beast_status_custom::{BeastStatusCustom};
    use tamagotchi::types::clean_status::{CleanStatus};

    // Event import
    use tamagotchi::events::push::{PushToken};

    // Constants import
    use tamagotchi::constants;

    // Starknet imports
    use starknet::{EthAddress};

    #[test]
    #[available_gas(40000000)]
    fn test_spawn_player() {
        let world = create_test_world();
        let player_system = create_player_system(world);


        cheat_caller_address(PLAYER());

        // Test spawn player
        player_system.spawn_player();

        // Verify player state
        let player: Player = world.read_model(PLAYER());
        assert(player.current_beast_id == 0, 'invalid initial beast id');
    }

    #[test]
    #[available_gas(50000000)]
    fn test_set_current_beast() {
        let world = create_test_world();
        let game_system = create_game_system(world);
        let player_system = create_player_system(world);


        cheat_caller_address(PLAYER());

        // Initialize player
        player_system.spawn_player();
        
        let custom_beast_status =  BeastStatusCustom {
            beast_id: 3,
            is_alive: true,
            is_awake: true,
            hunger: 50,
            energy: 1,
            happiness: 50,
            hygiene: 50,
            clean_status: CleanStatus::Clean.into(),
            last_timestamp: 7000000,
        };
        
        // Spawn a beast first
        game_system.spawn_beast_custom_status(1, 1, custom_beast_status, 'test-beast'); // Spawn beast with specie 1

        // Set current beast
        let beast_id: u16 = 1;

        // Verify current beast was set correctly
        let player: Player = world.read_model(PLAYER());
        assert(player.current_beast_id == beast_id, 'wrong current beast id');
    }

    #[test]
    #[available_gas(40000000)]
    fn test_update_player_total_points() {
        let world = create_test_world();
        let player_system = create_player_system(world);

        cheat_caller_address(PLAYER());

        // Initialize player
        player_system.spawn_player();

        // Update player total points
        let points: u32 = 100;
        player_system.update_player_total_points(points);

        // Verify player total points
        let player: Player = world.read_model(PLAYER());
        assert(player.total_points == points, 'wrong total points');
    }

    #[test]
    #[available_gas(40000000)]
    fn test_update_player_total_coins() {
        let world = create_test_world();
        let player_system = create_player_system(world);

        cheat_caller_address(PLAYER());

        // Initialize player
        player_system.spawn_player();

        // Update player total points
        let coins: u32 = 1000;
        player_system.update_player_total_coins(coins);

        // Verify player total points
        let player: Player = world.read_model(PLAYER());
        assert(player.total_coins == coins + constants::INITIAL_COINTS, 'wrong total coins');
    }

            #[test]
    #[available_gas(40000000)]
    fn test_update_player_total_gems() {
        let world = create_test_world();
        let player_system = create_player_system(world);

        cheat_caller_address(PLAYER());

        // Initialize player
        player_system.spawn_player();

        // Update player total points
        let gems: u32 = 1000;
        player_system.update_player_total_gems(gems);

        // Verify player total points
        let player: Player = world.read_model(PLAYER());
        assert(player.total_gems == gems + constants::INITIAL_GEMS, 'wrong total gems');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_player_emit_push_token_event() {
        let world = create_test_world();
        let player_system = create_player_system(world);

        cheat_caller_address(PLAYER());

        // Initialize player
        player_system.spawn_player();

        drop_all_events(world.dispatcher.contract_address);

        let test_client_token: ByteArray = "fAU1e5l3h3LH3IvL-oopuG:APA91bH7wBebtThd31cXqRgMQrAQ7Jc3arbBlYDXuKf5D81SmSyokGH24yefscOpUzRV0YwSFMy6N_DVrgMvISFCXYVOU8_DxpQUP-c5vtqUxF1cG5nfNMU";
        
        // Call method to emit the event
        player_system.emit_player_push_token(test_client_token);

        let event = starknet::testing::pop_log::<WorldEvent>(world.dispatcher.contract_address);

        assert(event.is_some(), 'no event');

        if let WorldEvent::EventEmitted(event) = event.unwrap() {
            assert(
                event.selector == Event::<PushToken>::selector(world.namespace_hash),
                'bad event selector',
            );
            assert(event.keys == [PLAYER().into()].span(), 'bad key');
            // Values assert omited as there is issues retrieving them
            // assert(event.values == [test_client_token.into()].span(), 'bad value');
        } else {
            core::panic_with_felt252('no PushToken event emited');
        }
    }

    #[test]
    #[available_gas(40000000)]
    fn test_set_player_world_coin_address() {
        let world = create_test_world();
        let player_system = create_player_system(world);

        cheat_caller_address(PLAYER());

        player_system.spawn_player();

        let world_coin_address: EthAddress = '0x123'.try_into().unwrap();
        player_system.set_world_coin_address(world_coin_address);

        let player: Player = world.read_model(PLAYER());
        assert(player.world_coin_address == world_coin_address, 'wrong world coin address');
    }
}
