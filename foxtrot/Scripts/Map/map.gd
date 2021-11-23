extends CanvasLayer

# The theme for the map button for a selected map point
export(String, FILE) var button_map_select_theme

# A container that contains all the map points on the map
onready var map_points = $PanelContainer/Panel/OceanMap/MapPoints

# Label to update current level
onready var level_label = $PanelContainer/Panel/InfoPanel/LevelLabel

# The map point the player has selected to go to. The player can only go to the next and previous
# map point from the played_map_point.
var current_map_point = null

# The map point the player is in currently and has played on
var played_map_point = null

func _ready():
  button_map_select_theme = load(button_map_select_theme)
  Reset()
  
  # On player death reset the map
  if Signals.connect("on_player_death", self, "Reset") != OK:
    printerr("[Map] Error. Could not connect to signal on_player_death...")
    
  # Open the map when a submarine is accessed
  if Signals.connect("on_map_trigger", self, "OpenMap") != OK:
    printerr("[Map] Error. Could not connect to signal on_map_trigger...")
    
  # 
  if Signals.connect("on_map_resurface", self, "Resurface") != OK:
    printerr("[Map] Error. Could not connect to signal on_map_resurface...")
  
  # When a levle is loaded display the new location
  if Signals.connect("on_level_loaded", self, "DisplayLocation") != OK:
    printerr("[Map] Error. Could not connect to signal on_change_base_level...")    

func DisplayLocation():
  # Purpose   : Display panel to show the current location the player is in
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # Make UI visible and update current location text
  $LocationPanel.visible = true
  $LocationPanel/Label.text = played_map_point.level_name
  
  $AnimationPlayer.play("location_panel_open")
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/paper_crumble.wav", 1)
  yield(get_tree().create_timer(2), "timeout")
  $AnimationPlayer.play("location_panel_close")
  Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/paper_folded.wav", 1)  
  
  # Close UI after animation finishes
  while $AnimationPlayer.is_playing():
    yield(get_tree(), "idle_frame")
  $LocationPanel.visible = false  


func ToggleMap(forceState=false, state=false):
  # Purpose   : Turn on/off the map UI
  # Param(s)  :
  # - forceState : set the visibility of the map UI to state instead of toggling
  # - state   : the bool value to set the map UI visibility
  # Return(s) : N/A
  
  var new_state = !$PanelContainer.visible
  if forceState:
    new_state = state
    
  if new_state:
    Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/paper_crumble.wav", 3)
    $PanelContainer.visible = true
    $AnimationPlayer.play("open")
  else:
    Signals.emit_signal("on_play_audio", "res://Audio/SoundEffects/paper_folded.wav", 3)    
    $AnimationPlayer.play("close")
    while $AnimationPlayer.is_playing():
      yield(get_tree(), "idle_frame")
    $PanelContainer.visible = false
    

func _on_BackButton_pressed():
  # Purpose   : Closes the map
  # Param(s)  : N/A
  # Return(s) : N/A
  
  ToggleMap(true, false)

func _on_DiveButton_pressed():
  # Purpose   : Closes the map and launches the player into the selected level
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # Hide the map when the level is being loaded
  ToggleMap(true, false)
  
  # Ignore the player spamming the resurface button
  # No reason to keep loading spawn if the player is in spawn
  if played_map_point == current_map_point && played_map_point.level == Globals.LPATH_SPAWN:
    return
  
  # Change the level
  played_map_point = current_map_point
  Signals.emit_signal("on_change_base_level", current_map_point.level, current_map_point.level_location)
  
  # Change the played map point to the current map point
  UpdateAccessiblePoints()
  
func _on_map_point_select(map_point):
  # Purpose   : Update the selected map point on the map
  # Param(s)  : N/A
  # Return(s) : N/A
  
  UpdateAccessiblePoints()
    
  # Only allow the player to traverse up and down from the played map point. Prevent travelling
  # freely everywhere
  if map_point in played_map_point.next || map_point in played_map_point.prev || map_point == played_map_point:
    # Update the old map point to indicate that it is no longer selected
    current_map_point.set_theme(null)
    
    # Update the current map point the player selected
    current_map_point = map_point
    
    # Update the theme of the map point to clearly indicate visually the current point selected
    map_point.set_theme(button_map_select_theme)
    
    # Update the text of the current level being displayed
    level_label.text = map_point.level_name
  else:
    level_label.text = "Out of range..."

func UpdateAccessiblePoints():
  # Purpose   : Update the icosn of the map points the player can travel to
  # Param(s)  : N/A
  # Return(s) : N/A
  
  for point in map_points.get_children():
    if not (point in played_map_point.next || point in played_map_point.prev || point == played_map_point):
      point.disabled = true
    else:
      point.disabled = false 

func Reset():
  # Purpose   : Reset the map to the first map point (should be spawn)
  # Param(s)  : N/A
  # Return(s) : N/A
  
  if current_map_point: current_map_point.set_theme(null)
  if played_map_point: played_map_point.set_theme(null)
  
  # Set the default current_map_point to spawn
  played_map_point = map_points.get_child(0)
  current_map_point = map_points.get_child(1)
  current_map_point.set_theme(button_map_select_theme)
  level_label.text = current_map_point.level_name
  UpdateAccessiblePoints()
  
func OpenMap():
  # Purpose   : Opens the map
  # Param(s)  : N/A
  # Return(s) : N/A
  
  ToggleMap(true, true)
  
func Resurface():
  # Purpose   : Resets map to spawn and loads the spawn scene.
  # Param(s)  : N/A
  # Return(s) : N/A
  
  if current_map_point: current_map_point.set_theme(null)
  current_map_point = map_points.get_child(0)
  _on_map_point_select(current_map_point)
  _on_DiveButton_pressed()
