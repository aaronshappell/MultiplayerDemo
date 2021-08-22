extends Control

const DEFAULT_PORT: int = 6969
const MAX_PLAYERS: int = 4

var players = {}
var player_name: String = "Joe Smith"

onready var player_list = $Players/ItemList

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


remote func register_player(name: String):
	var id := get_tree().get_rpc_sender_id()
	players[id] = name
	refresh_lobby()


func refresh_lobby() -> void:
	player_list.clear()
	for name in players.values():
		player_list.add_item(name)
	player_list.sort_items_by_text()


remotesync func start_game() -> void:
	var world = load("res://World.tscn").instance()
	get_tree().root.add_child(world)
	hide()

	var player_scene = load("res://Player.tscn")
	for p_id in players:
		var player = player_scene.instance()
		player.set_name(str(p_id))
		player.set_network_master(p_id)
		player.set_player_name(players[p_id])
		
		world.get_node("Players").add_child(player)


func _player_connected(id: int) -> void:
	rpc_id(id, "register_player", player_name)
	print("%d connected" % id)


func _player_disconnected(id: int) -> void:
	players.erase(id)
	refresh_lobby()
	print("%d disconnected" % id)


func _connected_ok() -> void:
	players[get_tree().get_network_unique_id()] = player_name
	$Connect.hide()
	$Players.show()
	$Players/Start.hide()
	print("Connection ok")


func _connected_fail() -> void:
	print("Connection fail")


func _server_disconnected() -> void:
	players.clear()
	$Players.hide()
	$Connect.show()
	print("Server disconnected")


func _on_Join_pressed() -> void:
	var peer := NetworkedMultiplayerENet.new()
	var ip: String = $Connect/IP.text
	if ip.empty():
		peer.create_client($Connect/IP.placeholder_text, DEFAULT_PORT)
	else:
		peer.create_client(ip, DEFAULT_PORT)
	get_tree().network_peer = peer
	player_name = $Connect/Name.text
	print("Client created")


func _on_Host_pressed() -> void:
	var peer := NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	player_name = $Connect/Name.text
	$Connect.hide()
	$Players.show()
	players[1] = player_name
	refresh_lobby()
	print("Server hosted")


func _on_Start_pressed() -> void:
	assert(get_tree().is_network_server())
	rpc("start_game")
