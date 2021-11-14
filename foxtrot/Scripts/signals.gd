extends Node

#--------------------------------------------------------------------------------------------------
# Audio System Signals
#--------------------------------------------------------------------------------------------------
# Inform the game to play the clip in the music source
signal on_play_audio(clip, source)
#--------------------------------------------------------------------------------------------------
# Base Signals
#--------------------------------------------------------------------------------------------------
# Inform the game when a level change request is sent
signal on_change_base_level(level, location)

# Signals that the base game has been fully loaded
signal on_base_game_loaded()
#--------------------------------------------------------------------------------------------------
# Dialogue System Signals
#--------------------------------------------------------------------------------------------------
# Inform the dialogue system that a dialogue has started
signal on_dialogue_trigger(dialogue_id)

# Inform the dialogue system that a dialogue has ended
signal on_dialogue_exited()
#--------------------------------------------------------------------------------------------------
# Inventory System Signals
#--------------------------------------------------------------------------------------------------
# Inform the world that an `item` is to be dropped at `position`
signal on_item_drop(item, position)

# Inform the game to add an item to the player inventory
signal on_inventory_add_item(item)

# Inform the game to add an item_stack to the player inventory with the amount
signal on_inventory_add_item_stack(item, amount)

# Inform the game that the player has died
signal on_player_death()
#--------------------------------------------------------------------------------------------------
# Map Signals
#--------------------------------------------------------------------------------------------------
# Inform the game to open the map
signal on_map_trigger()

# Tell the game to reset player to spawn and reset the map
signal on_map_resurface()
#--------------------------------------------------------------------------------------------------
# Level Signals
#--------------------------------------------------------------------------------------------------
signal on_level_loaded()
#--------------------------------------------------------------------------------------------------
# Player/ Interaction Signals
#--------------------------------------------------------------------------------------------------
# Informs the player that they can or cannot interact with the object they have entered
signal on_interaction_changed(state)

# Send this signal to notify that the player's money has changed in amount
signal on_money_update()

# Send this signal to signify the player's base damage has changed
signal on_damage_update()

# Send this signal to signify the player's defense has changed
signal on_defense_update()

# Send this signal to signify that the player's seashell collection has updated
signal on_seashell_update()
#--------------------------------------------------------------------------------------------------
# Save System Signals
#--------------------------------------------------------------------------------------------------
# Informs the game that the player has been loaded
signal on_player_loaded(player)

# Informs the game that the inventory has been loaded
signal on_inventory_loaded(inventory)

# Informs the game that the game has saved
signal on_game_saved(state)
