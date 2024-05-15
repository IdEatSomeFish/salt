class_name Post
extends PanelContainer

const POST_WIDTH: int = 500

var post_id: int
var artists: PackedStringArray
var score: int
var favourite_count: int
var image_url: String
var file_extension: String
var image_aspect_ratio: float
var rating: Info.PostRating
var age: int

var image: Image = Image.new()

@onready var artists_label: Label = $MarginContainer/ContentContainer/PostArtists
@onready var rating_label: Label = $MarginContainer/ContentContainer/Rating
@onready var score_label: Label = $MarginContainer/ContentContainer/Interactions/Votes/Score
@onready var favourite_button: Button = $MarginContainer/ContentContainer/Interactions/FavouriteButton
@onready var image_rect: TextureRect = $MarginContainer/ContentContainer/Image
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var content_container: VBoxContainer = $MarginContainer/ContentContainer


func request_image() -> void:
	http_request.request(image_url)


func _ready() -> void:
	content_container.custom_minimum_size.x = POST_WIDTH
	image_rect.custom_minimum_size.y = image_aspect_ratio * POST_WIDTH
	
	artists_label.text = ' • '.join(artists)
	score_label.text = str(score)
	favourite_button.text = str(favourite_count)
	
	match rating:
		Info.PostRating.SAFE:
			rating_label.text = 'safe'
		Info.PostRating.QUESTIONABLE:
			rating_label.text = 'questionable'
		Info.PostRating.EXPLICIT:
			rating_label.text = 'explicit'
	
	if file_extension == 'png' or file_extension == 'jpg':
		request_image()
	else:
		queue_free()


func _on_http_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	match file_extension:
		'png':
			image.load_png_from_buffer(body)
		'jpg':
			image.load_jpg_from_buffer(body)
	
	image_rect.texture = ImageTexture.create_from_image(image)
