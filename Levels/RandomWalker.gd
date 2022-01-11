extends Node2D

signal path_completed

# this step otptions here control direction and frequency
const STEP := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.UP]

# Use the Rooms scene to generate rooms
export (PackedScene) var Rooms := preload("Rooms.tscn")
onready var camera = $Camera2D
onready var timer = $Timer
onready var level: TileMap = $Level

export var grid_size := Vector2(3, 5)

var _rooms: Node2D = null
var _rng := RandomNumberGenerator.new()

var _state:= {}
var _horizontal_chance := 0.0

func _ready():
	_rng.randomize()
	_rooms = Rooms.instance();

	# calc the chance of moving horizontally
	_horizontal_chance = 1.0 - STEP.count(Vector2.UP) / float(STEP.size())

	_setup_camera()
	_generate_level()

func _setup_camera() -> void:
	var world_size := _grid_to_world(grid_size)
	camera.position = world_size / 2

	var ratio := world_size / OS.window_size
	var zoom_max := max(ratio.x, ratio.y) + 1
	camera.zoom = Vector2(zoom_max, zoom_max)

func _generate_level() -> void:
	_reset()
	_update_start_position()
	while _state.offset.y < grid_size.y:
		_update_room_type()
		_update_next_position()
		_update_down_counter()

	_place_walls()
	_place_path_rooms()
	_place_side_rooms()

func _reset() -> void:
	_state = {
		"random_index": -1, # index to pick a direction form the STEP array 
		"offset": Vector2.ZERO # curr position on grid
		"delta": Vector2.ZERO # direction to inc the offset key
		"up_counter": 0, # the num of times the walker moved up wo interruption
		"path": [], # the level's unobstructed path
		"empty_cells": {} # coords of the cells we have yet to populate 
	}
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			_state.empty_cells[Vector2(x,y)] = 0

func _update_start_position() -> void:
	var x := _rng.randi_range(0, grid_size.x - 1)
	_state.offset = Vector2(x, 0)

func _update_room_type() -> void:
	if not _state.path.empty():
		var last: Dictionary = _state.path.back()

		# unused special case check
		""" if last.type in _rooms.BOTTOM_CLOSED and _state.delta.is_equal_approx(Vector2.DOWN):
			var index := _rng.randi_range(0, _rooms.BOTTOM_OPENED.size() - 1)
			var type := int = (
				_rooms.BOTTOM_OPENED[index]
				if _state.down_counter < 2
				else _rooms.RoomType.TDLR
				)
				_state.path[-1].type = type """

	var type: int (
		_rooms.RoomType.TDL
		if(state.delta.is_equal_approx(Vector2.DOWN)
		else _rng.randi_range(1, _rooms.RoomType.size() - 1)
	)

	_state.empty_celsl.erase(_state.offset)
	_state.path.push_back({"offset": _state.offset, "type": type})

	