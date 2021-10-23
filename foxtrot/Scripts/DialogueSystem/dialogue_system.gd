extends CanvasLayer

const FILENAME_DIALOGUE_EN = "dialogue_system_en"

var dialogue = null
var current_dialogue_id : String

func _init():
  
  pass

func ReadDialogue():
  # Check for file existance before reading
  var file = File.new()
  if not file.file_exists("res://Scripts/DialogueSystem/%s" % [FILENAME_DIALOGUE_EN]): return null
  
  # Read in the config file
  file.open("res://Scripts/DialogueSystem/%s" % [FILENAME_DIALOGUE_EN], File.READ)
  var text = file.get_as_text()
  var data = parse_json(text)
  if data == null: return null
  
  # Insert the data into the config (Do not set config equal to data. People may
  # insert their own values) dictionary.
  dialogue = data
    
  print("\n[Dialogue System] Loading dialogue...")
  print("[Dialogue System] Dialogue: %s" % [dialogue])
  

func ToggleDialogueBox(force_set=false, value=false):
  if force_set:
    $DialogueBox.visible = value
  else :
    $DialogueBox.visible = !$DialogueBox.visible

func SetDialogueBox(id):
  # Update which dialogue the game is on
  current_dialogue_id = id
  
  # Set the text for the current dialgoue
  var curr_dialogue = dialogue[current_dialogue_id]
  $DialogueBox/Log.text = curr_dialogue["text"]
  ToggleDialogueBox(true, true)
  
  # If the dialogue features options, then list out those options
  if curr_dialogue["next"] == "":
    pass
  # Else do not show any options
  else:
    pass
