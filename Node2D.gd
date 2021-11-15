extends Node2D

# Declare member variables here. Examples:
# Called when the node enters the scene tree for the first time.
func _ready():
	var backgrounds = []
	var dir = Directory.new()
	dir.open('res://assets/battle/Background/')
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with('png'):
			backgrounds.append('res://assets/battle/Background/' + file_name)
		file_name = dir.get_next()
	dir.list_dir_end ()
	var bg_idx = randi() % len(backgrounds)
	print(bg_idx)
	$Background.set_texture(load(backgrounds[bg_idx]))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
