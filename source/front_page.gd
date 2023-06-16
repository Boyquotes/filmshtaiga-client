extends ScrollContainer
class_name FrontPage



signal element_pressed(element: ItemDisplay)

var library_items: Array
var loaded_images_counter:= 0

@onready var library_container:= $VBoxContainer/LibraryContainer



func _ready():
	library_items = await JellyfinApi.get_items()
	for item in library_items:
		var item_display: ItemDisplay = load(Global.SCENE_PATH["item_display"]).instantiate()
		item_display.info = item
		library_container.add_child(item_display)
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
	
	if loaded_images_counter == library_items.size():
		for element in library_container.get_children():
			element.visible = true


func _on_element_pressed(element: ItemDisplay):
	element_pressed.emit(element)
