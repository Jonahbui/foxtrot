# Settings menu will not work by itself inserted into a scene. The appropriate
# audio nodes need to be updated when the settings changes. Make an event.
# NOTE: may just need to update audio buses
extends CanvasLayer

var bus_layout = load("res://default_bus_layout.tres")

func _ready():
  LoadConfigToSettings()
  
func _on_MasterSlider_value_changed(value):
  Save.config[Globals.VOLUME_MASTER] = value

func _on_MusicSlider_value_changed(value):
  Save.config[Globals.VOLUME_MUSIC] = value

func _on_SFXSlider_value_changed(value):
  Save.config[Globals.VOLUME_SFX] = value

func _on_Reset_pressed():
  Save.reset_config()
  LoadConfigToSettings()

func LoadConfigToSettings():
  # Set the volume settings to the ones in the config file
  $Background/AudioVbox/MasterVolume/MasterSlider.value = Save.config[Globals.VOLUME_MASTER]
  $Background/AudioVbox/MusicVolume/MusicSlider.value = Save.config[Globals.VOLUME_MUSIC]
  $Background/AudioVbox/SFXVolume/SFXSlider.value = Save.config[Globals.VOLUME_SFX]
  
  #bus_layout.instance()
