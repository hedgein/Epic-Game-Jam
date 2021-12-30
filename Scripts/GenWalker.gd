extends Node
class_name GenWalker

const DIRECTIONS = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]

var pos = Vector2.ZERO
var dir = Vector2.RIGHT
var borders = Rect2()
var step_history = []
# used to fix hallway distance
var steps_since_turn = 0
var rooms = []

func _init(starting_position, new_borders):
	assert(new_borders.has_point(starting_position))
	pos = starting_position
	step_history.append(pos)
	borders = new_borders

func walk(steps):
	place_room(pos)
	for step in steps:
		# change direction approx 25% of the time or at max hallway length
		if randf() <= 0.5 and steps_since_turn >= 6:
			change_direction()
		
		if step():
			step_history.append(pos)
		else:
			change_direction()
	return step_history

# called in walk func
func step():
	var target_position = pos + dir
	if borders.has_point(target_position):
		steps_since_turn += 1
		pos = target_position
		return true
	else:
		return false

# called in walk func
func change_direction():
	place_room(pos)
	# don't choose same direction
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(dir)
	directions.shuffle()
	# pick new direction
	dir = directions.pop_front()
	while not borders.has_point(pos + dir):
		dir = directions.pop_front()

func create_room(_pos, _size):
	return { position = _pos, size = _size }

# called in change_direction
func place_room(_pos):
	var minRoomSize = 4	
	var maxRoomSize = 4	
	
	var size = Vector2(randi()%maxRoomSize + minRoomSize, randi()%maxRoomSize + minRoomSize)
	var top_left_corner = (_pos - size/2).ceil()
	rooms.append(create_room(_pos, size))
	for y in size.y:
		for x in size.x:
			var new_step = top_left_corner + Vector2(x, y)
			if borders.has_point(new_step):
				step_history.append(new_step)

func get_end_room():
	var end_room = rooms.pop_front()
	var starting_position = step_history.front()
	for room in rooms:
		if starting_position.distance_to(room.position) > starting_position.distance_to(end_room.position):
			end_room = room
	return end_room