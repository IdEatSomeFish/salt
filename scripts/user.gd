extends Node

var signed_in: bool = false

var username: String
var api_key: String


func encode() -> String:
	return Marshalls.utf8_to_base64('%s:%s' % [User.username, User.api_key])
