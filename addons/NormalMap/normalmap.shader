shader_type canvas_item;

uniform bool normal_preview = false;
uniform float emboss_height : hint_range(0,100) = 0.1;
uniform float bump_height : hint_range(0,100) = 0.3;
uniform int blur : hint_range(0,10) = 5;
uniform int bump : hint_range(0,100) = 60;

uniform bool invertX = true;
uniform bool invertY = true;
uniform bool with_distance = true;
uniform bool with_emboss = true;

uniform sampler2D distanceTex;

vec4 gray_scale(sampler2D TEXTURE, vec2 texCoord){
	vec4  FragColor = texture(TEXTURE, texCoord);
    float average = 0.2126 * FragColor.r + 0.7152 * FragColor.g + 0.0722 * FragColor.b;
    return vec4(average, average, average, 1.0);
}

vec4 borders(sampler2D TEXTURE, vec2 texCoord){
	if(texCoord.x > 1.0 || texCoord.y > 1.0 || texCoord.x < 0.0 || texCoord.y < 0.0)
		return vec4(0.0);
	return vec4(vec3(float(texture(TEXTURE, texCoord).a != 0.0)),1.0);
}

void fragment() {
	vec2 offset = TEXTURE_PIXEL_SIZE;
	float x0 = 0.0;
	float x1 = 0.0;
	float y0 = 0.0;
	float y1 = 0.0;
	float distx0 = 0.0;
	float distx1 = 0.0;
	float disty0 = 0.0;
	float disty1 = 0.0;
	float blur_den = 0.0;
	for(int i=-blur; i <= blur ; i++){
		for (int j = -blur; j<= blur; j++){
			float coef = exp(-(pow(float(i),2.0)+pow(float(j),2.0)/18.0));
			blur_den += coef;
			if(with_emboss){
				x0 += gray_scale(TEXTURE,UV-vec2(offset.x,0.0)+vec2(float(i)*offset.x,float(j)*offset.y)).r*coef;//(8.0*float(blur)+1.0);
				x1 += gray_scale(TEXTURE,UV+vec2(offset.x,0.0)+vec2(float(i)*offset.x,float(j)*offset.y)).r*coef;//(8.0*float(blur)+1.0);
				y0 += gray_scale(TEXTURE,UV-vec2(0.0,offset.y)+vec2(float(i)*offset.x,float(j)*offset.y)).r*coef;//(8.0*float(blur)+1.0);
				y1 += gray_scale(TEXTURE,UV+vec2(0.0,offset.y)+vec2(float(i)*offset.x,float(j)*offset.y)).r*coef;//(8.0*float(blur)+1.0);
			}
			if(with_distance){
				distx0 += texture(distanceTex,UV+vec2(-offset.x,0.0)+vec2(float(i)*offset.x,float(j)*offset.y)).r*coef;//(8.0*float(blur)+1.0);
				distx1 += texture(distanceTex,UV+vec2(offset.x,0.0)+vec2(float(i)*offset.x,float(j)*offset.y)).r*coef;//(8.0*float(blur)+1.0);
				disty0 += texture(distanceTex,UV+vec2(0.0,-offset.y)+vec2(float(i)*offset.x,float(j)*offset.y)).r*coef;//(8.0*float(blur)+1.0);
				disty1 += texture(distanceTex,UV+vec2(0.0,offset.y)+vec2(float(i)*offset.x,float(j)*offset.y)).r*coef;//(8.0*float(blur)+1.0);
			}
		}
	}
	x0 /= blur_den;	x1 /= blur_den;	y0 /= blur_den;	y1 /= blur_den;
	distx0 /= blur_den;	distx1 /= blur_den;	disty0 /= blur_den;	disty1 /= blur_den;
	
	distx0 = min(distx0 * 255.0 / float(bump),1.0);
	distx1 = min(distx1 * 255.0 / float(bump),1.0);
	disty0 = min(disty0 * 255.0 / float(bump),1.0);
	disty1 = min(disty1 * 255.0 / float(bump),1.0);
	
	distx0 = sqrt(1.0-pow((distx0-1.0),2));
	distx1 = sqrt(1.0-pow((distx1-1.0),2));
	disty0 = sqrt(1.0-pow((disty0-1.0),2));
	disty1 = sqrt(1.0-pow((disty1-1.0),2));
	
	float dx = (-2.0*float(invertX)+1.0)*(-x0+x1)*0.5/offset.x;

	float dy = (-2.0*float(invertY)+1.0)*(-y0+y1)*0.5/offset.y;
	vec3 normal = (normalize(vec3(dx*emboss_height,dy*emboss_height,1.0)));
	vec4 tex = texture(TEXTURE, UV);


	float offx = 0.0;
	float offy = 0.0;

	float bx = (-2.0*float(invertX)+1.0)*(-distx0+distx1)*0.5/offset.x;
	float by = (-2.0*float(invertY)+1.0)*(-disty0+disty1)*0.5/offset.y;
	vec3 normal_b = (normalize(vec3(bx*bump_height,by*bump_height,1.0)));

	normal = 0.5*normalize(normal+normal_b)+0.5;

	if (!normal_preview)
		COLOR = tex;
	else 
		COLOR = vec4(normal,tex.a);

	NORMAL = normal * 2.0 - 1.0;
	//COLOR = vec4(vec3(distx0),tex.a);
}

void light(){
	if (normal_preview){
		LIGHT = vec4(0.0);
	}
}