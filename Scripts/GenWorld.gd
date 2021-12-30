extends Node2D
# TODO: automate by fetching world size?
# !Holy cow I'm so sorry about all the literals

const Player = preload("res://Scenes/Player.tscn")
const Exit = preload("res://Scenes/Stairway.tscn")
# these numbers come from the size of the starting world
var borders = Rect2(1, 1, 43, 26)

onready var tileMap = $TileMap

func _ready():
	randomize()
	generate_level()

func generate_level():
	# 64 here is the grid size
	var gridSize = 64

	var walker = GenWalker.new(Vector2(21, 13), borders)
	
	#this var can be tweaked to generate bigger rooms
	var map = walker.walk(200)

	# create player & set positon
	var player = Player.instance()
	add_child(player)
	player.position = map.front() * gridSize

	var exit = Exit.instance()
	add_child(exit)
	exit.position = walker.get_end_room().position * gridSize
	exit.connect("next_level", self, "reload_level")

	walker.queue_free()
	for location in map:
		tileMap.set_cellv(location, -1)
	tileMap.update_bitmask_region(borders.position, borders.end)

func reload_level():
	get_tree().reload_current_scene()
