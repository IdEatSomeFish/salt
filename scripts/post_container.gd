extends ScrollContainer

var post_scene: PackedScene = preload("res://scenes/post.tscn")

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var posts: VBoxContainer = $CenterContainer/Posts

@export var query: String = ""
@export var limit: int = 20


func request_posts() -> void:
	var url: String = "%s/posts.json" % Info.ROOT_URL
	var headers: PackedStringArray = PackedStringArray(["User-Agent: %s" % Info.USER_AGENT])
	
	if User.signed_in:
		headers.append("Authorization: Basic %s" % [User.encode()])
	
	var parameters: PackedStringArray = PackedStringArray([
		"tags=%s" % query,
		"limit=%d" % limit,
	])
	
	http_request.request(url + "?" + "&".join(parameters), headers)


func parse_response(response: PackedByteArray) -> Dictionary:
	var json = JSON.new()
	json.parse(response.get_string_from_utf8())
	return json.data


func generate_post(post_dictionary: Dictionary) -> Post:
	var post: Post = post_scene.instantiate()
	
	post.post_id = post_dictionary["id"]
	post.artists = PackedStringArray(post_dictionary["tags"]["artist"])
	post.score = post_dictionary["score"]["total"]
	post.favourite_count = post_dictionary["fav_count"]
	post.image_url = post_dictionary["sample"]["url"]
	post.file_extension = "jpg" if post_dictionary["sample"]["has"] else post_dictionary["file"]["ext"]
	post.image_aspect_ratio = post_dictionary["file"]["height"]/ post_dictionary["file"]["width"]
	
	match post_dictionary["rating"]:
		"s":
			post.rating = Info.PostRating.SAFE
		"q":
			post.rating = Info.PostRating.QUESTIONABLE
		"e":
			post.rating = Info.PostRating.EXPLICIT
	
	var creation_datetime: int = Time.get_unix_time_from_datetime_string(post_dictionary["created_at"])
	var current_datetime: int = int(Time.get_unix_time_from_system())
	post.age = current_datetime - creation_datetime
	
	return post


func _ready() -> void:
	request_posts()


func _on_http_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var response: Dictionary = parse_response(body)
	
	for post_dictionary in response["posts"]:
		if post_dictionary["file"]["url"]:
			var post: Post = generate_post(post_dictionary)
			
			if post.file_extension == "png" or post.file_extension == "jpg":
				posts.posts.append(post)
	
	posts.update()
