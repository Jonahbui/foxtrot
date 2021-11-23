extends Node

export(String, FILE) var button_down
export(String, FILE) var button_up

func PlayAudio(clip, source):
  # Purpose   : Plays sounds
  # Param(s)  : 
  # - clip    : the absolute project path of the clip to play
  # - source  : the desired audio source in which to play the clip (0-3
  # Return(s) : N/A
  
  # Load the clip to be played
  var audio = load(clip)
  
  # 0: for music
  # 1: for sound effects
  # 2: for ambient background music/ sounds
  # 3: for UI sounds
  
  if audio:
    match source:
      0:
        $MusicStream.stream = audio
        $MusicStream.play()
      1:
        $SFXStream.stream = audio
        $SFXStream.play()
      2:
        $AmbienceStream.stream = audio
        $AmbienceStream.play()
      3:
        $UIStream.stream = audio
        $UIStream.play()
      _:
        pass
  else:
    printerr("[Base] Error. Could not play \"%s\"" % [clip])

func KillAudio():
  # Purpose   : Stops all playing audio
  # Param(s)  : N/A
  # Return(s) : N/A
  $MusicStream.stop()
  $SFXStream.stop()
  $AmbienceStream.stop()
  $UIStream.stop()
  
func _on_button_down():
  # Purpose   : Used to play a button sound when clicked
  # Param(s)  : N/A
  # Return(s) : N/A
  PlayAudio(button_down, 3)

func _on_button_up():
  # Purpose   : Used to play a button sound when released
  # Param(s)  : N/A
  # Return(s) : N/A
  
  # There is a possibility that the player can click and almost instantenously let go of the LMB.
  # If that occurs, then the sound played on LMB down will not be heard. We should wait until that
  # finishes before we play the LMB up sound.
  while $UIStream.playing:
    yield(get_tree(), "idle_frame")
  PlayAudio(button_up, 3)

func _on_tab_clicked(tab : int):
  # Purpose   : Used to play a sound when a tab is clicked
  # Param(s)  : N/A
  # Return(s) : N/A
  _on_button_down()
  _on_button_up()
