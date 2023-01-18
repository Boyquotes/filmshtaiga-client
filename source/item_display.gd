extends Control
class_name ItemDisplay



signal element_pressed(element: ItemDisplay)

const HOVER_MODULATE_COLOR = Color("cccccc")

var info: Dictionary

@onready var texture_button:= $PanelContainer/TextureButton



func _ready():
	if info["Type"] == "CollectionFolder":
		$Label.set_text("")
	elif info["Type"] == "Movie" or info["Type"] == "Season" or info["Type"] == "Series":
		if info.has("ProductionYear"):
			$YearLabel.set_text(str(info["ProductionYear"]))
		$Label.set_text(info["Name"])
	else:
		$Label.set_text(info["Name"])
	


func set_image(new_texture: ImageTexture):
	texture_button.set_texture_normal(new_texture)


func _on_texture_button_pressed():
	element_pressed.emit(self)


func _on_texture_button_mouse_entered():
	var tween:= create_tween()
	tween.tween_property(self, "modulate", HOVER_MODULATE_COLOR, 0.06).from_current()


func _on_texture_button_mouse_exited():
	var tween:= create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.06).from_current()
