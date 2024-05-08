extends Node

const VERSION: String = "0.0.0"
const USER_AGENT: String = "salt/%s" % VERSION
const ROOT_URL: String = "https://e621.net"

enum PostRating{
	SAFE,
	QUESTIONABLE,
	EXPLICIT,
}
