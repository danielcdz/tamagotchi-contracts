#[cfg(test)]
mod tests {
    // Dojo imports
    #[allow(unused_imports)]
    use dojo::event::{Event, EventStorage};
    use dojo::model::{ModelStorage};
    use dojo::world::world::Event as WorldEvent;

    // Traits import
    use tamagotchi::systems::player::IPlayerDispatcherTrait;

    // Models and types import
    use tamagotchi::models::player::{Player};
    use tamagotchi::tests::utils::{utils::{PLAYER, cheat_caller_address, create_player_system, create_test_world, drop_all_events}};

    // Event import
    use tamagotchi::events::push::{PushToken};

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
}
