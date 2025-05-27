#[cfg(test)]
mod tests {
    // Dojo import
    use dojo::model::{ModelStorage};

    // Traits import
    use tamagotchi::systems::game::IGameDispatcherTrait;
    use tamagotchi::systems::player::IPlayerDispatcherTrait;

    // Import models and types
    use tamagotchi::models::beast::{Beast};
    use tamagotchi::tests::utils::{utils::{PLAYER, cheat_caller_address, create_game_system, create_player_system, create_test_world, cheat_block_timestamp}};

    // Types import
    use tamagotchi::types::beast_status_custom::{BeastStatusCustom};
    use tamagotchi::types::clean_status::{CleanStatus};

    #[test]
    fn test_spawn_beast_custom_status_custom_status() {
        // Initialize test environment
        let world = create_test_world();
        let game_system = create_game_system(world);
        let player_system = create_player_system(world);

        cheat_caller_address(PLAYER());

        // Setup player
        player_system.spawn_player();

        let custom_beast_status =  BeastStatusCustom {
            beast_id: 1,
            is_alive: true,
            is_awake: true,
            hunger: 100,
            energy: 100,
            happiness: 100,
            hygiene: 100,
            clean_status: CleanStatus::Clean.into(),
            last_timestamp: 7000000,
        };

        // Spawn beast with specie 1
        game_system.spawn_beast_custom_status(1, 1, custom_beast_status);
        player_system.set_current_beast(1);

        // Get beast data
        let beast: Beast = world.read_model((PLAYER(), 1));
        println!("Beast Data - ID: {}, Specie: {}", 
            beast.beast_id, beast.specie);

        // Verify initial beast state
        assert(beast.beast_id == 1, 'wrong beast id');
        assert(beast.specie == 1, 'wrong specie');
    }

    #[test]
    fn test_beast_age_reading_model() {
        // Initialize test environment
        let world = create_test_world();
        let game_system = create_game_system(world);
        let player_system = create_player_system(world);

        let custom_beast_status =  BeastStatusCustom {
            beast_id: 1,
            is_alive: true,
            is_awake: true,
            hunger: 100,
            energy: 100,
            happiness: 100,
            hygiene: 100,
            clean_status: CleanStatus::Clean.into(),
            last_timestamp: 7000000,
        };

        cheat_caller_address(PLAYER());
        cheat_block_timestamp(7000000);

        player_system.spawn_player();
        game_system.spawn_beast_custom_status(1, 1, custom_beast_status);
        player_system.set_current_beast(1);

        // Get beast age before 24 hours
        game_system.update_beast();
        let mut beast: Beast = world.read_model((PLAYER(), 1));
        assert(beast.age == 0, 'wrong beast age');

        // Get beast age after 24 hours
        cheat_block_timestamp(7086500);
        game_system.update_beast();
        let mut beast: Beast = world.read_model((PLAYER(), 1));
        assert(beast.age == 1, 'wrong beast age');

        // Get beast age
        cheat_block_timestamp(7172900);
        game_system.update_beast();
        beast = world.read_model((PLAYER(), 1));
        assert(beast.age == 2, 'wrong beast age');
    }

    #[test]
    fn test_multiple_beasts() {
        // Initialize test environment
        let world = create_test_world();
        let game_system = create_game_system(world);
        let player_system = create_player_system(world);

        cheat_caller_address(PLAYER());

        // Setup player
        player_system.spawn_player();

        let custom_beast_status_1 =  BeastStatusCustom {
            beast_id: 1,
            is_alive: true,
            is_awake: true,
            hunger: 50,
            energy: 1,
            happiness: 50,
            hygiene: 50,
            clean_status: CleanStatus::Clean.into(),
            last_timestamp: 7000000,
        };

        let custom_beast_status_2 =  BeastStatusCustom {
            beast_id: 2,
            is_alive: true,
            is_awake: true,
            hunger: 50,
            energy: 1,
            happiness: 50,
            hygiene: 50,
            clean_status: CleanStatus::Clean.into(),
            last_timestamp: 7000000,
        };

        let custom_beast_status_3 =  BeastStatusCustom {
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

        // Spawn multiple beasts
        game_system.spawn_beast_custom_status(1, 1, custom_beast_status_1); // First beast, specie 1
        game_system.spawn_beast_custom_status(2 , 2, custom_beast_status_2); // Second beast, specie 2
        game_system.spawn_beast_custom_status(3, 3, custom_beast_status_3); // Third beast, specie 3

        // Read and verify each beast
        let beast1: Beast = world.read_model((PLAYER(), 1));
        let beast2: Beast = world.read_model((PLAYER(), 2));
        let beast3: Beast = world.read_model((PLAYER(), 3));

        println!("Beast 1 - ID: {}, Specie: {}", beast1.beast_id, beast1.specie);
        println!("Beast 2 - ID: {}, Specie: {}", beast2.beast_id, beast2.specie);
        println!("Beast 3 - ID: {}, Specie: {}", beast3.beast_id, beast3.specie);

        // Verify each beast has correct ID and specie
        assert(beast1.beast_id == 1 && beast1.specie == 1, 'wrong beast 1 data');
        assert(beast2.beast_id == 2 && beast2.specie == 2, 'wrong beast 2 data');
        assert(beast3.beast_id == 3 && beast3.specie == 3, 'wrong beast 3 data');
    }
}
