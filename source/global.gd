extends Node



const SCENE_PATH = {
	"login_screen": "res://source/login_screen.tscn",
	"main_scene": "res://source/main_scene.tscn",
	"item_display": "res://source/item_display.tscn",
	"front_page": "res://source/front_page.tscn",
	"collection_view": "res://source/collection_view.tscn",
	"movie_view": "res://source/movie_view.tscn",
	"series_view": "res://source/series_view.tscn",
	"episode_display": "res://source/episode_display.tscn"
}

const DEFAULT_VLC_PATHS = {
	"Windows": "C:/Program Files (x86)/VideoLAN/VLC/vlc.exe",
}

var current_scene = null
var access_token: String
var server_id: String # what does it do?
var user_id: String
var user_name: String
var vlc_path: String = DEFAULT_VLC_PATHS[OS.get_name()]



func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)


func goto_scene(path: String):
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path: String):
	current_scene.free()
	var scene = load(path)
	current_scene = scene.instantiate()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
