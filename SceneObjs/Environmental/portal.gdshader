shader_type spatial;
render_mode unshaded, cull_front;

//uniform sampler2D overworld_texture : hint_screen_texture, source_color;
uniform sampler2D underworld_texture : source_color;
uniform float deactive_z;
uniform float z_slice;
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

	// 1. Transform vertex from View Space to World Space
    vec4 world_vertex = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
    
    // 2. Transform from World Space to Local/Model Space using the inverse model matrix
    vec3 local_vertex = (inverse(MODEL_MATRIX) * world_vertex).xyz;
	
	// if negative
	if ((deactive_z < z_slice && local_vertex.z > 0.0) || (deactive_z > z_slice && local_vertex.z < 0.0)) {
		
		vec2 finalUV = SCREEN_UV;
		
		// Called for every pixel the material is visible on.
		ALBEDO = texture(underworld_texture, finalUV).xyz;
	} else {

		ALPHA = 0.0;
	}
	//ALBEDO = ALBEDO;
}

//void light() {
	//// Called for every pixel for every light affecting the material.
	//
    //DIFFUSE_LIGHT = vec3(100.0, 100.0, 100.0);
	//SPECULAR_LIGHT = vec3(100.0, 100.0, 100.0);
//}
