extends TextureRect

var radius : int = 50
var screen_center = Vector2.ZERO

var player = null

func _ready():
  if Signals.connect("on_player_loaded", self, "init_player") != OK:
    printerr("[Save] Error. Failed to connect to signal on_player_loaded...")
  #Input.set_custom_mouse_cursor(null)
  screen_center = get_viewport_rect().size
  screen_center /= 2
  #print(screen_center)

func _input(event):
  if event is InputEventMouseMotion:
    self.set_global_position(event.position - self.rect_pivot_offset)
  #else:
    #self.set_global_position(screen_center + radius * Vector2(Input.get_joy_axis(0, JOY_ANALOG_RX), Input.get_joy_axis(0, JOY_ANALOG_RY)).normalized())
    #self.set_global_position(player.get_global_transform().get_origin())
    
func init_player(player):
  self.player = player
