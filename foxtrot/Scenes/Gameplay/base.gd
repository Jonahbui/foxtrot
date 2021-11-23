extends Node2D

# The current level the player is on
var current_level = null

# Dev console vars
var history = []
var history_index = -1

export(NodePath) var dev_console
export(NodePath) var cmdline
export(NodePath) var logs

# The node to instantiate when an entity takes damage
export(String, FILE) var damage_text

# --------------------------------------------------------------------------------------------------
# Godot Functions
# --------------------------------------------------------------------------------------------------
func _input(event):
  if event.is_action_released("ui_dev"):
    ToggleDevConsole()
  
  if dev_console.visible && cmdline.has_focus():
    if event.is_action_pressed("ui_up"):
      GetNextHistoryCmd()
      cmdline.caret_position = cmdline.text.length()
    elif event.is_action_pressed("ui_down"):
      GetNextHistoryCmd(false) 
  
func _ready():
  # Load default level on base load
  LoadLevel(Globals.LPATH_SPAWN)
  
  dev_console = self.get_node(dev_console)
  cmdline = self.get_node(cmdline)
  logs = self.get_node(logs)
  
  damage_text = load(damage_text)
  
  # Sets the game up after the player has died
  if Signals.connect("on_player_death", self, "OnDeath") != OK:
    printerr("[Base] Error. Failed to connect to signal on_player_death...")
  
  # Plays audio from random sources
  if Signals.connect("on_play_audio", self, "PlayAudio") != OK:
    printerr("[Base] Error. Failed to connect to signal on_play_audio...")

  # Loads the selected gameplay level
  if Signals.connect("on_change_base_level", self, "LoadLevel") != OK:
    printerr("[Base] Error. Failed to connect to signal on_change_base_level...")
  
  # Generates damage text
  if Signals.connect("on_damage_taken", self, "SpawnDamageText") != OK:
    printerr("[Base] Error. Failed to connect to signal on_change_base_level...")
# --------------------------------------------------------------------------------------------------
# Audio Functions
# --------------------------------------------------------------------------------------------------
func PlayAudio(clip, source):
  # Purpose   : Plays sounds
  # Param(s)  : 
  # - clip    : the absolute project path of the clip to play
  # - source  : the desired audio source in which to play the clip (0-3
  # Return(s) : N/A
  var audio = load(clip)
  
  if audio:
    match source:
      0:
        $Audio/MusicStream.stream = audio    
        $Audio/MusicStream.play()
      1:
        $Audio/SFXStream.stream = audio    
        $Audio/SFXStream.play()
      2:
        $Audio/AmbienceStream.stream = audio    
        $Audio/AmbienceStream.play()
      3:
        $Audio/UIStream.stream = audio    
        $Audio/UIStream.play()
      _:
        pass
  else:
    printerr("[Base] Error. Could not play \"%s\"" % [clip])

# --------------------------------------------------------------------------------------------------
# Base Scene Functions
# --------------------------------------------------------------------------------------------------
func LoadLevel(path, location=""):
  # Purpose   : Loads a gameplay level
  # Param(s)  : 
  # - path    : the filepath to the level's tscn file
  # - location: string of the spawnpoint to place the player
  # Return(s) : N/A
  ToggleLoadingScreen(true)
  
  # Give transition period
  var time_in_seconds = 0.25
  yield(get_tree().create_timer(time_in_seconds), "timeout")
  
  # Disable the player to prevent unwanted actions while changing levels
  Helper.SetActive($Player, false, false, false, false)
  
  # Load the current level.
  ## Check if there is already a level present
  var level_node = get_node_or_null("Level")
  if level_node != null:
    # If the level exists already, remove it
    self.remove_child(level_node)
    level_node.call_deferred("free")
  
  # Load and add the new level
  current_level = load(path)
  var instance = current_level.instance()
  self.add_child(instance)
  
  # Get spawnpoint path and set player position to spawnpoint.
  var spawnlocation = instance.get_node_or_null("Spawnpoint/%s" % [location])
  if spawnlocation != null:
    $Player.set_global_position(spawnlocation.get_global_position())
    print_debug("[Base] Loaded at \'Spawnpoint/%s\'..." % [location])    
  else:
    printerr("[Base] The location could not be located in Spawnpoint/%s..." % [location])

  # After the level is loaded, reenable the player
  Helper.SetActive($Player, true, true, true, true)
  
  # Give transition period
  yield(get_tree().create_timer(time_in_seconds), "timeout")
  
  ToggleLoadingScreen(false)  
    
func OnDeath():
  # Purpose   : Sets up the game after the player has died
  # Param(s)  : N/A
  # Return(s) : N/A
  $Audio.KillAudio()
  $UI/GameOver.visible = true
  Signals.emit_signal("on_play_audio", "res://Audio/Music/death_song.mp3", 0)

func Restart():
  # Purpose   : Restarts the game at spawn after the player died
  # Param(s)  : N/A
  # Return(s) : N/A
  $Audio.KillAudio()
  $UI/GameOver.visible = false
  LoadLevel(Globals.LPATH_SPAWN)
  $Player.ResetPlayer()
  
func Quit():
  # Purpose   : Quits the game
  # Param(s)  : N/A
  # Return(s) : N/A
  get_tree().quit()

func SpawnDamageText(damage, pos):
  # Purpose   : Instantiates text representing how much damage was dealt
  # Param(s)  :
  # - damage  : the amount of damage dealt
  # - pos     : the global position to spawn the text
  # Return(s) : N/A
  var instance = damage_text.instance()
  self.add_child(instance)
  instance.Init(damage, pos)

func ToggleLoadingScreen(state):
  # Purpose   : Turns off or on the loading screen
  # Param(s)  :
  # - state   : the state to set the loading screen
  # Return(s) : N/A
  if state:
    $LoadingScreen/LoadingScreen.visible = true
    $LoadingScreen/AnimationPlayer.play("open")
  else:
    $LoadingScreen/AnimationPlayer.play("close")
    while $LoadingScreen/AnimationPlayer.is_playing():
      yield(get_tree(), "idle_frame")
    $LoadingScreen/LoadingScreen.visible = false
# --------------------------------------------------------------------------------------------------
# Dev Console Functions
# --------------------------------------------------------------------------------------------------
func GetNextHistoryCmd(forward=true):
  # Purpose   : Populates the cmd line with the next history cmd
  # Param(s)  :
  # - forward : Gets the next history command if true, else gets the previous
  # Return(s) : N/A
  if history.size() > 0:
    history_index = (history_index + 1) if(forward) else (history_index  - 1)
    
    if history_index < 0:
      history_index = 0
      cmdline.text = ""
    elif history_index >= history.size():
      history_index = history.size() - 1
    else:
      cmdline.text = history[history_index]
    
  cmdline.caret_position = cmdline.text.length()

func ProcessCmd(cmd):
  # Purpose   : Executes the commmand passed in if valid
  # Param(s)  :
  # - cmd     : A string representing the command
  # Return(s) : N/A
  UpdateHistory(cmd)
  
  # Reset history index so the user searches through the front again
  history_index = -1
  
  # Do not execute anything if the command is null
  if (cmd == null): return

  # Parse the input
  var parse = cmd.split(" ")
  
  # Organize commands by the number of parameters
  match parse.size():
    0:
      return
    1:
      match parse[0]:
        "clear":
          logs.text = ""
        "exit":
          get_tree().quit()
        "kill":
          $Player.TakeDamage($Player.health)
        _:
          logs.text += "\nCould not find command..."
    2:
      match parse[0]:
        "setlevel":
          # Note: if leaving in for player, need to sanitize input just in case
          # they load up a scene they should not be allowed to...
          var valid : bool = File.new().file_exists(parse[1])
          valid = parse[1] in Globals.LEVEL_PATH && valid
          if valid : LoadLevel(parse[1])
        "damage":
          $Player.TakeDamage(int(parse[1]))
        _:
          logs.text += "\nCould not find command or not enough params provided..."
    3:
      match parse[0]:
        "additem":
          if not parse[1].is_valid_integer(): return
          var item_id = int(parse[1])
          if not item_id in Equips.equips: 
            logs.text += "\nInvalid id presented. Could not find item..."
            return
          
          if Equips.equips[item_id].subtype != Equips.Subtype.stackable:
            Signals.emit_signal("on_inventory_add_item", item_id)
          else:
            if not parse[2].is_valid_integer(): return
            var amount = int(parse[2])
            Signals.emit_signal("on_inventory_add_item_stack", item_id, amount)
        _:
          logs.text += "\nCould not find command or not enough params provided..."

func ToggleDevConsole():
  # Purpose   : Toggles on or off the deve console based off its current state
  # Param(s)  : N/A
  # Return(s) : N/A

  # Set the current visibility to the opposite of the current visibility
  dev_console.visible = !dev_console.visible
  
  # Inform the game of the new state, so other scripts pause accordingly
  Globals.SetFlag(Globals.FLAG_DEV_OPEN, dev_console.visible)
  if dev_console.visible:
    cmdline.grab_focus()

func UpdateHistory(cmd):
  # Purpose   : Adds a command to the history
  # Param(s)  :
  # - cmd     : The command to add to the history
  # Return(s) : N/A
  
  if(history.size() > 10):
    history.pop_back()
  history.push_front(cmd)

func _on_CmdLine_text_entered(new_text):
  # Purpose   : Ensures the text entered is proper, issues the command entered, and logs it
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # Do some preprocessing to avoid errors when parsing
  new_text = new_text.strip_edges()
  
  # Reset command line for next user input
  cmdline.text = ""
  
  # Display last user input
  logs.text += "\n> %s" % [new_text] if history.size() > 0 else "> %s" % [new_text]
  var line_count = logs.get_line_count()
  logs.cursor_set_line(line_count)
  ProcessCmd(new_text)
  
func _on_CmdLine_text_changed(new_text):
  # Purpose   : Ensures certain characters are removed from input
  # Param(s)  : N/A
  # Return(s) : N/A
  
  var old_pos = cmdline.caret_position
  # Do not allow '`' to be used as input
  new_text = new_text.replace('`', '')
  cmdline.text = new_text
  cmdline.caret_position = old_pos
