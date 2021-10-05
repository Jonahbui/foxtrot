extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
  $Credits/Background.hide()
  $SettingsMenu/Background.hide()

func _on_NewGameButton_pressed():
  pass # Replace with function body.

func _on_LoadGameButton_pressed():
  pass # Replace with function body.

func _on_SettingsButton_pressed():
  $MainMenu/Background.hide()
  $SettingsMenu/Background.show()
  $Credits/Background.hide()

func _on_ExitButton_pressed():
  get_tree().quit()

# Used to open up the credits. Note: the Credits.tscn is expected to be imported
# into the main menu scene.
func _on_CreditsButton_pressed():
  $MainMenu/Background.hide()
  $SettingsMenu/Background.hide()
  $Credits/Background.show()

func _on_SettingsBackButton_pressed():
  $MainMenu/Background.show()
  $SettingsMenu/Background.hide()
  $Credits/Background.hide()

func _on_CreditsBackButton_pressed():
  $MainMenu/Background.show()
  $SettingsMenu/Background.hide()
  $Credits/Background.hide()
