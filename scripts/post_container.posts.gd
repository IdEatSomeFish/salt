extends VBoxContainer

var posts: Array[Post]


func update() -> void:
	for post in posts:
		add_child(post)
		
		var h_separator: HSeparator = HSeparator.new()
		add_child(h_separator)
