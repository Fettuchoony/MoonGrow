shader_type spatial;
render_mode unshaded, cull_front;

//uniform sampler2D overworld_texture : hint_screen_texture, source_color;
uniform sampler2D underworld_texture : source_color;
//uniform vec3 test : source_color;

void vertex() {
	// Non-flat distortion: warp UVs based on surface normal deviation
    //vec3 norm = normalize(NORMAL);
    //vec3 viewDir = normalize(VERTEX - (vec4(NODE_POSITION_VIEW, 0.0) * VIEW_MATRIX).xyz);
    //
    //// Displace UV coordinates dynamically based on the non-planar curvature angle
    //vec2 warp = dot(norm, viewDir) * 0.1 * norm.xy;
    //vec2 finalUV = clamp(VERTEX.xy + warp, 0.05, 0.95);
	//
	//// Called for every pixel the material is visible on.
	//ALBEDO = texture(underworld_texture, vec3(finalUV, 1.0));
}

void fragment() {
	//
	//// Non-flat distortion: warp UVs based on surface normal deviation
    //vec3 norm = normalize(NORMAL);
    //vec3 viewDir = normalize(FRAGCOORD.xyz - VIEW);
    //
    //// Displace UV coordinates dynamically based on the non-planar curvature angle
    //vec2 warp = dot(norm, viewDir) * 0.1 * norm.xy;
    //vec2 finalUV = clamp(SCREEN_UV + warp, 0.05, 0.95);
	
	vec2 finalUV = SCREEN_UV;
	
	// Called for every pixel the material is visible on.
	ALBEDO = texture(underworld_texture, finalUV).xyz;
	//ALBEDO = ALBEDO;
}

//void light() {
	//// Called for every pixel for every light affecting the material.
	//
    //DIFFUSE_LIGHT = vec3(100.0, 100.0, 100.0);
	//SPECULAR_LIGHT = vec3(100.0, 100.0, 100.0);
//}
