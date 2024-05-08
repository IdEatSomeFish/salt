extends PanelContainer

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var username_box: LineEdit = $MarginContainer/VBoxContainer/UsernameBox
@onready var api_key_box: LineEdit = $MarginContainer/VBoxContainer/APIKeyBox
@onready var save_login_box: CheckBox = $MarginContainer/VBoxContainer/SaveLogin/CheckBox
@onready var login_status: Label = $MarginContainer/VBoxContainer/LoginStatus

var username: String
var api_key: String


func _on_submit_button_pressed() -> void:
	username = username_box.text
	api_key = api_key_box.text
	
	if !username or !api_key:
		login_status.text = "incomplete details"
		return
	
	var url: String = "%s/" % Info.ROOT_URL
	var headers: PackedStringArray = PackedStringArray(["User-Agent: %s" % Info.USER_AGENT])
	
	var parameters: PackedStringArray = PackedStringArray([
		"api_key=%s" % api_key,
		"login=%s" % username,
	])
	
	http_request.request(url + "?" + "&".join(parameters), headers)


func _on_http_request_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if response_code == 200:
		User.username = username
		User.api_key = api_key
		User.signed_in = true
		
		queue_free()
	else:
		login_status.text = "invalid details"
