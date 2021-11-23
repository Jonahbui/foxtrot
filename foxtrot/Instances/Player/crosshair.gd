extends TextureRect

# The maximum offset from the center the crosshair may go (for controllers)
var radius : int = 50

# The vector storing the coordinates for the center screen
var screen_center = Vector2.ZERO

# A reference to the player... use to determine crosshair placement for controllers
var player = null

func _ready():
  if Signals.connect("on_player_loaded", self, "init_player") != OK:
    printerr("[Save] Error. Failed to connect to signal on_player_loaded...")
  
  # Caculate screen center
  #Input.set_custom_mouse_cursor(null)
  screen_center = get_viewport_rect().size
  screen_center /= 2
  #print_debug(screen_center)

func _input(event):
  # Set the crosshair position to be where the player mouse is (compensate for the pivot point 
  # misaligning the crosshair from the center)
  if event is InputEventMouseMotion:
    self.set_global_position(event.position - self.rect_pivot_offset)
  #else:
    #self.set_global_position(screen_center + radius * Vector2(Input.get_joy_axis(0, JOY_ANALOG_RX), Input.get_joy_axis(0, JOY_ANALOG_RY)).normalized())
    #self.set_global_position(player.get_global_transform().get_origin())
    
func init_player(player):
  self.player = player
