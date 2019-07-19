shader_type canvas_item;

uniform bool normal_preview = false;
uniform sampler2D normal_texture;

void fragment(){
	COLOR = texture(TEXTURE,UV);
	NORMAL= texture(normal_texture, UV).xyz*2.0-1.0;
	if (normal_preview){
		COLOR = texture(normal_texture, UV);
	}
}


void light(){
	if (normal_preview){
		LIGHT = vec4(0.0)
	}
}
