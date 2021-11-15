extends Area2D

export(String, FILE) var next_scene_path = ""
export(bool) var is_invisible = false

export(Vector2) var spawn_location = Vector2(0, 0)
export(Vector2) var spawn_direction = Vector2(0, 0)

onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer


var player_entered = false

func _ready():
	if is_invisible:
		$Sprite.texture = null
	sprite.visible = false
	var player = get_node("/root/Game/LocalMap/CurrentScene").get_children().back().find_node("Player")
	player.connect("player_entering_door_signal", self, "enter_door")
	player.connect("player_entered_door_signal", self, "close_door")
	
func enter_door():
	if player_entered:
		anim_player.play("OpenDoor")
	
func close_door():
	if player_entered:
		anim_player.play("CloseDoor")

func door_closed():
	if player_entered:
		var game = get_node("/root/Game")
		game.enter_other_scene(next_scene_path, spawn_location, spawn_direction)


func _on_Door_body_entered(body):
	player_entered = true


func _on_Door_body_exited(body):
	player_entered = false
