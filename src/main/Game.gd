# Responsible for transitions between the main game screens:
# combat, game over, and the map
extends Node

signal combat_started
var next_scene = null

const combat_arena_scene = preload("res://src/combat/CombatArena.tscn")
onready var transition = $Overlays/TransitionColor
onready var local_map = $LocalMap
onready var party = $Party as Party
onready var music_player = $MusicPlayer
onready var game_over_interface := $GameOverInterface
onready var gui := $GUI

var transitioning = false
var combat_arena: CombatArena

var player_location = Vector2(0, 0)
var player_direction = Vector2(0, 0)



func _ready():
	QuestSystem.initialize(self, party)
	local_map.spawn_party(party)
	local_map.visible = true
	local_map.connect("enemies_encountered", self, "enter_battle")


	
func enter_party_screen():
	if transitioning:
		return
	transitioning = true
	yield(transition.fade_to_color(),"completed")
	$Menu.load_party_screen()
	yield(transition.fade_from_color(),"completed")
	transitioning = false

func quit_party_screen():
	if transitioning:
		return
	transitioning = true
	yield(transition.fade_to_color(),"completed")
	$Menu.unload_party_screen()
	yield(transition.fade_from_color(),"completed")
	transitioning = false
	
	
func enter_other_scene(new_scene,spawn_location,spawn_direction):
	next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction
	
	if transitioning:
		return

	gui.hide()

	transitioning = true
	yield(transition.fade_to_color(), "completed")
	$LocalMap/CurrentScene.get_child(0).queue_free()
	$LocalMap/CurrentScene.add_child(load(next_scene).instance())
			
	var player = get_node("/root/Game/LocalMap/CurrentScene").get_children().back().find_node("Player")
	player.set_spawn(player_location, player_direction)

	yield(transition.fade_from_color(), "completed")
	transitioning = false

func enter_battle(formation: Formation):
	# Plays the combat transition animation and initializes the combat scene
	if transitioning:
		return

	gui.hide()
	music_player.play_battle_theme()

	transitioning = true
	yield(transition.fade_to_color(), "completed")

	remove_child(local_map)
	combat_arena = combat_arena_scene.instance()
	add_child(combat_arena)
	combat_arena.connect("victory", self, "_on_CombatArena_player_victory")
	combat_arena.connect("game_over", self, "_on_CombatArena_game_over")
	combat_arena.connect(
		"battle_completed", self, "_on_CombatArena_battle_completed", [combat_arena]
	)
	combat_arena.initialize(formation, party.get_active_members())

	yield(transition.fade_from_color(), "completed")
	transitioning = false

	combat_arena.battle_start()
	emit_signal("combat_started")


func _on_CombatArena_battle_completed(arena):
	# At the end of an encounter, fade the screen, remove the combat arena
	# and add the local map back
	gui.show()

	transitioning = true
	yield(transition.fade_to_color(), "completed")
	combat_arena.queue_free()

	add_child(local_map)
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	music_player.stop()


func _on_CombatArena_player_victory():
	music_player.play_victory_fanfare()


func _on_CombatArena_game_over() -> void:
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	game_over_interface.display(GameOverInterface.Reason.PARTY_DEFEATED)
	yield(transition.fade_from_color(), "completed")
	transitioning = false


func _on_GameOverInterface_restart_requested():
	game_over_interface.hide()
	var formation = combat_arena.initial_formation
	combat_arena.queue_free()
	enter_battle(formation)
