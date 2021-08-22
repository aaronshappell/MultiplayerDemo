extends Node

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


func _player_connected(id: int) -> void:
	rpc_id(id, "register_player", player_name)
	print("%d connected" % id)


func _player_disconnected(id: int) -> void:
	players.erase(id)
	refresh_lobby()
	print("%d disconnected" % id)


func _connected_ok() -> void:
	print("connected ok")


func _connected_fail() -> void:
	print("connected fail")


func _server_disconnected() -> void:
	# Kick to main menu or something
	pass


remote func register_player(name: String):
	var id := get_tree().get_rpc_sender_id()
	players[id] = name
	refresh_lobby()


func refresh_lobby() -> void:
	player_list.clear()
	player_list.add_item(player_name)
	for name in players.values():
		player_list.add_item(name)
	player_list.sort_items_by_text()


func _on_Join_pressed() -> void:
	var peer = NetworkedMultiplayerENet.new()
	var ip = $Connect/IP.text
	if ip.empty():
		peer.create_client($Connect/IP.placeholder_text, DEFAULT_PORT)
	else:
		peer.create_client(ip, DEFAULT_PORT)
	get_tree().network_peer = peer
	print("Client created!")
	player_name = $Connect/Name.text
	$Connect.hide()
	$Players.show()
	$Players/Start.hide()


func _on_Host_pressed() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	print("Server hosted!")
	player_name = $Connect/Name.text
	$Connect.hide()
	$Players.show()
	refresh_lobby()


func _on_Start_pressed() -> void:
	assert(get_tree().is_network_server())
	
