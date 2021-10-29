extends CanvasLayer

export(NodePath) var masterSlider
export(NodePath) var musicSlider
export(NodePath) var sfxSlider
export(NodePath) var ambienceSlider

export(NodePath) var masterToggle
export(NodePath) var musicToggle
export(NodePath) var sfxToggle
export(NodePath) var ambienceToggle

export(NodePath) var fullscreenCheckbox
func _ready():
  masterSlider = get_node(masterSlider)
  musicSlider = get_node(musicSlider)
  sfxSlider = get_node(sfxSlider)
  ambienceSlider = get_node(ambienceSlider)
  
  masterToggle = get_node(masterToggle)
  musicToggle = get_node(musicToggle)
  sfxToggle = get_node(sfxToggle)
  ambienceToggle = get_node(ambienceToggle)
  
  fullscreenCheckbox = get_node(fullscreenCheckbox)
  LoadConfigToSettings()

func LoadConfigToSettings():
  # Set the volume settings to the ones in the config file.
  masterSlider.value = Save.config[Globals.VOLUME_MASTER]
  musicSlider.value = Save.config[Globals.VOLUME_MUSIC]
  sfxSlider.value = Save.config[Globals.VOLUME_SFX]
  ambienceSlider.value = Save.config[Globals.VOLUME_SFX]
  masterToggle.pressed = Save.config[Globals.VOLUME_MASTER_TOGGLE]
  musicToggle.pressed = Save.config[Globals.VOLUME_MUSIC_TOGGLE]
  sfxToggle.pressed = Save.config[Globals.VOLUME_SFX_TOGGLE]
  ambienceToggle.pressed = Save.config[Globals.VOLUME_SFX_TOGGLE]
  
  fullscreenCheckbox.pressed = Save.config[Globals.GRAPHICS_FULLSCREEN]

  # Note: updating the value of the sliders & checkboxes respectively with the 
  #   properties value and pressed will issue out signals indicating that their
  #   value has changed. So when we change the value of the slider, the
  #   according functions below will be called and those functions will update
  #   the AudioServer and the config file.
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

func _on_AmbienceSlider_value_changed(value):
  Save.config[Globals.VOLUME_AMBIENCE] = value
  AudioServer.set_bus_volume_db(3, value)

func _on_MasterCheckbox_toggled(button_pressed):
  Save.config[Globals.VOLUME_MASTER_TOGGLE] = button_pressed
  AudioServer.set_bus_mute(0, button_pressed)

func _on_MusicCheckbox_toggled(button_pressed):
  Save.config[Globals.VOLUME_MUSIC_TOGGLE] = button_pressed
  AudioServer.set_bus_mute(1, button_pressed)

func _on_SFXCheckbox_toggled(button_pressed):
  Save.config[Globals.VOLUME_SFX_TOGGLE] = button_pressed
  AudioServer.set_bus_mute(2, button_pressed)

func _on_AmbienceCheckbox_toggled(button_pressed):
  Save.config[Globals.VOLUME_AMBIENCE_TOGGLE] = button_pressed
  AudioServer.set_bus_mute(3, button_pressed)

func _on_Reset_pressed():
  Save.reset_config()
  LoadConfigToSettings()
  AudioServer.set_bus_mute(0, Save.config[Globals.VOLUME_MASTER_TOGGLE])
  AudioServer.set_bus_mute(1, Save.config[Globals.VOLUME_MUSIC_TOGGLE])
  AudioServer.set_bus_mute(2, Save.config[Globals.VOLUME_SFX_TOGGLE])  
  AudioServer.set_bus_mute(3, Save.config[Globals.VOLUME_AMBIENCE_TOGGLE])  

func _on_FullScreenCheckBox_toggled(button_pressed):
  OS.window_fullscreen = button_pressed
  Save.config[Globals.GRAPHICS_FULLSCREEN] = button_pressed
