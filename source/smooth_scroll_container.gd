extends ScrollContainer
class_name SmoothScrollContainer

# Disables default scroll button scrolling and replaces it with smooth scrolling

signal scrolled_down

var prev_scroll_vertical
var tween: Tween
var scroll_down_inputs_accum:= 0
var scroll_up_inputs_accum:= 0

@export var pixels_per_scroll:= 280
@export var tween_duration:= 0.08



func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	prev_scroll_vertical = scroll_vertical


func _input(event: InputEvent) -> void:
	
	if not get_rect().has_point(get_parent().get_local_mouse_position()):
		return
	if event.is_action("scroll_down"):
		scroll_vertical = prev_scroll_vertical
		if scroll_up_inputs_accum > 0:
			scroll_up_inputs_accum = 0
		
		var scroll_just_started:= false
		
		if scroll_down_inputs_accum == 0:
			scroll_just_started = true
		
		scroll_down_inputs_accum += 1
		
		
		
		if scroll_just_started:
			while(scroll_down_inputs_accum > 0):
				prev_scroll_vertical = scroll_vertical
				tween = create_tween()
				tween.tween_property(self, "scroll_vertical", 
						scroll_vertical + pixels_per_scroll, tween_duration)
				await tween.finished
				scrolled_down.emit()
				scroll_down_inputs_accum -= 2
	
	if event.is_action("scroll_up"):
		scroll_vertical = prev_scroll_vertical
		if scroll_down_inputs_accum > 0:
			scroll_down_inputs_accum = 0
		var scroll_just_started:= false
		if scroll_up_inputs_accum == 0:
			scroll_just_started = true
		
		scroll_up_inputs_accum += 1
		
		if scroll_just_started:
			while(scroll_up_inputs_accum > 0):
				tween = create_tween()
				tween.tween_property(self, "scroll_vertical", 
						scroll_vertical - pixels_per_scroll, tween_duration)
				await tween.finished
				prev_scroll_vertical = scroll_vertical
				scroll_up_inputs_accum -= 2
