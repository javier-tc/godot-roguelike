extends Navigation2D

const SPAWN_ROOMS: Array = [preload("res://Rooms/SpawnRoom0.tscn"), preload("res://Rooms/SpawnRoom1.tscn")]
const INTERMEDIATE_ROOMS: Array = [preload("res://Rooms/Room0.tscn"), preload("res://Rooms/Room1.tscn")]
const END_ROOMS: Array = [preload("res://Rooms/EndRoom0.tscn"), preload("res://Rooms/EndRoom1.tscn")]


const TILE_SIZE: int = 16
const FLOOR_TILE_INDEX: int = 4
const RIGHT_WALL_TILE_INDEX: int = 6
const LEFT_WALL_TILE_INDEX: int = 5

export(int) var num_levels: int = 5

onready var player: KinematicBody2D = get_parent().get_node("Player")

func _ready() -> void:
	_spawn_rooms()
	
func _spawn_rooms() -> void:
	var previous_room: Node2D
	
	for i in num_levels:
		var room: Node2D
		
		if i == 0:
			room = SPAWN_ROOMS[randi() % SPAWN_ROOMS.size()].instance()
			player.position = room.get_node("PlayerSpawnPos").position
		else:
			if i == num_levels - 1:
				room = END_ROOMS[randi() % END_ROOMS.size()].instance()
			else:
				room = INTERMEDIATE_ROOMS[randi() % INTERMEDIATE_ROOMS.size()].instance()
			
			var previous_room_tilemap: TileMap = previous_room.get_node("TileMap")
			var previous_room_door: StaticBody2D = previous_room.get_node("Doors/Door")
			var exit_tile_pos: Vector2 = previous_room_tilemap.world_to_map(previous_room_door.position) + Vector2.UP #salida de la sala anterior
			
			var corridor_height: int = randi() % 4 + 2 #range 2 - 5
			
			for y in corridor_height:
				previous_room_tilemap.set_cellv(exit_tile_pos + Vector2(-2,-y), LEFT_WALL_TILE_INDEX)
				previous_room_tilemap.set_cellv(exit_tile_pos + Vector2(-1,-y), FLOOR_TILE_INDEX)
				previous_room_tilemap.set_cellv(exit_tile_pos + Vector2(0,-y), FLOOR_TILE_INDEX)
				previous_room_tilemap.set_cellv(exit_tile_pos + Vector2(1,-y), RIGHT_WALL_TILE_INDEX)
			
			var room_tilemap: TileMap = room.get_node("TileMap")
			
			var vector_room_size: Vector2 = Vector2.UP * (room_tilemap.get_used_rect().size.y) * TILE_SIZE
			var vector_align_axis_x: Vector2 = Vector2.LEFT * room_tilemap.world_to_map(room.get_node("Entrance/Position2D2").position).x * TILE_SIZE
			var vector_corridor_height: Vector2 = Vector2.UP * TILE_SIZE * (corridor_height + 1)
			
			
			room.position = previous_room_door.global_position + vector_room_size + vector_align_axis_x + vector_corridor_height
			#print_debug(room)
		add_child(room)
		previous_room = room
