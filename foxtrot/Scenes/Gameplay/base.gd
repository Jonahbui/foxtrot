extends Node2D

var current_level = null

var history = []
var history_index = -1

func _input(event):
  if(event.is_action_pressed("ui_dev")):
    $UI/DevConsole.visible = !$UI/DevConsole.visible
    Globals.isDevConsoleOpen = $UI/DevConsole.visible
  elif(event.is_action_pressed("ui_up")):
    if($UI/DevConsole/CmdLine.has_focus()):
      GetNextHistoryCmd()
  elif(event.is_action_pressed("ui_down")):
    if($UI/DevConsole/CmdLine.has_focus()):
      GetNextHistoryCmd(false)
  
func _ready():
  LoadLevel("res://Scenes/Gameplay/Spawn.tscn")
    
func LoadLevel(path):
  $Player.visible = false
  # Load the level.
  var level_node = get_node_or_null("/root/Base/Level")
  if level_node != null:
    remove_child(level_node)
    level_node.call_deferred("free")
  current_level = load(path)
  add_child(current_level.instance())
  
  # Get spawnpoint path and set player position to spawnpoint.
  var spawnpoint = current_level.instance().get_node_or_null("Spawnpoint")
  if spawnpoint != null:
    $Player.position = spawnpoint.position
  else:
    printerr("The spawnpoint could not be located in %s" % [spawnpoint.get_name()])
  $Player.visible = true
  
func _on_CmdLine_text_entered(new_text):
  # Do some preprocessing to avoid errors when parsing
  new_text = new_text.strip_edges()
  
  # Reset command line for next user input
  $UI/DevConsole/CmdLine.text = ""
  
  # Display last user input
  $UI/DevConsole/Log.text += "\n> %s" % [new_text] if history.size() > 0 else "> %s" % [new_text]
  var line_count = $UI/DevConsole/Log.get_line_count()
  $UI/DevConsole/Log.cursor_set_line(line_count)
  ProcessCmd(new_text)
  
func ProcessCmd(cmd):
  UpdateHistory(cmd)
  
  # Reset history index so the user searches through the front again
  history_index = -1
  
  # Do not execute anything if the command is null
  if (cmd == null): 
    return

  # Parse the input
  var parse = cmd.split(" ")
  
  # Organize commands by the number of parameters
  if parse.size() == 0:
    return
  elif parse.size() == 1:
    
    if parse[0] == "clear":
      $UI/DevConsole/Log.text = ""
    elif parse[0] == "exit":
      get_tree().quit()
      
  elif(parse.size() == 2):
    
    if(parse[0] == "setlevel"):
      # Note: if leaving in for player, need to sanitize input just in case
      # they load up a scene they should not be allowed to...
      var file_exists = File.new().file_exists(parse[1])
      if file_exists : LoadLevel(parse[1])
      
func UpdateHistory(cmd):
  if(history.size() > 10):
    history.pop_back()
  history.push_front(cmd)
    
func GetNextHistoryCmd(forward=true):
  if history.size() > 0:
    history_index = (history_index + 1) if(forward) else (history_index  - 1)
    
    if history_index < 0:
      history_index = 0
      $UI/DevConsole/CmdLine.text = ""
    elif history_index >= history.size():
      history_index = history.size() - 1
    else:
      $UI/DevConsole/CmdLine.text = history[history_index]
