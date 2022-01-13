extends Node2D

# This type must corispond to the room layout in the Rooms Scene 
enum RoomType { LR, LRB, LRT, LRTB, SIDE }
enum Cell { WALLS, GROUND, VEGETATION, SPIKES, MAYBE_GROUND, MAYBE_BUSH, MAYBE_SPIKES, MAYBE_TREE }

const TOP_OPENED := [RoomType.LRT, RoomType.LRTB]
const TOP_CLOSED := [RoomType.LR, RoomType.LRB]

const CELL_MAP := {
  Cell.WALLS: {"chance": 1.0, "cell": [[Cell.WALLS]], "size": Vector2.ONE},
  Cell.GROUND: {"chance": 1.0, "cell": [[Cell.GROUND]], "size": Vector2.ONE},
  Cell.VEGETATION: {"chance": 0.0, "cell": [[Cell.VEGETATION]], "size": Vector2.ONE},
  Cell.SPIKES: {"chance": 0.0, "cell": [[Cell.SPIKES]], "size": Vector2.ONE},
  Cell.MAYBE_GROUND: {"chance": 0.7, "cell": [[Cell.GROUND]], "size": Vector2.ONE},
  Cell.MAYBE_BUSH: {"chance": 0.0, "cell": [[Cell.VEGETATION]], "size": Vector2.ONE},
  Cell.MAYBE_SPIKES: {"chance": 0.2, "cell": [[Cell.SPIKES]], "size": Vector2.ONE},
  Cell.MAYBE_TREE: # beeg tiles example
  {
	"chance": 0.0,
	"cell": [[Cell.VEGETATION, Cell.VEGETATION], [Cell.VEGETATION, Cell.VEGETATION]],
	"size": 2 * Vector2.ONE
  }
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
			continue
		var mapping: Dictionary = CELL_MAP[room.get_cellv(v)]
		if _rng.randf() > mapping.chance:
			continue

		for x in range(mapping.size.x):
			for y in range(mapping.size.y):
				data.tilemap.push_back({"offset": v + Vector2(x, y), "cell": mapping.cell[x][y]})
	return data
