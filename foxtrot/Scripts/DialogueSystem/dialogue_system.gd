extends CanvasLayer

const FILENAME_DIALOGUE_EN = "dialogue_en.json"

const DIALOGUE_TEXT = "text"
const DIALOGUE_NEXT = "next"
const DIALOGUE_OPTIONS = "options"
const DIALOGUE_ACTOR = "actor"
const DIALOGUE_ACTOR_NAME = "name"
const DIALOGUE_ACTOR_SPRITE = "sprite"

# Used to determine if the player is currently given a choice in the current dialogue
var is_choosing_option : bool = false

# The dialogue JSON
var dialogue = null

# The current dialogue being processed
var current_dialogue_id : String

func _input(event):
  if $DialogueBox.visible && event.is_action_pressed("dialogue_continue") && !is_choosing_option:
    OnNextDialogue()

func _init():
  ReadDialogue()
  Signals.connect("on_dialogue_trigger", self, "SetDialogueBox")


# --------------------------------------------------------------------------------------------------
# Dialogue Functions
# --------------------------------------------------------------------------------------------------
func ReadDialogue():
  print("\n[Dialogue System] Loading dialogue...")
  # Check for file existance before reading
  var file = File.new()
  if not file.file_exists("res://Scripts/DialogueSystem/%s" % [FILENAME_DIALOGUE_EN]): 
    print("[Dialogue System] Dialogue file does not exist. Aborting...")
    return null
  
  # Read in the config file
  file.open("res://Scripts/DialogueSystem/%s" % [FILENAME_DIALOGUE_EN], File.READ)
  var text = file.get_as_text()
  var data = parse_json(text)
  if data == null: 
    return null
  
  # Insert the data into the config (Do not set config equal to data. People may
  # insert their own values) dictionary.
  dialogue = data
  for key in dialogue:
    if dialogue[key][DIALOGUE_OPTIONS].size() > 0:
      for num in dialogue[key][DIALOGUE_OPTIONS]:
        dialogue[key][DIALOGUE_OPTIONS][int(num)] = dialogue[key][DIALOGUE_OPTIONS][num]
    
  #print("[Dialogue System] Dialogue: %s" % [dialogue])

func ToggleDialogueBox(force_set=false, value=false):
  if force_set:
    $DialogueBox.visible = value
  else :
    $DialogueBox.visible = !$DialogueBox.visible
    
  Globals.SetFlag(Globals.FLAG_INTERACTING, $DialogueBox.visible)

func SetDialogueBox(id):
  if id == "":
    ToggleDialogueBox(true, false)
    Signals.emit_signal("on_dialogue_exited")
    return
  
  # Update which dialogue the game is on
  current_dialogue_id = id
  
  # Set the text for the current dialgoue
  var curr_dialogue = dialogue[current_dialogue_id]
  $DialogueBox/Log.text = curr_dialogue[DIALOGUE_TEXT]
  ToggleDialogueBox(true, true)
  
  # Set the photo for the entity speaking/displaying a message
  $DialogueBox/ActorFrame/ActorPhoto.texture = load(dialogue[current_dialogue_id][DIALOGUE_ACTOR][DIALOGUE_ACTOR_SPRITE])
  $DialogueBox/ActorFrame/ActorName.text = dialogue[current_dialogue_id][DIALOGUE_ACTOR][DIALOGUE_ACTOR_NAME]
  
  # If the dialogue features options, then list out those options
  if curr_dialogue[DIALOGUE_OPTIONS].size() > 0:
    is_choosing_option = true
    if curr_dialogue[DIALOGUE_OPTIONS].has(3):
      $DialogueBox/Options/Button0.visible  = true
      $DialogueBox/Options/Button1.visible  = true
      $DialogueBox/Options/Button2.visible  = true
      $DialogueBox/Options/Button3.visible  = true  
      
      $DialogueBox/Options/Button0.text  = curr_dialogue[DIALOGUE_OPTIONS][0][0]
      $DialogueBox/Options/Button1.text  = curr_dialogue[DIALOGUE_OPTIONS][1][0]
      $DialogueBox/Options/Button2.text  = curr_dialogue[DIALOGUE_OPTIONS][2][0]
      $DialogueBox/Options/Button3.text  = curr_dialogue[DIALOGUE_OPTIONS][3][0]
    elif curr_dialogue[DIALOGUE_OPTIONS].has(2):
      $DialogueBox/Options/Button0.visible  = true
      $DialogueBox/Options/Button1.visible  = true
      $DialogueBox/Options/Button2.visible  = true
      $DialogueBox/Options/Button3.visible  = false  

      $DialogueBox/Options/Button0.text  = curr_dialogue[DIALOGUE_OPTIONS][0][0]
      $DialogueBox/Options/Button1.text  = curr_dialogue[DIALOGUE_OPTIONS][1][0]
      $DialogueBox/Options/Button2.text  = curr_dialogue[DIALOGUE_OPTIONS][2][0]
    elif curr_dialogue[DIALOGUE_OPTIONS].has(1):
      $DialogueBox/Options/Button0.visible  = true
      $DialogueBox/Options/Button1.visible  = true
      $DialogueBox/Options/Button2.visible  = false
      $DialogueBox/Options/Button3.visible  = false  

      $DialogueBox/Options/Button0.text  = curr_dialogue[DIALOGUE_OPTIONS][0][0]
      $DialogueBox/Options/Button1.text  = curr_dialogue[DIALOGUE_OPTIONS][1][0]
    else:
      $DialogueBox/Options/Button0.visible  = true
      $DialogueBox/Options/Button1.visible  = false
      $DialogueBox/Options/Button2.visible  = false
      $DialogueBox/Options/Button3.visible  = false  
  
      $DialogueBox/Options/Button0.text  = curr_dialogue[DIALOGUE_OPTIONS][0][0]

  # Else do not show any options
  else:
    is_choosing_option = false
    $DialogueBox/Options/Button0.visible  = false
    $DialogueBox/Options/Button1.visible  = false
    $DialogueBox/Options/Button2.visible  = false
    $DialogueBox/Options/Button3.visible  = false
    
func OnOptionSelect(choice_id:int):
  var next_dialogue = dialogue[current_dialogue_id][DIALOGUE_OPTIONS][str(choice_id)][1]
  SetDialogueBox(next_dialogue)

func OnNextDialogue():
  var next_dialogue = dialogue[current_dialogue_id][DIALOGUE_NEXT]
  SetDialogueBox(next_dialogue)

