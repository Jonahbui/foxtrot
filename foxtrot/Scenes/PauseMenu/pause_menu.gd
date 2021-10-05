extends CanvasLayer

func _ready():
  if($UI.visible):
    Globals.isGamePaused = true
  else:
    Globals.isGamePaused = false

func _input(event):
  if event.is_action_released("ui_cancel"):
    Globals.isGamePaused = !Globals.isGamePaused
    if(Globals.isGamePaused):
      $UI.show()
    else:
      $UI.hide()

func _on_ResumeButton_pressed():
  Globals.isGamePaused = false
  $UI.hide()
  $SettingsMenu/UI.hide()  

func _on_SettingsButton_pressed():
  $UI.hide()
  $SettingsMenu/UI.show()  

func _on_MainMenuButton_pressed():
  get_tree().change_scene("res://Scenes/MainMenu/main_menu.tscn")

func _on_ExitButton_pressed():
  get_tree().quit()

func _on_SettingsBackButton_pressed():
  $UI.show()
  $SettingsMenu/UI.hide()
