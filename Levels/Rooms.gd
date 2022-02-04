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

var gear_coin = preload("res://Item.tscn")

onready var LR_0 = get_node("LR/0")
onready var LRB_0 = get_node("LRB/0")
onready var LRB_2 = get_node("LRB/2")
onready var LRB_4 = get_node("LRB/4")
onready var LRT_1 = get_node("LRT/1")
onready var LRT_3 = get_node("LRT/3")
onready var LRT_5 = get_node("LRT/5")
onready var LRTB_0 = get_node("LRTB/0")
onready var LRTB_2 = get_node("LRTB/2")
onready var LRTB_3 = get_node("LRTB/3")
onready var LRTB_4 = get_node("LRTB/4")

func _ready():
    var g_LR_0 = gear_coin.instance()
    g_LR_0.position = Vector2(358, 408)
    LR_0.add_child(g_LR_0)
    
    var g_LRB_0 = gear_coin.instance()
    g_LRB_0.position = Vector2(538, 455)
    LRB_0.add_child(g_LRB_0)
    
    var g_LRB_2 = gear_coin.instance()
    g_LRB_2.position = Vector2(540, 461)
    LRB_2.add_child(g_LRB_2)
    
    var g_LRB_4 = gear_coin.instance()
    g_LRB_4.position = Vector2(542, 169)
    LRB_4.add_child(g_LRB_4)
    
    var g_LRT_1 = gear_coin.instance()
    g_LRT_1.position = Vector2(542, 97)
    LRT_1.add_child(g_LRT_1)
    
    var g_LRT_3 = gear_coin.instance()
    g_LRT_3.position = Vector2(580, 326)
    LRT_3.add_child(g_LRT_1)
    
    var g_LRT_5 = gear_coin.instance()
    g_LRT_5.position = Vector2(540, 573)
    LRT_5.add_child(g_LRT_5)
    
    var g_LRTB_0 = gear_coin.instance()
    g_LRTB_0.position = Vector2(546, 110)
    LRTB_0.add_child(g_LRTB_0)
    
    var g_LRTB_2 = gear_coin.instance()
    g_LRTB_2.position = Vector2(542, 397)
    LRTB_2.add_child(g_LRTB_2)
    
    var g_LRTB_3 = gear_coin.instance()
    g_LRTB_3.position = Vector2(761, 219)
    LRTB_3.add_child(g_LRTB_3)
    
    var g_LRTB_4 = gear_coin.instance()
    g_LRTB_4.position = Vector2(342,530)
    LRTB_4.add_child(g_LRTB_4)
    
    
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
            #print("Could not read cellv:", v)
            continue
        var mapping: Dictionary = CELL_MAP[room.get_cellv(v)]
        if _rng.randf() > mapping.chance:
            continue

        for x in range(mapping.size.x):
            for y in range(mapping.size.y):
                data.tilemap.push_back({"offset": v + Vector2(x, y), "cell": mapping.cell[x][y]})
    return data
