extends HBoxContainer
class_name EpisodeDisplay



var id: String

@onready var episode_title:= $EpisodeTitle
@onready var button:= $PlayButton
@onready var runtime_label:= $Runtime



func _on_play_button_pressed():
	OS.create_process(Global.vlc_path, [JellyfinApi.get_video_stream(id)])
