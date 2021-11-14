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
    
  if Signals.connect("on_map_trigger", self, "OpenMap") != OK:
    printerr("[Map] Error. Could not connect to signal on_map_trigger...")
    
  if Signals.connect("on_map_resurface", self, "Resurface") != OK:
    printerr("[Map] Error. Could not connect to signal on_map_resurface...")

func ToggleMap(forceState=false, state=false):
  if forceState:
    $PanelContainer.visible = state
  else:
    $PanelContainer.visible = !$PanelContainer.visible

func _on_BackButton_pressed():
  ToggleMap(true, false)

func _on_DiveButton_pressed():
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
  for point in map_points.get_children():
    if not (point in played_map_point.next || point in played_map_point.prev || point == played_map_point):
      point.disabled = true
    else:
      point.disabled = false 

func Reset():
  if current_map_point: current_map_point.set_theme(null)
  if played_map_point: played_map_point.set_theme(null)
  
  # Set the default current_map_point to spawn
  played_map_point = map_points.get_child(0)
  current_map_point = map_points.get_child(1)
  current_map_point.set_theme(button_map_select_theme)
  level_label.text = current_map_point.level_name
  UpdateAccessiblePoints()
  
func OpenMap():
  ToggleMap(true, true)
  
func Resurface():
  current_map_point = map_points.get_child(0)
  _on_map_point_select(current_map_point)
  _on_DiveButton_pressed()
