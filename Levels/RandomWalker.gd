extends Node2D

signal path_completed
signal level_completed(player_position)

# this step otptions here control direction and frequency
const STEP := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.UP]

# Use the Rooms scene to generate rooms
export (PackedScene) var Rooms := preload("res://Levels/Rooms.tscn")
export var grid_size := Vector2(3, 5)

var _player: KinematicBody2D = null
var _rooms: Node2D = null
var _rng := RandomNumberGenerator.new()
var _state:= {}
var _horizontal_chance := 0.0
var _camera_limits := {}
var _resolution := OS.window_size
var _player_spawn: Vector2 = Vector2(0.0, 0.0)

onready var scene_tree: SceneTree = get_tree()
onready var camera: Camera2D = $Camera2D
onready var tween: Tween = $Camera2D/Tween
onready var level_main: TileMap = $Level/TileMapMain
onready var level_danger: TileMap = $Level/TileMapDanger
onready var level_extra: Node2D = $Level/Extra
onready var timer: Timer = $Timer
onready var background: ParallaxBackground = $ParallaxBackground
onready var timeloop = $TimeLoop

func _ready() -> void:
    timeloop.connect("restart", self, "on_Timer_restart")
    
    _rng.randomize()
    _rooms = Rooms.instance()
    _horizontal_chance = 1.0 - STEP.count(Vector2.DOWN) / float(STEP.size())
    
    _camera_limits = {
        "min": level_main.map_to_world(-Vector2.ONE),
        "max": level_main.map_to_world(_grid_to_map(grid_size) + Vector2.ONE)
    }

    camera.setup(_resolution, _grid_to_world(grid_size))
    # scene_tree.paused = true
    _generate_level()
    yield(self, "level_completed")
    scene_tree.paused = false

func _on_Camera2D_zoom_changed(zoom: Vector2) -> void:
    for n in background.get_children():
        n.modulate.a = 1 / zoom.x


func _on_Tween_tween_all_completed() -> void:
    _player.get_node("RemoteTransform2D").remote_path = camera.get_path()
    camera.limit_left = _camera_limits.min.x
    camera.limit_top = _camera_limits.min.y
    camera.limit_right = _camera_limits.max.x
    camera.limit_bottom = _camera_limits.max.y

func _generate_level() -> void:
    _reset()
    _update_start_position()
    _place_walls()
    
    while _state.offset.y > -1:
        _update_room_type()
        _update_next_position()
        _update_up_counter()

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

# Picks a random start position on the first row of the generation grid.
func _update_start_position() -> void:
    # warning-ignore: narrowing_conversion
    var x := _rng.randi_range(0, grid_size.x - 1)
    _state.offset = Vector2(x, grid_size.y - 1)

# Picks a room type to use on the cell the algorithm is currently visiting.
# Uses some rules to prevent the room from blocking the player.
func _update_room_type() -> void:
    if not _state.path.empty():
        var last: Dictionary = _state.path.back()

        # special case for consecutive up rooms
        if last.type in _rooms.TOP_CLOSED and _state.delta.is_equal_approx(Vector2.UP):
            var index := _rng.randi_range(0, _rooms.TOP_OPENED.size() - 1)
            var type: int = (
                _rooms.TOP_OPENED[index]
                if _state.up_counter < 2
                else _rooms.RoomType.LRTB
                )
            _state.path[-1].type = type

    var type: int = (
        _rooms.RoomType.LRB
        if _state.delta.is_equal_approx(Vector2.UP)
        else _rng.randi_range(0, _rooms.RoomType.size() - 2) # excluse SIDE from range
    )

    _state.empty_cells.erase(_state.offset)
    _state.path.push_back({"offset": _state.offset, "type": type})

# Picks the direction in which the generator should move to place the next room. This is
# semi-random: we pick a random direction only if that doesn't risk generating a broken path, and in
# such a way we prevent backtracking.
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
        _state.random_index = (
            0 
            if _state.offset.x > 1 and horizontal_chance < _horizontal_chance 
            else 2)
    elif _state.delta.is_equal_approx(Vector2.RIGHT):
        # random_index = 1 => STEP = RIGHT
        _state.random_index = (
            1 
            if _state.offset.x < grid_size.x - 1 and horizontal_chance < _horizontal_chance 
            else 2)
    else: 
        if _state.offset.x > 0 and _state.offset.x < grid_size.x - 1: # in this case we've just moved up
            _state.random_index = _rng.randi_range(0, STEP.size() - 1)
        elif _state.offset.x == 0: # hit 'left-boundry'
            _state.random_index = 1 if horizontal_chance < _horizontal_chance else 2
        elif _state.offset.x == grid_size.x - 1: # hit 'right-boundry'
            _state.random_index = 0 if horizontal_chance < _horizontal_chance else 2

    _state.delta = STEP[_state.random_index]
    # DEBUG 
    # print("Current walker position: ", _state.offset)
    _state.offset += _state.delta # check here

# Increments the `up_counter` every time the random walker moves downward.
func _update_up_counter() -> void:
    _state.up_counter = (
        _state.up_counter + 1
        if _state.delta.is_equal_approx(Vector2.UP)
        else 0
    )

# Walls here are used as the boarders for the entire level
func _place_walls(type: int = 1) -> void:
    var cell_grid_size := _grid_to_map(grid_size)

    for x in [-2, -1, cell_grid_size.x, cell_grid_size.x + 1]:
        for y in range(-2, cell_grid_size.y + 2):
            level_main.set_cell(x, y, type)

    for x in range(-1, cell_grid_size.x + 2):
        for y in [-2, -1, cell_grid_size.y, cell_grid_size.y + 1]:
            level_main.set_cell(x, y, type)

# These rooms make up the unobstructed path generated in the beginning
func _place_path_rooms() -> void:
    for path in _state.path:
        yield(timer, "timeout") # visual for debug
        _copy_room(path.offset, path.type, path == _state.path[0])
    emit_signal("path_completed")

# These are all rooms not on the path
func _place_side_rooms() -> void:
    yield(self, "path_completed")
    for key in _state.empty_cells:
        var type := _rng.randi_range(0, _rooms.RoomType.size() - 1)
        _copy_room(key, type, false)
        
    level_main.update_bitmask_region()
    emit_signal("level_completed", _player.position)

# copys room from Rooms onto main scene
func _copy_room(offset: Vector2, type: int, start: bool) -> void:
    var world_offset := _grid_to_world(offset)
    var map_offset := _grid_to_map(offset)
    var data: Dictionary = _rooms.get_room_data(type)
    
    # copy over all objects in the room excluding player
    for object in data.objects:
        if (not start and object.is_in_group("player")) or (start and object.is_in_group("enemy")):
            continue
        
        var new_object: Node2D = object.duplicate()
        new_object.position += world_offset
        level_extra.add_child(new_object)
        
        # code that puts the player in the world
        if start and new_object.is_in_group("player"):
            _player = new_object
            _player_spawn = _player.global_position
            print("Debug: player added in", offset)
    
    for d in data.tilemap:
        var tilemap := level_main 
        # if we add a danger level
        # if d.cell != _rooms.Cell.SPIKES else level_danger
        tilemap.set_cellv(map_offset + d.offset, d.cell)

func on_Timer_restart():
    print("restarted player position")
    _player.global_position = _player_spawn 
