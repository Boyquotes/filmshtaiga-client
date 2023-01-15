extends Control
class_name ItemDisplay



signal element_pressed(element: ItemDisplay)

enum Type {COLLECTION_FOLDER, MOVIE, SERIES, SEASON, EPISODE, BOX_SET}

const HOVER_MODULATE_COLOR = Color("cccccc")

var info: Dictionary
var item_id: String
var is_folder: bool
var type: Type

@onready var texture_button:= $PanelContainer/TextureButton



func _ready():
	set_type(info["Type"])
	item_id = info["Id"]
	is_folder = info["IsFolder"]
	if type == Type.COLLECTION_FOLDER:
		$Label.set_text("")
	elif type == Type.MOVIE or type == Type.SEASON or type == Type.SERIES:
		if info.has("ProductionYear"):
			$YearLabel.set_text(str(info["ProductionYear"]))
		$Label.set_text(info["Name"])
	else:
		$Label.set_text(info["Name"])
	


func set_image(new_texture: ImageTexture):
	texture_button.set_texture_normal(new_texture)


func set_type(type_string: String):
	match type_string:
		"CollectionFolder":
			type = Type.COLLECTION_FOLDER
		"Movie":
			type = Type.MOVIE
		"Series":
			type = Type.SERIES
		"Season":
			type = Type.SEASON
		"Episode":
			type = Type.EPISODE
		"BoxSet":
			type = Type.BOX_SET


func _on_texture_button_pressed():
	element_pressed.emit(self)


func _on_texture_button_mouse_entered():
	var tween:= create_tween()
	tween.tween_property(self, "modulate", HOVER_MODULATE_COLOR, 0.06).from_current()


func _on_texture_button_mouse_exited():
	var tween:= create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.06).from_current()
