extends Control



var current_subscene: Node
var previous_subscene: Node

@onready var search_bar:= (
	$RootContainer/TopBarPanel/MarginContainer/TopBarHbox/SearchBar)
@onready var user_name_label:= (
	$RootContainer/TopBarPanel/MarginContainer/TopBarHbox/UserName)
@onready var margin_container:= $RootContainer/PanelContainer/MarginContainer
@onready var settings_button:= $RootContainer/TopBarPanel/MarginContainer/TopBarHbox/SettingsButton
@onready var vlc_dir_popup:= $VlcDirPopup
@onready var vlc_dir_edit:= $VlcDirPopup/MarginContainer/VBoxContainer/VlcDirEdit



func _ready():
	user_name_label.set_text(Global.user_name)
	settings_button.get_popup().id_pressed.connect(_on_settings_menu_id_pressed)
	vlc_dir_edit.set_text(Global.vlc_path)
	
	var front_page: FrontPage = load(Global.SCENE_PATH["front_page"]).instantiate()
	margin_container.add_child(front_page)
	current_subscene = front_page
	front_page.element_pressed.connect(_on_element_pressed)


func change_view(scene_path: String, item_info = {}):
	var new_scene: Node = load(scene_path).instantiate()
	if not new_scene is FrontPage:
		new_scene.item_info = item_info
	margin_container.remove_child(current_subscene)
	previous_subscene = current_subscene
	current_subscene = new_scene
	margin_container.add_child(new_scene)
	if new_scene.has_signal("element_pressed"):
		new_scene.element_pressed.connect(_on_element_pressed)


func _on_element_pressed(element: ItemDisplay):
	var scene_path: String
	match element.info["Type"]:
		"CollectionFolder":
			scene_path = Global.SCENE_PATH["collection_view"]
		"Movie":
			scene_path = Global.SCENE_PATH["movie_view"]
		"Series":
			scene_path = Global.SCENE_PATH["series_view"]
		"BoxSet":
			scene_path = Global.SCENE_PATH["collection_view"]
	change_view(scene_path, element.info)



func _on_search_bar_text_submitted(new_text):
	change_view(Global.SCENE_PATH["collection_view"], new_text)


func _on_back_button_pressed():
	if not search_bar.get_text().is_empty():
		search_bar.set_text("")
	search_bar.release_focus()
		
	if previous_subscene == null:
		if not current_subscene is FrontPage:
			change_view(Global.SCENE_PATH["front_page"])
		return
	
	current_subscene.queue_free() #problem
	margin_container.add_child(previous_subscene)
	current_subscene = previous_subscene
	previous_subscene = null


func _on_home_button_pressed():
	if not search_bar.get_text().is_empty():
		search_bar.set_text("")
	search_bar.release_focus()
	
	change_view(Global.SCENE_PATH["front_page"])


func _on_settings_menu_id_pressed(id):
	match id:
		0: # Change VLC path
			vlc_dir_popup.popup_centered()
		1: # Log Out
			JellyfinApi.wait_for_login = true
			Global.goto_scene(Global.SCENE_PATH["login_screen"])


func _on_vlc_dir_edit_text_changed(new_text):
	Global.vlc_path = new_text
	print(Global.vlc_path)


func _on_button_pressed() -> void:
	var series_metadata:= []
	var first_eps_metadata:= []
	var series_bgsub:= []
	for series in current_subscene.collection_items:
		var metadata = await JellyfinApi.get_item_metadata(series["Id"])
		var seasons = await JellyfinApi.get_items(series["Id"])
		if seasons.is_empty():
			continue
		var episodes = await JellyfinApi.get_items(seasons[0]["Id"])
		if episodes.is_empty():
			continue
		var first_ep_metadata = await JellyfinApi.get_item_metadata(episodes[0]["Id"])
		first_eps_metadata.push_back(first_ep_metadata)
		series_metadata.push_back(metadata)
		print("here")
	assert(series_metadata.size() == first_eps_metadata.size())
	for index in first_eps_metadata.size():
		if first_eps_metadata[index].has("MediaStreams"):
			for media_stream in first_eps_metadata[index]["MediaStreams"]:
				if media_stream["Codec"] == "subrip" or media_stream["Codec"] == "srt":
					if media_stream.has("Language"):
						if media_stream["Language"] == "bul":
							series_bgsub.push_back(series_metadata[index])
	for movie in series_bgsub:
		if "000bgsub" in movie["Tags"]:
			continue
		movie["Tags"].push_back("000bgsub")
		print(movie["Name"])
		await JellyfinApi.post_item_metadata(movie["Id"], movie)
