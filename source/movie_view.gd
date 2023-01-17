extends HBoxContainer



var item_info

@onready var movie_image_rect:= $VBoxContainer/PanelContainer/MovieImage
@onready var title_label:= $VBoxContainer2/Title
@onready var year_label:= $VBoxContainer2/Year
@onready var runtime_label:= $VBoxContainer2/Runtime
@onready var overview_label:= $VBoxContainer2/Overview



func _ready():
	title_label.set_text(item_info["Name"])
	year_label.set_text(str(item_info["ProductionYear"]))
	var runtime_min: int = item_info["RunTimeTicks"] * 1e-7 / 60
	runtime_label.set_text(str(runtime_min) + " min")
	overview_label.set_text(item_info["Overview"])
	var image = await JellyfinApi.request_image(item_info["Id"], "Primary", 500, 400)
	movie_image_rect.set_texture(image)


func _on_play_button_pressed():
	OS.create_process(Global.vlc_path, [JellyfinApi.get_video_stream(item_info["Id"])])
