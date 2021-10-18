extends Node2D

var current_level = null

var history = []
var history_index = -1

export(NodePath) var dev_console
export(NodePath) var cmdline
export(NodePath) var logs

func _input(event):
  if event.is_action_released("ui_dev"):
    ToggleDevConsole()
  
  if dev_console.visible && cmdline.has_focus():
    if event.is_action_pressed("ui_up"):
      GetNextHistoryCmd()
    elif event.is_action_pressed("ui_down"):
      GetNextHistoryCmd(false) 
  
func _ready():
  # Load default level on base load
  LoadLevel(Globals.LPATH_SPAWN)
  
  dev_console = self.get_node(dev_console)
  cmdline = self.get_node(cmdline)
  logs = self.get_node(logs)
  
  print()
  if Signals.connect("on_player_death", self, "OnDeath") != OK:
    print("[Base] Error. Failed to connect to signal on_player_death...")
  
  if Signals.connect("on_play_sfx", self, "PlaySfx") != OK:
    print("[Base] Error. Failed to connect to signal on_play_sfx...")
    
  if Signals.connect("on_play_music", self, "PlayMusic") != OK:
    print("[Base] Error. Failed to connect to signal on_play_music...")
    
func ToggleDevConsole():
  # Set the current visibility to the opposite of the current visibility
  dev_console.visible = !dev_console.visible
  
  # Inform the game of the new state, so other scripts pause accordingly
  Globals.SetFlag(Globals.FLAG_DEV_OPEN, dev_console.visible)
  if dev_console.visible:
    cmdline.grab_focus()
 
  
func PlayMusic(clip):
  var audio = load(clip)
  
  if clip:
    $Audio/MusicStream.stream = audio    
    $Audio/MusicStream.play()
  
func PlaySfx(clip):
  var audio = load(clip)
    
  if clip:
    $Audio/SFXStream.stream = audio
    $Audio/SFXStream.play()
     
func LoadLevel(path):
  ToggleLoadingScreen(true)
  
  # Give transition period
  var time_in_seconds = 0.25
  yield(get_tree().create_timer(time_in_seconds), "timeout")
  
  # Disable the player to prevent unwanted actions while changing levels
  Helper.SetActive($Player, false)
  
  # Load the current level.
  ## Check if there is already a level present
  var level_node = get_node_or_null("Level")
  if level_node != null:
    # If the level exists already, remove it
    self.remove_child(level_node)
    level_node.call_deferred("free")
  
  # Load and add the new level
  current_level = load(path)
  self.add_child(current_level.instance())
  
  # Get spawnpoint path and set player position to spawnpoint.
  var spawnpoint = current_level.instance().get_node_or_null("Spawnpoint")
  if spawnpoint != null:
    $Player.position = spawnpoint.position
  else:
    printerr("The spawnpoint could not be located in %s" % [spawnpoint.get_name()])
  
  # After the level is loaded, reenable the player
  Helper.SetActive($Player, true)
  
  # Give transition period
  yield(get_tree().create_timer(time_in_seconds), "timeout")
  
  ToggleLoadingScreen(false)  
  
func _on_CmdLine_text_entered(new_text):
  # Do some preprocessing to avoid errors when parsing
  new_text = new_text.strip_edges()
  
  # Reset command line for next user input
  cmdline.text = ""
  
  # Display last user input
  logs.text += "\n> %s" % [new_text] if history.size() > 0 else "> %s" % [new_text]
  var line_count = logs.get_line_count()
  logs.cursor_set_line(line_count)
  ProcessCmd(new_text)
  
func ProcessCmd(cmd):
  UpdateHistory(cmd)
  
  # Reset history index so the user searches through the front again
  history_index = -1
  
  # Do not execute anything if the command is null
  if (cmd == null): return

  # Parse the input
  var parse = cmd.split(" ")
  
  # Organize commands by the number of parameters
  if parse.size() == 0:
    return
  elif parse.size() == 1:
    match parse[0]:
      "clear":
        logs.text = ""
      "exit":
        get_tree().quit()
      "kill":
        $Player.TakeDamage($Player.health)
      
  elif(parse.size() == 2):
    match parse[0]:
      "setlevel":
        # Note: if leaving in for player, need to sanitize input just in case
        # they load up a scene they should not be allowed to...
        var valid : bool = File.new().file_exists(parse[1])
        valid = parse[1] in Globals.LEVEL_PATH && valid
        if valid : LoadLevel(parse[1])
      
func UpdateHistory(cmd):
  if(history.size() > 10):
    history.pop_back()
  history.push_front(cmd)
    
func GetNextHistoryCmd(forward=true):
  if history.size() > 0:
    history_index = (history_index + 1) if(forward) else (history_index  - 1)
    
    if history_index < 0:
      history_index = 0
      cmdline.text = ""
    elif history_index >= history.size():
      history_index = history.size() - 1
    else:
      cmdline.text = history[history_index]

func ToggleLoadingScreen(state):
  $LoadingScreen/LoadingScreen.visible = state

func _on_CmdLine_text_changed(new_text):
  var old_pos = cmdline.caret_position
  # Do not allow '`' to be used as input
  new_text = new_text.replace('`', '')
  cmdline.text = new_text
  cmdline.caret_position = old_pos

func OnDeath():
  if Globals.isHardcoreMode:
    # Go back to main menu
    Helper.ChangeLevel(Globals.SPATH_MAIN_MENU)
    # Restart game
  else:
    # Go back to spawn 
    LoadLevel(Globals.LPATH_SPAWN)
    $Player.ResetPlayer()
  print("Triggered")
