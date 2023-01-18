extends Control



@onready var server_edit:= $MarginContainer/VBoxContainer/VBoxContainer/ServerEdit
@onready var username_edit:= $MarginContainer/VBoxContainer/VBoxContainer/UsernameEdit
@onready var password_edit:= $MarginContainer/VBoxContainer/VBoxContainer/PasswordEdit


func _ready():
	if JellyfinApi.wait_for_login: # if we are returned to this scene, wait for relog
		return
	
	# else continue with data stored in file, if it exists
	var config = ConfigFile.new()
	var error = config.load("user://login_info.cfg")
	if error != OK:
		return
	for user in config.get_sections():
		Global.user_id = config.get_value("user_info", "user_id")
		Global.access_token = config.get_value("user_info", "access_token")
		Global.user_name = config.get_value("user_info", "user_name")
		JellyfinApi.url = config.get_value("user_info", "server_url")
		
		JellyfinApi.weird_header.push_back('Token=%s' % Global.access_token)
		JellyfinApi.json_headers[3] = ", ".join(JellyfinApi.weird_header)
		JellyfinApi.image_headers[3] = ", ".join(JellyfinApi.weird_header)
		
		Global.goto_scene(Global.SCENE_PATH["main_scene"])


func _login():
	var info = await JellyfinApi.login(server_edit.text, username_edit.text, password_edit.text)
	if info:
		var config = ConfigFile.new()
		config.set_value("user_info", "user_id", info["User"]["Id"])
		config.set_value("user_info", "access_token", info["AccessToken"])
		config.set_value("user_info", "user_name", info["User"]["Name"])
		config.set_value("user_info", "server_url", "http://" + server_edit.text)
		config.save("user://login_info.cfg")
		
		Global.access_token = info["AccessToken"]
		Global.user_id = info["User"]["Id"]
		Global.user_name = info["User"]["Name"]
		
		JellyfinApi.weird_header.push_back('Token=%s' % Global.access_token)
		JellyfinApi.json_headers[3] = ", ".join(JellyfinApi.weird_header)
		JellyfinApi.image_headers[3] = ", ".join(JellyfinApi.weird_header)
		
		Global.goto_scene(Global.SCENE_PATH["main_scene"])


func _on_login_button_pressed():
	_login()


func _on_exit_button_pressed():
	get_tree().quit()


func _on_password_edit_text_submitted(_new_text):
	_login()
