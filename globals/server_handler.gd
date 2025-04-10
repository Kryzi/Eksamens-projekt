extends Node

var weapon_node: Node2D
signal request_data_received(request_data: Dictionary)
# Declare member variables here. Examples:
var http_request : HTTPRequest = HTTPRequest.new()
# Change this to own localhost location
const SERVER_URL = "http://localhost:80/mountain_top/mountain_top_db_action_secure.php"
const SERVER_HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Cache-Control: max-age=0"]
const SECRET_KEY = 1234567890
var nonce = null
var request_queue : Array = []
var is_requesting : bool = false

#var weapon_data: Array[WeaponAmmoTableData]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	add_child(http_request)
	PlayerInfo.win_screen_reached.connect(_submit_score)
	#PlayerInfo.win_screen_reached.connect(get_weapon_ammo_data)
	http_request.request_completed.connect(_http_request_completed)


func _process(_delta):
	
	if is_requesting:
		return
		
	if request_queue.is_empty():
		return
		
	is_requesting = true
	
	if nonce == null:
		request_nonce()
	else:
		_send_request(request_queue.pop_front())
	
	
func request_nonce():
	var client = HTTPClient.new()
	var data = client.query_string_from_dict({"data" : JSON.stringify({})})
	var body = "command=get_nonce&" + data
	
	var err = http_request.request(SERVER_URL, SERVER_HEADERS, HTTPClient.METHOD_POST, body)
	
	
	if err != OK:
		printerr("HTTPRequest error: " + str(err))
		return
		
	print("Requested nonce")
	
		
func _send_request(request: Dictionary):
	var client = HTTPClient.new()
	var data = client.query_string_from_dict({"data" : JSON.stringify(request['data'])})
	var cnonce = str(Crypto.new().generate_random_bytes(32)).sha256_text()
	var body = "command=" + request['command'] + "&" + data + "&cnonce=" + cnonce

	var client_hash = (nonce + cnonce + body + str(SECRET_KEY)).sha256_text()
	nonce = null
	
	var headers = SERVER_HEADERS.duplicate()
	headers.push_back("cnonce: " + cnonce)
	headers.push_back("hash: " + client_hash)
	
	var err = http_request.request(SERVER_URL, headers, HTTPClient.METHOD_POST, body)
		
	if err != OK:
		printerr("HTTPRequest error: " + str(err))
		return


func _http_request_completed(_result, _response_code, _headers, _body):
	is_requesting = false
	if _result != http_request.RESULT_SUCCESS:
		printerr("Error w/ connection: " + str(_result))
		return
	
	var response_body = _body.get_string_from_utf8()
	var test_json_conv = JSON.new()
	test_json_conv.parse(response_body)
	var response = test_json_conv.get_data()
	
	if response['error'] != "none":
		printerr("We returned error: " + response['error'])
		return
		
	if response['command'] == "get_nonce":
		nonce = response['response']['nonce']
		print("Get nonce: " + response['response']['nonce'])
		return	
	
	# Kun send indholdet i HTTP-requesten som indeholder spillerdata og indholdsstørrelse 'size'
	request_data_received.emit(response['response'])

	

	
func _submit_score(_victory_bool: bool, score: int) -> void:
	var user_name := PlayerInfo.player_name
	var command = "add_score"
	var data = {"username" : user_name, "score" : str(score)}
	request_queue.push_back({"command" : command, "data" : data})
	
func _get_scores():
	var command = "get_scores"
	var data = {"score_offset" : 0, "score_number" : 100}
	request_queue.push_back({"command" : command, "data" : data})
	print("get scores")

func _get_player():
	var user_id = $ID.get_text()
	var command = "get_player"
	var data = {"user_id" : user_id}
	request_queue.push_back({"command" : command, "data" : data})

func _delete_player():
	var user_id = $ID.get_text()
	var command = "delete_player"
	var data = {"user_id": user_id}
	request_queue.push_back({"command" : command, "data" : data})
	
#func get_weapon_ammo_data(_bool: bool, _highscore: int) -> Array[WeaponAmmoTableData]:
	#var weapon_table_data_array: Array[WeaponAmmoTableData]
	#var weapon_nodes_array: Array[Node] = weapon_node.weapons
	#for weapon in weapon_nodes_array:
		#var new_weapon_ammo_row_data = WeaponAmmoTableData.new()
		#new_weapon_ammo_row_data.weapon_name = weapon.get_meta("IconId")
		#new_weapon_ammo_row_data.ranged = weapon.ranged
		#new_weapon_ammo_row_data.current_ammo = weapon.currentAmmo
		#new_weapon_ammo_row_data.reserve_ammo = weapon.reserveAmmo
		#weapon_table_data_array.append(new_weapon_ammo_row_data)
		#
	#
	#return weapon_table_data_array
	#
#class WeaponAmmoTableData:
	#var weapon_name: String
	#var ranged: bool
	#var current_ammo: int
	#var reserve_ammo: int
