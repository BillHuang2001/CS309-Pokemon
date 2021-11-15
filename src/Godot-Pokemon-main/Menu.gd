extends CanvasLayer

const PokemonPartyScreen = preload("res://src/Godot-Pokemon-main/PokemonPartyScreen.tscn")

onready var select_arrow = $Control/NinePatchRect/TextureRect
onready var menu = $Control

enum ScreenLoaded { NOTHING, JUST_MENU, PARTY_SCREEN, }
var screen_loaded = ScreenLoaded.NOTHING

var selected_option: int = 0

func _ready():
	menu.visible = false
	select_arrow.rect_position.y = 6 + (selected_option % 6) * 15

func load_party_screen():
	menu.visible = false
	screen_loaded = ScreenLoaded.PARTY_SCREEN
	var party_screen = PokemonPartyScreen.instance()
	add_child(party_screen)
	
	
func unload_party_screen():
	menu.visible = true
	screen_loaded = ScreenLoaded.JUST_MENU
	remove_child($PokemonPartyScreen)

func _unhandled_input(event):
	match screen_loaded:
		ScreenLoaded.NOTHING:
			if event.is_action_pressed("ui_accept"):
				var player = get_node("/root/Game/LocalMap/CurrentScene").get_children().back().find_node("Player")
				if !player.is_moving:
					player.set_physics_process(false)
					menu.visible = true
					screen_loaded = ScreenLoaded.JUST_MENU
		
		ScreenLoaded.JUST_MENU:
			if event.is_action_pressed("ui_accept") or event.is_action_pressed("x"):
				var player = get_node("/root/Game/LocalMap/CurrentScene").get_children().back().find_node("Player")
				player.set_physics_process(true)
				menu.visible = false
				screen_loaded = ScreenLoaded.NOTHING
				
			elif event.is_action_pressed("ui_down"):
				selected_option += 1
				select_arrow.rect_position.y = 6 + (selected_option % 6) * 15
				
			elif event.is_action_pressed("ui_up"):
				if selected_option == 0:
					selected_option = 5
				else:
					selected_option -= 1
				select_arrow.rect_position.y = 6 + (selected_option % 6) * 15
			elif event.is_action_pressed("z"):
				var game = get_node("/root/Game")
				game.enter_party_screen()
			
		ScreenLoaded.PARTY_SCREEN:
			if event.is_action_pressed("x"):
				var game = get_node("/root/Game")
				game.quit_party_screen()
