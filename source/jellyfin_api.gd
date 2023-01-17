extends Node



enum Response {RESULT, CODE, HEADERS, BODY}

var is_authorization_valid:= true
var url: String

var weird_header: PackedStringArray =[
	'X-Emby-Authorization: MediaBrowser Client="MyApp"',
	'Device="MyDevice"',
	'DeviceId=2',
	'Version=0.1',
]

var json_headers: PackedStringArray = [
	"Connection: keep-alive",
	"Content-Type: application/json",
	"accept: application/json",
	", ".join(weird_header)
]

var image_headers: PackedStringArray = [
	"Connection: keep-alive",
	"Content-Type: application/json",
	"accept: image/*",
	", ".join(weird_header)
]

var video_headers: PackedStringArray = [
	"Content-Type: application/json",
	"accept: video/*"
]


func login(server: String, username: String, password: String) -> Variant:
	if server.ends_with("/"):
		server.trim_suffix("/")
	url = "http://" + server
	var path = "/Users/AuthenticateByName"
	var body = JSON.stringify({"Username": username, "Pw": password})
	var response = await _http_request(path, HTTPClient.METHOD_POST,json_headers, body)
	return response


func item_search(search_term: String) -> Array:
	var encoded_term: String = search_term.uri_encode()
	var path = ("/Items?userId=%s&searchTerm=%s&recursive=true&includeItemTypes=Movie,Series"
			% [Global.user_id, encoded_term])
	var response = await _http_request(path, HTTPClient.METHOD_GET, json_headers)
	if response:
		return response["Items"]
	else:
		return []


func get_items(parent_id: String = "") -> Array:
	var path = ("/Items?userId=%s&parentId=%s&enableImages=true&sortBy=SortName&fields=Overview"
			% [Global.user_id, parent_id])
	var response = await _http_request(path, HTTPClient.METHOD_GET, json_headers)
	if response:
		return response["Items"]
	else:
		return []


func request_image(item_id: String, image_type: String, max_height:= 220, max_width:= 280):
	var path = ("/Items/%s/Images/%s?maxHeight=%s&maxWidth=%s"
			% [item_id, image_type, str(max_height), str(max_width)])
	var response = await _http_request(path, HTTPClient.METHOD_GET, image_headers)
	return response


func get_video_stream(item_id):
	return "%s/Items/%s/Download?api_key=%s" % [url, item_id, Global.access_token]


func get_video_stream_2(item_id):
	return "%s/Videos/%s/stream.mkv" % [url, item_id]


func _http_request(path: String, method: int, headers: PackedStringArray, body: String = ""):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request(url + path, headers, false, method, body)
	
	var response = await http_request.request_completed
	http_request.queue_free()
	if response[Response.CODE] == HTTPClient.RESPONSE_UNAUTHORIZED:
		print(response[Response.HEADERS])
		is_authorization_valid = false
		Global.goto_scene(Global.SCENE_PATH["login_screen"])
	
	if response[Response.HEADERS].has("Content-Type: image/png"):
		var image = Image.new()
		var error = image.load_png_from_buffer(response[Response.BODY])
		if error:
			print(error)
		var texture = ImageTexture.create_from_image(image)
		return texture
	
	elif response[Response.HEADERS].has("Content-Type: image/jpeg"):
		var image = Image.new()
		var error = image.load_jpg_from_buffer(response[Response.BODY])
		if error:
			print(error)
		var texture = ImageTexture.create_from_image(image)
		return texture
	
	elif response[Response.HEADERS].has("Content-Type: application/json; charset=utf-8"):
		var json = JSON.new()
		json.parse(response[Response.BODY].get_string_from_utf8())
		var response_body = json.get_data()
		assert(response[Response.CODE] == HTTPClient.RESPONSE_OK, "http_request_failed")
		return response_body
	
	else:
		print(response[Response.RESULT])
		print(response[Response.CODE])
		print(response[Response.HEADERS])
		printerr("unhandled http response header type")
		return 0


