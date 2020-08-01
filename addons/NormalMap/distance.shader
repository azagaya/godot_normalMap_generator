shader_type canvas_item;

vec4 borders(sampler2D texture, vec2 texCoord){
	if(texCoord.x > 1.0 || texCoord.y > 1.0 || texCoord.x < 0.0 || texCoord.y < 0.0)
		return vec4(0.0);
	return vec4(vec3(float(texture(texture, texCoord).a != 0.0)),1.0);
}

void fragment(){
	vec2 texCoord = UV;
	int bump = int(max(1.0/TEXTURE_PIXEL_SIZE.x,1.0/TEXTURE_PIXEL_SIZE.y)/2.0);
	vec2 offset = TEXTURE_PIXEL_SIZE;
	float dist = sqrt(2.0)*float(bump);
	bool d1 = false, d2 = false, d3 = false, d4 = false;
	for (int i = 0; i <= bump; i++){
		for (int j = -i; j<=i; j++){
			d1 = (borders(TEXTURE, texCoord+vec2(float(i)*offset.x,float(j)*offset.y)).r == 0.0);
			d2 = (borders(TEXTURE, texCoord+vec2(-float(i)*offset.x,float(j)*offset.y)).r == 0.0);
			d3 = (borders(TEXTURE, texCoord+vec2(float(j)*offset.x,float(i)*offset.y)).r == 0.0);
			d4 = (borders(TEXTURE, texCoord+vec2(float(j)*offset.x,-float(i)*offset.y)).r == 0.0);
			if (d1 || d2 || d3 || d4){
				dist = min(dist,sqrt(pow(float(i),2.0)+pow(float(j),2.0)));
			}
		}
	} 
	dist /= sqrt(2.0)*float(bump);
	COLOR = vec4(vec3(dist),1.0);
}
