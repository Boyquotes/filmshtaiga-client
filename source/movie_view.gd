extends HBoxContainer



var item_info

@onready var movie_image:= $VBoxContainer/PanelContainer/MovieImage
@onready var title:= $VBoxContainer2/Title



func _ready():
	title.set_text(item_info["Name"])
	var image = await JellyfinApi.request_image(item_info["Id"], "Primary", 500, 400)
	movie_image.set_texture(image)


func _on_copy_url_button_pressed():
	DisplayServer.clipboard_set(JellyfinApi.get_video_stream(item_info["Id"]))
