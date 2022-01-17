extends Node2D

# This type must corispond to the room layout in the Rooms Scene 
enum RoomType { LR, LRB, LRT, LRTB, SIDE }
# Tile types 
enum Cell {FACE_SM, BLOCK1, BLOCK2, BLOCK_WALL, FACE_LG}

const TOP_OPENED := [RoomType.LRT, RoomType.LRTB]
const TOP_CLOSED := [RoomType.LR, RoomType.LRB]

const CELL_MAP := {
  Cell.FACE_SM: {"chance": 1.0, "cell": [[Cell.FACE_SM]], "size": Vector2.ONE},
  Cell.BLOCK1: {"chance": 1.0, "cell": [[Cell.BLOCK1]], "size": Vector2.ONE},
  Cell.BLOCK2: {"chance": 1.0, "cell": [[Cell.BLOCK2]], "size": Vector2.ONE},
  Cell.BLOCK_WALL: {"chance": 1.0, "cell": [[Cell.BLOCK_WALL]], "size": Vector2.ONE},
  Cell.FACE_LG: {"chance": 1.0, "cell": [[Cell.FACE_LG]], "size": Vector2(3, 3)}
}

var room_size := Vector2.ZERO
var cell_size := Vector2.ZERO

var _rng := RandomNumberGenerator.new()

# initialize the size parameters and get a random seed on init
func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_INSTANCED:
		_rng.randomize()

		var room: TileMap = $LR.get_child(0)
		room_size = room.get_used_rect().size
		cell_size = room.cell_size


# this func will return room data of a specific room type in the form of a Dictionary
func get_room_data(type: int) -> Dictionary:
	var group: Node2D = get_child(type)
	var index := _rng.randi_range(0, group.get_child_count() - 1)
	var room: TileMap = group.get_child(index)

	var data := {"objects": [], "tilemap": []}
	for object in room.get_children():
		data.objects.push_back(object)
	
	for v in room.get_used_cells():
		if not room.get_cellv(v) in range(0, CELL_MAP.size() - 1):
			print("Could not read cellv:", v)
			continue
		var mapping: Dictionary = CELL_MAP[room.get_cellv(v)]
		if _rng.randf() > mapping.chance:
			continue

		for x in range(mapping.size.x):
			for y in range(mapping.size.y):
				data.tilemap.push_back({"offset": v + Vector2(x, y), "cell": mapping.cell[x][y]})
	return data
