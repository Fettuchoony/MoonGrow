shader_type spatial;
render_mode unshaded;

uniform sampler2D overworld_texture : hint_screen_texture;
uniform sampler2D underworld_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = texture(underworld_texture, SCREEN_UV).xyz;
	ALBEDO = ALBEDO;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
