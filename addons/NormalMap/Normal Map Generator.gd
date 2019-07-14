tool
extends Control

var texture_rect
var viewport
var current_path = "./generated.png"
var track_mouse = false

func _ready():
	texture_rect = $VBoxContainer/ViewportContainer/Viewport/TextureRect
	viewport = $VBoxContainer/ViewportContainer/Viewport
	viewport.size = texture_rect.texture.get_size()

func _process(delta):
	if (track_mouse):
		if Input.is_action_pressed("click"):
			print("click")
			$VBoxContainer/ViewportContainer/Viewport/TextureRect/Light2D.global_position = get_global_mouse_position()

func _on_Normal_toggled(button_pressed):
	texture_rect.material.set_shader_param("normal_preview",button_pressed)


func _on_Emboss_toggled(button_pressed):
	texture_rect.material.set_shader_param("with_emboss",button_pressed)


func _on_Emboss_Height_value_changed(value):
	texture_rect.material.set_shader_param("emboss_height",value)


func _on_Bump_toggled(button_pressed):
	texture_rect.material.set_shader_param("with_distance",button_pressed)


func _on_Bump_Height_value_changed(value):
	texture_rect.material.set_shader_param("bump_height",value)

func _on_SpinBoxBlur_value_changed(value):
	texture_rect.material.set_shader_param("blur",value)


func _on_SpinBoxDistance_value_changed(value):
	texture_rect.material.set_shader_param("bump",value)


func _on_InvertX_toggled(button_pressed):
	texture_rect.material.set_shader_param("invertX",button_pressed)


func _on_InvertY_toggled(button_pressed):
	texture_rect.material.set_shader_param("invertY",button_pressed)


func _on_Button_pressed():
	var img = viewport.get_texture().get_data()
	img.flip_y()
	print(img.save_png(current_path))

func _on_TextureButton_pressed():
	$FileDialog.popup()

func _on_FileDialog_file_selected(path):
	var img = Image.new()
	var itex = ImageTexture.new()
	if (!img.load(path)):
		itex.create_from_image(img)
		texture_rect.texture = itex
		var aux = path.rsplit(".",true,1)
		current_path = aux[0]+"_n."+aux[1]

func _on_TextureRect_mouse_entered():
	track_mouse = true;

func _on_TextureRect_mouse_exited():
	track_mouse = false;