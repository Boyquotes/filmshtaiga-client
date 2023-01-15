extends HBoxContainer



var item_info
var season_items: Array[Dictionary]
var loaded_images_counter:= 0
var episode_items: Array[Dictionary]

@onready var series_image:= $VBoxContainer/PanelContainer/SeriesImage
@onready var info_container:= $InfoContainer
@onready var season_container:= $ScrollContainer/SeasonContainer
@onready var episode_container:= $ScrollContainer2/EpisodeContainer
@onready var title:= $InfoContainer/Title
@onready var season_name:= $ScrollContainer2/EpisodeContainer/HBoxContainer/SeasonName
@onready var season_hbox:= $ScrollContainer2/EpisodeContainer/HBoxContainer



func _ready():
	title.set_text(item_info["Name"])
	var image = await JellyfinApi.request_image(item_info["Id"], "Primary", 500, 400)
	series_image.set_texture(image)
	season_items = await JellyfinApi.get_items(item_info["Id"])
	for item in season_items:
		var item_display: ItemDisplay = load(Global.SCENE_PATH["item_display"]).instantiate()
		item_display.info = item
		season_container.add_child(item_display)
		item_display.visible = false
		item_display.element_pressed.connect(_on_element_pressed)
		if not item["ImageTags"].is_empty():
			_fill_item_image(item_display)
		else:
			loaded_images_counter += 1


func _fill_item_image(item_display: ItemDisplay):
	var image_texture = await JellyfinApi.request_image(item_display.info["Id"], "Primary")
	loaded_images_counter += 1
	item_display.set_image(image_texture)
	
	if loaded_images_counter == season_items.size():
		for element in season_container.get_children():
			element.visible = true


func _on_element_pressed(element: ItemDisplay):
	for episode_element in episode_container.get_children():
		if episode_element == season_hbox:
			season_name.set_text("")
		else:
			episode_element.queue_free()
	episode_items = await JellyfinApi.get_items(element.item_id)
	season_name.set_text("Season " + str(element.info["IndexNumber"]))
	for item in episode_items:
		var episode_element: EpisodeDisplay = load(Global.SCENE_PATH["episode_display"]).instantiate()
		episode_container.add_child(episode_element)
		episode_element.episode_title.set_text(str(item["IndexNumber"]) + ". " + item["Name"])
		episode_element.id = item["Id"]




