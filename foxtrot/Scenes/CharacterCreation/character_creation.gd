extends Node2D

func _on_StartButton_pressed():
  $UI/PopupMenu.popup()

func _on_ConfirmButton_pressed():
  get_tree().change_scene("res://Scenes/Gameplay/Base.tscn")

func _on_CancelButton_pressed():
  $UI/PopupMenu.hide()
