extends Node

# Define config constants
const VOLUME_MASTER = "masterVolume"
const VOLUME_MUSIC = "musicVolume"
const VOLUME_SFX  = "sfxVolume"
const VOLUME_MASTER_TOGGLE  = "masterVolumeToggle"
const VOLUME_MUSIC_TOGGLE  = "musicVolumeToggle"
const VOLUME_SFX_TOGGLE  = "sfxVolumeToggle"

# Define save constants
const PLAYER_NAME   = "playerName"
const PLAYER_HEALTH = "playerHealth"
const PLAYER_MONEY  = "playerMoney"

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
const LPATH_SPAWN = "res://Scenes/Gameplay/Spawn.tscn"
const LPATH_TEST = "res://Scenes/Gameplay/Test.tscn"

## Mainly used for dev console to verify that the path selected is one that the 
## player should be allowed to switch to.
const LEVEL_PATH = [
  LPATH_SPAWN,
  LPATH_TEST
 ]

# --------------------------------------------------------------------------------------------------
# Gameplay Management
# --------------------------------------------------------------------------------------------------

# TA: to remove since we added pause_flags
var isGamePlaying : bool = false
var isNewGame     : bool = false
var isHardcoreMode: bool = false

# Possible pause 'like' events that can occur
const FLAG_DEV_OPEN = 1
const FLAG_PAUSED = 2
const FLAG_INTERACTING = 4
const FLAG_INVENTORY = 8

# This variable is used to determine whether the game should is in a certain
# state of pause. If it is not paused at all, then the value of this variable
# should be 0. However, if any of it's bits are equal to one, then the game is
# paused in some way
var pause_flags : int = 0

func SetFlag(flag, state):
  if state:
    pause_flags |= flag
  else:
    pause_flags &= (~flag)

func IsFlagSet(flag):
  return flag == (flag&pause_flags)

func ToggleFlag(flag):
  # Param(s) :
  #   - flag: the flag you want to toggle
  # Purpose  :
  #   Toggles the bit represented by 'flag' on pause_flag.
  # Return(s):
  #   A bool representing the new state of the flag passed in.
  
  var result = !IsFlagSet(flag)
  SetFlag(flag, result)
  return result

enum ItemProcess{
  World,
  Player
 }
