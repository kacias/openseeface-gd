extends Node

const DYNAMIC_PHYSICS_BONES: bool = false

const ENV_VAR_NAME: String = "VSS_ENV"
const ENVS: Dictionary = {
	"DEFAULT": "default",
	"TEST": "test"
}

# TODO currently unused
# onready var tm: TranslationManager = TranslationManager.new()
onready var sb: SignalBroadcaster = load("res://utils/SignalBroadcaster.gd").new()
onready var cm: ConfigManager = load("res://utils/ConfigManager.gd").new()

# These must be initialized AFTER ConfigManager since they need to pull config data
var nm: NotificationManager = load("res://utils/NotificationManager.gd").new()
var lsm: LipSyncManager = load("res://utils/LipSyncManager.gd").new()
var rcm: RemoteControlManager = load("res://utils/RemoteControlManager.gd").new()

onready var logger: Logger = load("res://utils/Logger.gd").new()

# Debounce
const DEBOUNCE_TIME: float = 5.0
var debounce_counter: float = 0.0
var should_save := false
var config_to_save: Reference

var main: MainScreen
var env: String = ENVS.DEFAULT

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	self.connect("tree_exiting", self, "_on_tree_exiting")

	var system_env = OS.get_environment(ENV_VAR_NAME)
	if system_env:
		env = system_env

	# if not OS.is_debug_build():
	# 	save_directory_path = OS.get_executable_path().get_base_dir()
	# else:
	# 	save_directory_path = "res://export"
		# Run unit tests
#		var goth = load("res://addons/goth/GOTH.gd").new()
#		goth.run_unit_tests()
		# goth.run_bdd_tests()

	cm.setup()
	add_child(nm)
	add_child(lsm)
	add_child(rcm)

func _process(delta: float) -> void:
#	rtls.poll()
	if should_save:
		debounce_counter += delta
		if debounce_counter > DEBOUNCE_TIME:
			debounce_counter = 0.0
			should_save = false
			cm.save_config(config_to_save)

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_tree_exiting() -> void:
	OpenSeeGd.stop_receiver()
	rcm.shutdown()

	if env != AppManager.ENVS.TEST:
		cm.save_config()
	
	logger.info("Exiting. おやすみ。")

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func save_config(p_config: Reference = null) -> void:
	"""
	Start saving config based off a debounce time
	
	If p_config is null, will save the current config in use
	"""
	should_save = true
	config_to_save = p_config

func save_config_instant(p_config: Reference = null) -> void:
	"""
	Immediately save config and stop debouncing if in progress
	
	If p_config is null, will save the current config in use
	"""
	should_save = false
	debounce_counter = 0.0
	cm.save_config(p_config)


