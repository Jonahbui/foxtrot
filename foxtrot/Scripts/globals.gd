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
var isGamePlaying : bool = false
var isNewGame     : bool = false
var isGamePaused  : bool = false
var isPlayerDead  : bool = false
var isHardcoreMode: bool = false
var isDevConsoleOpen: bool = false

enum source{
  music,
  sfx
 }

enum clips{
  pop
 }
