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
	go_to_front_page()


func go_to_front_page():
	var front_page: FrontPage = load(Global.SCENE_PATH["front_page"]).instantiate()
	if current_subscene != null:
		margin_container.remove_child(current_subscene)
		previous_subscene = current_subscene
	margin_container.add_child(front_page)
	current_subscene = front_page
	front_page.element_pressed.connect(_on_element_pressed)


func _on_element_pressed(element: ItemDisplay):
	var new_scene
	match element.type:
		ItemDisplay.Type.COLLECTION_FOLDER:
			new_scene = load(Global.SCENE_PATH["collection_view"]).instantiate()
			new_scene.element_pressed.connect(_on_element_pressed)
		ItemDisplay.Type.MOVIE:
			new_scene = load(Global.SCENE_PATH["movie_view"]).instantiate()
		ItemDisplay.Type.SERIES:
			new_scene = load(Global.SCENE_PATH["series_view"]).instantiate()
		ItemDisplay.Type.BOX_SET:
			new_scene = load(Global.SCENE_PATH["collection_view"]).instantiate()
			new_scene.element_pressed.connect(_on_element_pressed)
	new_scene.item_info = element.info
	margin_container.remove_child(current_subscene)
	previous_subscene = current_subscene
	current_subscene = new_scene
	margin_container.add_child(new_scene)


func _on_search_bar_text_submitted(new_text):
	var new_scene = load(Global.SCENE_PATH["collection_view"]).instantiate()
	new_scene.element_pressed.connect(_on_element_pressed)
	new_scene.item_info = new_text
	margin_container.remove_child(current_subscene)
	previous_subscene = current_subscene
	current_subscene = new_scene
	margin_container.add_child(new_scene)


func _on_back_button_pressed():
	if not search_bar.get_text().is_empty():
		search_bar.set_text("")
		
	if previous_subscene == null:
		if not current_subscene is FrontPage:
			go_to_front_page()
		return
	
	current_subscene.queue_free()
	margin_container.add_child(previous_subscene)
	current_subscene = previous_subscene
	previous_subscene = null


func _on_home_button_pressed():
	if not search_bar.get_text().is_empty():
		search_bar.set_text("")
	
	go_to_front_page()


func _on_settings_menu_id_pressed(id):
	match id:
		0: # Change VLC path
			vlc_dir_popup.popup_centered()
		1: # Log Out
			pass


func _on_vlc_dir_edit_text_changed(new_text):
	Global.vlc_path = new_text
	print(Global.vlc_path)
