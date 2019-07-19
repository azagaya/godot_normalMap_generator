tool
extends Control

var texture_rect
var viewport
var current_path = "./generated.png"
var light2d_node = null
var viewport_container_node = null
var distance_texture;


func _ready():
	texture_rect = $ViewportNormal/Normal
	viewport = $GUI/ViewportContainer/Viewport
	viewport.size = texture_rect.texture.get_size()
	
	$ViewportDistance.size = $ViewportDistance/Distance.texture.get_size()
	$ViewportDistance/Distance.position = $ViewportDistance.size/2;
	$ViewportDistance.render_target_update_mode = Viewport.UPDATE_ONCE
	
	distance_texture = $ViewportDistance.get_texture()
	
	texture_rect.material.set_shader_param("distanceTex", distance_texture)
	
	light2d_node = $GUI/ViewportContainer/Viewport/TextureRect/Light2D
	viewport_container_node = $GUI/ViewportContainer
	$GUI/HBoxContainer_ColorPicker/ColorPickerButton.color = light2d_node.color
	$GUI/ViewportContainer/Viewport/TextureRect.material.set_shader_param("normal_texture", $ViewportNormal.get_texture())

func _on_Normal_toggled(button_pressed):
	$GUI/ViewportContainer/Viewport/TextureRect.material.set_shader_param("normal_preview",button_pressed)


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
	$ViewportNormal.size = $ViewportNormal/Normal.texture.get_size()
	$ViewportNormal/Normal.position = $ViewportNormal.size/2;

	var img = $ViewportNormal.get_texture().get_data()
	img.save_png(current_path)


func _on_TextureButton_pressed():
	# Make the file dialog half the size of the Godot editor and make it popup in the center.
	$FileDialog.rect_size = get_tree().root.size / 2;
	$FileDialog.popup_centered();


func _on_FileDialog_file_selected(path):
	var img = Image.new()
	var itex = ImageTexture.new()
	if (!img.load(path)):
		itex.create_from_image(img)
		var aux = path.rsplit(".",true,1)
		current_path = aux[0]+"_n.png"
		# Create and Load new distance
		$ViewportDistance/Distance.texture = itex
		$ViewportDistance.size = $ViewportDistance/Distance.texture.get_size()
		$ViewportDistance/Distance.position = $ViewportDistance.size/2;
		$ViewportDistance.render_target_update_mode = Viewport.UPDATE_ONCE
		
		texture_rect.texture = itex
		$ViewportNormal.size = texture_rect.texture.get_size()
		texture_rect.position = $ViewportNormal.size/2;
		
		distance_texture = $ViewportDistance.get_texture()

		$GUI/ViewportContainer/Viewport/TextureRect.texture = itex
		texture_rect.material.set_shader_param("distanceTex", distance_texture)
		# Change viewport size to match the new image size
		# Commented this out because i think viewports inside container cannot be resized...
		#$GUI/ViewportContainer/Viewport.size = img.get_size();


# Used for tracking the mouse and other input events.
# Currently this is only used to move the Light2D node.
func _input(event):
	if (event is InputEventMouseButton):
		
		var mouse_pos = get_tree().root.get_mouse_position();
		
		# Check if the mouse is within the bounds of the Viewport container
		# NOTE: this is perhaps not the most performance friendly way of checking, may need to be replaced later.
		if Rect2(viewport_container_node.rect_global_position, viewport_container_node.rect_size).has_point(get_tree().root.get_mouse_position()):
			if event.pressed == true and event.button_index == BUTTON_LEFT:
				
				# First, get the position of the mouse within the rectangle of the ViewportContainer
				var relative_mouse_pos = mouse_pos - rect_global_position
				
				# Get the position relative to the Viewport.
				# First, convert the position so it is in a 0-1 range on both axis.
				var light_pos = relative_mouse_pos / viewport_container_node.rect_size
				# Multiple by the viewport size so the position is within viewport space.
				light_pos *= $GUI/ViewportContainer/Viewport.size
				# Finally, set the position.
				light2d_node.global_position = light_pos


# Changes the Light2D node color based on input from the ColorPickerButton
func _on_ColorPickerButton_color_changed(color):
	light2d_node.color = color


func _on_SpinBoxLightScale_value_changed(value):
	light2d_node.texture_scale = value