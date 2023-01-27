extends SmoothScrollContainer
class_name CollectionView



signal element_pressed(element: ItemDisplay)

const ITEMS_TO_LOAD = 60
const SCROLL_THRESHOLD = 1500

var item_info
var collection_items: Array[Dictionary]

var loaded_images:= 0
var index_to_load_next:= 0
var items_last_loaded: int

@onready var item_container:= $HFlowContainer



func _ready():
	self.scrolled_down.connect(_on_scrollbar_scrolling)
	get_v_scroll_bar().scrolling.connect(_on_scrollbar_scrolling)
	if item_info is Dictionary: # we're in a collection folder
		collection_items = await JellyfinApi.get_items(item_info["Id"])
	elif item_info is String: # we're displaying search results
		collection_items = await JellyfinApi.item_search(item_info)
	create_more_elements()


func _on_scrollbar_scrolling():
	if get_v_scroll() > item_container.size.y - SCROLL_THRESHOLD:
		if not index_to_load_next == collection_items.size() and loaded_images == ITEMS_TO_LOAD:
			create_more_elements()


func _gui_input(event):
	if event.is_action_pressed("scroll_down"):
		if get_v_scroll() > item_container.size.y - SCROLL_THRESHOLD:
			if not index_to_load_next == collection_items.size() and loaded_images == ITEMS_TO_LOAD:
				create_more_elements()


func create_more_elements():
	loaded_images = 0
	var up_to_index: int = mini(index_to_load_next + ITEMS_TO_LOAD - 1, collection_items.size() - 1)
	items_last_loaded = up_to_index - index_to_load_next + 1
	for index in range(index_to_load_next, up_to_index + 1):
		var item: Dictionary = collection_items[index]
		var item_display: ItemDisplay = load(Global.SCENE_PATH["item_display"]).instantiate()
		item_display.info = item
		item_container.add_child(item_display)
		item_display.visible = false
		item_display.element_pressed.connect(_on_element_pressed)
		if not item["ImageTags"].is_empty():
			_fill_item_image(item_display)
		else:
			loaded_images += 1
		if index == up_to_index:
			# tracks starting point for loading on next scroll down
			index_to_load_next = index + 1



func _fill_item_image(item_display: ItemDisplay):
	var image_texture = await JellyfinApi.request_image(item_display.info["Id"], "Primary")
	loaded_images += 1
	item_display.set_image(image_texture)
	
	if loaded_images == items_last_loaded:
		for element in item_container.get_children():
			element.visible = true


func _on_element_pressed(element: ItemDisplay):
	element_pressed.emit(element)
