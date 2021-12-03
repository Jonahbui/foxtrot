extends Node

# Define config constants
const VOLUME_MASTER         = "masterVolume"
const VOLUME_MUSIC          = "musicVolume"
const VOLUME_SFX            = "sfxVolume"
const VOLUME_AMBIENCE       = "ambienceVolume"
const VOLUME_UI             = "userInterfaceVolume"
const VOLUME_MASTER_TOGGLE  = "masterVolumeToggle"
const VOLUME_MUSIC_TOGGLE   = "musicVolumeToggle"
const VOLUME_SFX_TOGGLE     = "sfxVolumeToggle"
const VOLUME_AMBIENCE_TOGGLE= "ambienceVolumeToggle"
const VOLUME_UI_TOGGLE      = "userInterfaceVolumeToggle"

# Define save constants
const PLAYER_DIFFICULTY   = "playerDifficulty"
const PLAYER_INVENTORY    = "playerInventory"
const PLAYER_NAME         = "playerName"
const PLAYER_HEALTH       = "playerHealth"
const PLAYER_MANA         = "playerMana"
const PLAYER_MONEY        = "playerMoney"

const COLOR_PRIMARY = "primary_color"
const COLOR_SECONDARY = "secondary_color"
const COLOR_BODY = "skin_color"

const GRAPHICS_FULLSCREEN = 'fullscreen'

# --------------------------------------------------------------------------------------------------
# Scene Management
# --------------------------------------------------------------------------------------------------

# Define scene resource paths
const SPATH_SPLASH_SCREEN = "res://Scenes/SplashScreen/SplashScreen.tscn"
const SPATH_MAIN_MENU = "res://Scenes/MainMenu/MainMenu.tscn"
const SPATH_CHARACTER_CREATION = "res://Scenes/CharacterCreation/CharacterCreation.tscn"
const SPATH_BASE = "res://Scenes/Gameplay/Base.tscn"

const SCENE_PATHS = [
  SPATH_SPLASH_SCREEN,
  SPATH_MAIN_MENU,
  SPATH_CHARACTER_CREATION,
  SPATH_BASE
 ]

# Define level resource paths (levels that the player play in)
const LPATH_AQUARIUM = "res://Scenes/Gameplay/Aquarium.tscn"
const LPATH_SPAWN = "res://Scenes/Gameplay/Spawn.tscn"
const LPATH_SEAFLOOR = "res://Scenes/Gameplay/Seafloor.tscn"
const LPATH_ATLANTIS = "res://Scenes/Gameplay/Atlantis.tscn"

## Mainly used for dev console to verify that the path selected is one that the 
## player should be allowed to switch to.
const LEVEL_PATH = [
  LPATH_AQUARIUM,
  LPATH_SPAWN,
  LPATH_SEAFLOOR,
  LPATH_ATLANTIS
 ]

# --------------------------------------------------------------------------------------------------
# Gameplay Management
# --------------------------------------------------------------------------------------------------
func Player():
  return self.get_tree().get_root().get_node_or_null("/root/Base/Player")
var is_in_spawn           : bool = false
var is_new_game           : bool = false 
var is_game_playing       : bool = false
var is_hardcore_mode      : bool = false setget set_hardcore, get_hardcore
var is_in_water           : bool = false


func set_hardcore(state):
  is_hardcore_mode = state
  Save.save[PLAYER_DIFFICULTY] = is_hardcore_mode

func get_hardcore():
  return is_hardcore_mode

# Possible pause 'like' events that can occur
const FLAG_DEV_OPEN = 1
const FLAG_PAUSED = 2
const FLAG_INTERACTING = 4
const FLAG_INVENTORY = 8
const FLAG_DEAD = 16

# This variable is used to determine whether the game should is in a certain
# state of pause. If it is not paused at all, then the value of this variable
# should be 0. However, if any of it's bits are equal to one, then the game is
# paused in some way
var pause_flags : int = 0

func SetFlag(flag, state):
  # Purpose   : Sets a pause flag to the desired state
  # Param(s)  :
  # - flag    : the flag to set the state
  # - state   : the bool state
  # Return(s) : N/A
  
  if state:
    pause_flags |= flag
  else:
    pause_flags &= (~flag)

func IsFlagSet(flag):
  # Purpose   : Checks if a given flag is set
  # Param(s)  :
  # - flag    : the flag to check
  # Return(s) : true if flag set, false otherwise
  
  return flag == (flag&pause_flags)

func ToggleFlag(flag):
  # Purpose  : Toggles the bit represented by 'flag' on pause_flag.
  # Param(s) :
  #   - flag: the flag you want to toggle
  # Return(s): A bool representing the new state of the flag passed in.
  
  var result = !IsFlagSet(flag)
  SetFlag(flag, result)
  return result

enum ItemProcess{
  Dynamic,
  Hidden,
  Active,
  Static
 }
