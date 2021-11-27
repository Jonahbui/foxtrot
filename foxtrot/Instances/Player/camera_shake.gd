extends Camera2D


var shake_time_remaining : float = 0.75
var shake_power : float = 6
var shake_fade_time : float = 0
var rotation_multiplier : float = 2
var shake_rotation : float = 0

var rng = null

func _ready():
  rng = RandomNumberGenerator.new()
  rng.randomize()

func start_shake(length, power):
  shake_time_remaining = length
  shake_power = power
  shake_fade_time = power/length
  shake_rotation = power * rotation_multiplier

func _physics_process(delta):
  if shake_time_remaining > 0:
    shake_time_remaining -= delta
    
    var x_amount = rng.randf_range(-0.1, 0.1) * shake_power
    var y_amount = rng.randf_range(-0.1, 0.1) * shake_power
    
    self.offset = Vector2(x_amount, y_amount)
    
    var vec_power = Vector2(shake_power, 0)
    var vec_rotation = Vector2(shake_rotation, 0)
    
    if shake_power > 0:
      shake_power -= shake_fade_time * delta
      if shake_power < 0: shake_power = 0
    
    if shake_rotation > 0:
      shake_rotation -= shake_fade_time * rotation_multiplier * delta
      if shake_rotation < 0: shake_rotation = 0
    
  self.rotation = shake_rotation*rng.randf_range(-0.1,0.1)
