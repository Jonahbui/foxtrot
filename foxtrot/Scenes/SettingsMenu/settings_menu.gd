extends CanvasLayer

var bus_layout = load("res://default_bus_layout.tres")

func _ready():
  AudioServer.set_bus_layout(bus_layout)
  LoadConfigToSettings()

func LoadConfigToSettings():
  # Set the volume settings to the ones in the config file
  $Background/AudioVbox/MasterVolume/MasterSlider.value = Save.config[Globals.VOLUME_MASTER]
  $Background/AudioVbox/MusicVolume/MusicSlider.value = Save.config[Globals.VOLUME_MUSIC]
  $Background/AudioVbox/SFXVolume/SFXSlider.value = Save.config[Globals.VOLUME_SFX]
  $Background/AudioVbox/MasterVolume/MasterSlider/MasterCheckbox.pressed = Save.config[Globals.VOLUME_MASTER_TOGGLE]
  $Background/AudioVbox/MusicVolume/MusicSlider/MusicCheckbox.pressed = Save.config[Globals.VOLUME_MUSIC_TOGGLE]
  $Background/AudioVbox/SFXVolume/SFXSlider/SFXCheckbox.pressed = Save.config[Globals.VOLUME_SFX_TOGGLE]
  
  $Background/GraphicsVbox/Fullscreen/FullscreenCheckBox.pressed = Save.config[Globals.GRAPHICS_FULLSCREEN]
  #bus_layout.instance()

# Note: the audio bus is arranged like so {0:master, 1:music, 2:sfx}

func _on_MasterSlider_value_changed(value):
  Save.config[Globals.VOLUME_MASTER] = value
  AudioServer.set_bus_volume_db(0, value)

func _on_MusicSlider_value_changed(value):
  Save.config[Globals.VOLUME_MUSIC] = value
  AudioServer.set_bus_volume_db(1, value)

func _on_SFXSlider_value_changed(value):
  Save.config[Globals.VOLUME_SFX] = value
  AudioServer.set_bus_volume_db(2, value)

func _on_MasterCheckbox_toggled(button_pressed):
  Save.config[Globals.VOLUME_MASTER_TOGGLE] = button_pressed
  AudioServer.set_bus_mute(0, button_pressed)

func _on_MusicCheckbox_toggled(button_pressed):
  Save.config[Globals.VOLUME_MUSIC_TOGGLE] = button_pressed
  AudioServer.set_bus_mute(1, button_pressed)

func _on_SFXCheckbox_toggled(button_pressed):
  Save.config[Globals.VOLUME_SFX_TOGGLE] = button_pressed
  AudioServer.set_bus_mute(2, button_pressed)

func _on_Reset_pressed():
  Save.reset_config()
  LoadConfigToSettings()
  AudioServer.set_bus_mute(0, Save.config[Globals.VOLUME_MASTER_TOGGLE])
  AudioServer.set_bus_mute(1, Save.config[Globals.VOLUME_MUSIC_TOGGLE])
  AudioServer.set_bus_mute(2, Save.config[Globals.VOLUME_SFX_TOGGLE])  

func _on_FullScreenCheckBox_toggled(button_pressed):
  OS.window_fullscreen = button_pressed
  Save.config[Globals.GRAPHICS_FULLSCREEN] = button_pressed
