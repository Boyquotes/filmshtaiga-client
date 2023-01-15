extends HBoxContainer
class_name EpisodeDisplay



var id: String

@onready var episode_title:= $EpisodeTitle
@onready var button:= $CopyUrlButton

func _ready():
	pass


func _on_copy_url_button_pressed():
	DisplayServer.clipboard_set(JellyfinApi.get_video_stream(id))
