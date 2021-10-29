extends Node

# Inform the world that an `item` is to be dropped at `position`
signal on_item_drop(item, position)

# Inform the game that the player has died
signal on_player_death()

# Inform the game to play the clip in the music source
signal on_play_music(clip)

# Inform the game to play the clip in the sfx source
signal on_play_sfx(clip)

# Inform the game when a level change request is sent
signal on_change_base_level(level)

# Inform the dialogue system that a dialogue has started
signal on_dialogue_trigger(dialogue_id)

signal on_dialogue_exited()

# Informs the player that they can or cannot interact with the object they have entered
signal on_interaction_changed(state)

# Signals that the base game has been fully loaded.
signal on_base_game_loaded()
#--------------------------------------------------------------------------------------------------
# Save System Signals
#--------------------------------------------------------------------------------------------------
signal on_player_loaded(player)

signal on_inventory_loaded(inventory)

signal on_game_saved(state)
