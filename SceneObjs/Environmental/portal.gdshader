shader_type spatial;
render_mode unshaded, cull_disabled;

//uniform sampler2D overworld_texture : hint_screen_texture, source_color;
uniform sampler2D underworld_texture : source_color;
//uniform vec3 test : source_color;

void vertex() {
	// Called for every ertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = texture(underworld_texture, SCREEN_UV).xyz;
	//ALBEDO = ALBEDO;
}

//void light() {
	//// Called for every pixel for every light affecting the material.
	//
    //DIFFUSE_LIGHT = vec3(100.0, 100.0, 100.0);
	//SPECULAR_LIGHT = vec3(100.0, 100.0, 100.0);
//}
