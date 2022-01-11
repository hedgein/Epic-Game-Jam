extends Node2D
# TODO: automate by fetching world size?
# !Holy cow I'm so sorry about all the literals

const Player = preload("res://Scenes/Player.tscn")
const Exit = preload("res://Scenes/Stairway.tscn")
const TimeLoop = preload("res://Scenes/TimeLoop.tscn")
const Inventory = preload("res://Inventory.tscn")
const Item = preload("res://Scenes/Item.tscn")

#set a global variables
var position_start = Vector2(0,0)
var player = Player.instance()
var item = Item.instance()

var inventory_array = []


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


    #add player instance & set player positon    
    add_child(player)
    position_start = map.front() * gridSize
    player.position = position_start

    var exit = Exit.instance()
    add_child(exit)
    exit.position = walker.get_end_room().position * gridSize
    exit.connect("next_level", self, "reload_level")
    
    #add  time loop instance, connect to signal for restart
    var timeLoop = TimeLoop.instance()
    add_child(timeLoop)
    timeLoop.connect("restart", self, "on_restart")
    
    #add inventory instance
    var inventory = Inventory.instance()
    add_child(inventory)
    inventory_array = get_tree().get_nodes_in_group("Slots")
    
    #add item instance
    add_child(item)
    item.position = player.position + Vector2(0, 100)
    item.connect("delete_item_self", self, "on_delete_item_self") 
    
    walker.queue_free()
    for location in map:
        tileMap.set_cellv(location, -1)
    tileMap.update_bitmask_region(borders.position, borders.end)

func reload_level():
    get_tree().reload_current_scene()
    
func on_restart():
    player.position = position_start
    add_child(item)
    item.position = player.position + Vector2(0, 100)


func on_delete_item_self():
    remove_child(item)
    for slot in inventory_array:
        if (slot.texture == null):
            slot.texture = load("res://Art/icon-green.png")
            break
        else:
            pass
    
