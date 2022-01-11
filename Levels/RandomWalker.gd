extends Node2D

signal path_completed

# this step otptions here control direction and frequency
const STEP := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.UP]

# Use the Rooms scene to generate rooms
export (PackedScene) var Rooms := preload("Rooms.tscn")
export var grid_size := Vector2(3, 5)

var _rooms: Node2D = null
var _rng := RandomNumberGenerator.new()
var _state:= {}
var _horizontal_chance := 0.0

onready var camera = $Camera2D
onready var timer = $Timer
onready var level: TileMap = $Level

func _ready() -> void:
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
		_update_up_counter()

	_place_walls()
	_place_path_rooms()
	_place_side_rooms()

func _grid_to_map(vector: Vector2) -> Vector2:
	return _rooms.room_size * vector

func _grid_to_world(vector: Vector2) -> Vector2:
	return _rooms.cell_size * _rooms.room_size * vector

func _reset() -> void:
	_state = {
		"random_index": -1, # index to pick a direction form the STEP array 
		"offset": Vector2.ZERO, # curr position on grid
		"delta": Vector2.ZERO, # direction to inc the offset key
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

# generating the first room type
func _update_room_type() -> void:
	if not _state.path.empty():
		var last: Dictionary = _state.path.back()

		# special case for consecutive up rooms
		if last.type in _rooms.BOTTOM_CLOSED and _state.delta.is_equal_approx(Vector2.UP):
			var index := _rng.randi_range(0, _rooms.BOTTOM_OPENED.size() - 1)
			var type: int = (
				_rooms.BOTTOM_OPENED[index]
				if _state.up_counter < 2
				else _rooms.RoomType.LRTB
				)
			_state.path[-1].type = type

	var type: int = (
		_rooms.RoomType.LRB
		if _state.delta.is_equal_approx(Vector2.UP)
		else _rng.randi_range(1, _rooms.RoomType.size() - 1)
	)

	_state.empty_cells.erase(_state.offset)
	_state.path.push_back({"offset": _state.offset, "type": type})

# advance the walker
func _update_next_position() -> void:
	# check to avoid moving to a visited cell
	_state.random_index = (
		_rng.randi_range(0, STEP.size() - 1)
		if _state.random_index < 0 
		else _state.random_index
	)
	# get direction from random_index in our const
	_state.delta = STEP[_state.random_index]

	var horizontal_chance := _rng.randf()
	if _state.delta.is_equal_approx(Vector2.LEFT):
		# move up when the 'left-boundry' of grid is reached
		# random_index = 0 => STEP = LEFT
		# random_index = 3 => STEP = UP
		_state.random_index = 0 if _state.offset.x > 1 and horizontal_chance < _horizontal_chance else 3
	elif _state.delta.is_equal_approx(Vector2.RIGHT):
		# random_index = 1 => STEP = RIGHT
		_state.random_index = 1 if _state.offset.x < grid_size.x - 1 and horizontal_chance < _horizontal_chance else 3
	else: 
		if _state.offset.x > 0 and _state.offset.x < grid_size.x - 1: # in this case we've just moved up
			_state.random_index = _rng.randi_range(0, STEP.size() - 1)
		elif _state.offset.x == 0: # hit 'left-boundry'
			_state.random_index = 1 if horizontal_chance < _horizontal_chance else 3
		elif _state.offset.x == grid_size.x - 1: # hit 'right-boundry'
			_state.random_index = 0 if horizontal_chance < _horizontal_chance else 3

	_state.delta = STEP[_state.random_index]
	_state.offset += _state.delta

func _update_up_counter() -> void:
	_state.down_counter = (
		_state.down_counter + 1
		if _state.delta.is_equal_approx(Vector2.DOWN)
		else 0
	)

func _place_walls(type: int = 0) -> void:
	var cell_grid_size := _grid_to_map(grid_size)
	# create left and right walls
	for x in [-1, cell_grid_size.x]:
		for y in range(-1, cell_grid_size.y + 1):
			level.set_cell(x, y, type)
	
	# create top and bottom floors
	for x in range(cell_grid_size.x + 1):
		for y in [-1, cell_grid_size.y]:
			level.set_cell(x, y, type)

func _place_path_rooms() -> void:
	for path in _state.path:
		yield(timer, "timeout") # visual for debug
		_copy_room(path.offset, path.type)
	emit_signal("path_completed")

func _place_side_rooms() -> void:
	yield(self, "path_completed")
	var rooms_max_index: int = _rooms.RoomType.size() - 1
	for key in _state.empty_cells:
		var type := _rng.randi_range(0, rooms_max_index)
		_copy_room(key, type)

func _copy_room(offset: Vector2, type: int) -> void:
	var map_offset := _grid_to_map(offset)
	var data: Array = _rooms.get_room_data(type)
	for item in data:
		level.set_cellv(map_offset + item.offset, item.cell)


