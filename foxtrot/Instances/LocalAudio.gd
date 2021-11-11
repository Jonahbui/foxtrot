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
  while $UIStream.playing:
    yield(get_tree(), "idle_frame")
  PlayAudio(button_up, 3)
