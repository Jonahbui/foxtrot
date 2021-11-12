extends Node

export(String, FILE) var button_down
export(String, FILE) var button_up

func PlayAudio(clip, source):
  var audio = load(clip)
  
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
  else:
    printerr("[Base] Error. Could not play \"%s\"" % [clip])


func _on_button_down():
  PlayAudio(button_down, 3)

func _on_button_up():
  # There is a possibility that the player can click and almost instantenously let go of the LMB.
  # If that occurs, then the sound played on LMB down will not be heard. We should wait until that
  # finishes before we play the LMB up sound.
  while $UIStream.playing:
    yield(get_tree(), "idle_frame")
  PlayAudio(button_up, 3)

func _on_tab_clicked(tab : int):
  _on_button_down()
  _on_button_up()
