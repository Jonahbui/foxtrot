extends CanvasLayer

# Text file to read dialogue from
const FILENAME_DIALOGUE_EN = "dialogue_en.json"

# Constants to access dictionary
const DIALOGUE_TEXT = "text"
const DIALOGUE_NEXT = "next"
const DIALOGUE_OPTIONS = "options"
const DIALOGUE_ACTOR = "actor"
const DIALOGUE_ACTOR_NAME = "name"
const DIALOGUE_ACTOR_SPRITE = "sprite"

# How fast to display text
var dialogue_text_speed = 0.2

# Used to determine if the player is currently given a choice in the current dialogue
var is_choosing_option : bool = false

# The dialogue JSON
var dialogue = null

# The current dialogue being processed
var current_dialogue_id : String

func _input(event):
  # If the dialogue is active and the player is not presented with any options to choose from, then
  # the 'dialogue_continue' action should just get the next available dialogue
  if $DialogueBox.visible && event.is_action_pressed("dialogue_continue") && !is_choosing_option:
    OnNextDialogue()

func _init():
  # Initialize the dialogue file
  ReadDialogue()
  
  # Opens up the dialogue to be interacted with
  if Signals.connect("on_dialogue_trigger", self, "SetDialogueBox") != OK:
    printerr("[Dialgoue] Error. Failed to connect to signal on_dialogue_trigger...")


# --------------------------------------------------------------------------------------------------
# Dialogue Functions
# --------------------------------------------------------------------------------------------------
func ReadDialogue():
  # Purpose   : Reads in the file that contains all the dialogue
  # Param(s)  : 
  # Return(s) : N/A
  print_debug("\n[Dialogue System] Loading dialogue...")
  # Check for file existance before reading
  var file = File.new()
  if not file.file_exists("res://Scripts/Dialogue/%s" % [FILENAME_DIALOGUE_EN]): 
    printerr("[Dialogue System] Dialogue file does not exist. Aborting...")
    return null
  
  # Read in the config file
  file.open("res://Scripts/Dialogue/%s" % [FILENAME_DIALOGUE_EN], File.READ)
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
    
  #print_debug("[Dialogue System] Dialogue: %s" % [dialogue])

func ToggleDialogueBox(force_set=false, value=false):
  # Purpose   : Turn on/off the dialogue UI
  # Param(s)  :
  # - forceState : set the visibility of the dialogue UI to state instead of toggling
  # - state   : the bool value to set the dialogue UI visibility
  # Return(s) : N/A
  if force_set:
    $DialogueBox.visible = value
  else :
    $DialogueBox.visible = !$DialogueBox.visible
    
  Globals.SetFlag(Globals.FLAG_INTERACTING, $DialogueBox.visible)

func SetDialogueBox(id):
  # Purpose   : Set the dialogue to the current id
  # Param(s)  :
  # - id      : the ID of the dialogue to activate
  # Return(s) : N/A
  
  # No more dialogue. Close
  if id == "":
    ToggleDialogueBox(true, false)
    Signals.emit_signal("on_dialogue_exited")
    return
  
  # Update which dialogue the game is on
  current_dialogue_id = id
  
  # Set the text for the current dialgoue
  var curr_dialogue = dialogue[current_dialogue_id]
  $DialogueBox/Log.text = curr_dialogue[DIALOGUE_TEXT]
  PrintDialogueAtSpeed(curr_dialogue)
  ToggleDialogueBox(true, true)
  
  # Set the photo for the entity speaking/displaying a message
  $DialogueBox/ActorFrame/ActorPhoto.texture = load(dialogue[current_dialogue_id][DIALOGUE_ACTOR][DIALOGUE_ACTOR_SPRITE])
  $DialogueBox/ActorFrame/ActorName.text = dialogue[current_dialogue_id][DIALOGUE_ACTOR][DIALOGUE_ACTOR_NAME]
  
  # If the dialogue features options, then list out those options
  if curr_dialogue[DIALOGUE_OPTIONS].size() > 0:
    is_choosing_option = true
    $DialogueBox/HintLabel.visible = false
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
    $DialogueBox/HintLabel.visible = true
    $DialogueBox/Options/Button0.visible  = false
    $DialogueBox/Options/Button1.visible  = false
    $DialogueBox/Options/Button2.visible  = false
    $DialogueBox/Options/Button3.visible  = false
    
func OnOptionSelect(choice_id:int):
  # Purpose   : Allows the user to select a dialogue option.
  # Param(s)  :
  # - choice_id : the ID of the selected choice (0-3)
  # Return(s) : N/A
  var next_dialogue = dialogue[current_dialogue_id][DIALOGUE_OPTIONS][str(choice_id)][1]
  SetDialogueBox(next_dialogue)

func OnNextDialogue():
  # Purpose   : Get the next dialogue available.
  # Param(s)  : N/A
  # Return(s) : N/A
  var next_dialogue = dialogue[current_dialogue_id][DIALOGUE_NEXT]
  SetDialogueBox(next_dialogue)

func PrintDialogueAtSpeed(text):
  # Purpose   : Displays the dialgogue text in a scrolling manner
  # Param(s)  : N/A
  # Return(s) : N/A
  var text_length = len(text)
  var label = $DialogueBox/Log
  var speed = text_length * dialogue_text_speed
  $DialogueBox/Tween.interpolate_property(label, "percent_visible", 0.0, 1.0, speed, Tween.TRANS_LINEAR, Tween.EASE_OUT)
  $DialogueBox/Tween.start()
  $DialogueBox/AudioStreamPlayer.playing = true
  yield($DialogueBox/Tween, "tween_all_completed")
  $DialogueBox/AudioStreamPlayer.playing = false
