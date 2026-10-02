shader_type spatial;
render_mode world_vertex_coords;

// This is the hard cap from the shader, should mirror uniform portal_count
const int PORTAL_COUNT_SHADER_MAX = 16;


// Is global coords for all ins
uniform int portal_count;
uniform vec3[PORTAL_COUNT_SHADER_MAX] portal_positions;
uniform bool is_dimension = true;



void vertex() {
	// Called for every vertex the material is visible on.
	// O = this object
	// P = portal
	// C = cam/player
	
	// Object Vertex ----> Portals
	vec3[PORTAL_COUNT_SHADER_MAX] OtPs;
	// Not entire array is traversed because they could be empty
	for (int i = 0; i < portal_count; i++) {
		OtPs[i] = portal_positions[i] - VERTEX;
		// If this object is not in the dimension (ie only visible thru portal)
		if (!is_dimension && dot(normalize(CAMERA_DIRECTION_WORLD), normalize(OtPs[i])) < 0.0) {
			POSITION = vec4(0.0,0.0,0.0,0.0);
		}
	}
	
}

void fragment() {
	// Called for every pixel the material is visible on.
	// Test
	ALBEDO = vec3(255.0, 0.0, 0.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
