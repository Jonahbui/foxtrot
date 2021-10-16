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

# Gameplay vars
# TA: to remove since we added pause_flags
var isGamePlaying : bool = false
var isNewGame     : bool = false
var isGamePaused  : bool = false
var isPlayerDead  : bool = false
var isHardcoreMode: bool = false
var isDevConsoleOpen: bool = false
var isInteracting : bool = false

const FLAG_DEV_OPEN = 1
const FLAG_PAUSED = 2
const FLAG_INTERACTING = 4

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

enum source{
  music,
  sfx
 }

enum clips{
  pop
 }


enum ItemProcess{
  World,
  Player
 }
