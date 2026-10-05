shader_type spatial;
render_mode world_vertex_coords;

// This is the hard cap from the shader, should mirror uniform portal_count
const int PORTAL_COUNT_SHADER_MAX = 16;


// Is global coords for all ins
uniform int portal_count;
uniform vec3[PORTAL_COUNT_SHADER_MAX] portal_positions;
uniform bool is_dimension = true;

varying float a;


void vertex() {
	// Called for every vertex the material is visible on.
	// Every vertex cast ray to camera
	vec3[PORTAL_COUNT_SHADER_MAX] CtO;
	for (int i = 0; i < 1; i++) {
		vec3 hit_point = vec3(0.0,0.0,0.0);
		CtO[i] = CAMERA_POSITION_WORLD - VERTEX;
		vec3 temp_norm = vec3(0.0,0.0,1.0);
		float d = dot(temp_norm, CtO[i]);
		if (abs(d) > 1e-6) {
			float t = dot(CtO[i] - CAMERA_POSITION_WORLD, temp_norm)/d;
			if (t > 0.0) {
				hit_point = CAMERA_POSITION_WORLD + CtO[i] * t;
				// CHANGE THIS IS DEBUG
				if (hit_point.x < CtO[i].x + 2.5 && hit_point.x > CtO[i].x - 2.5) {
					a = 1.0;
					//COLOR = vec4(0.0,0.0,0.0,0.0);
				} else {
					a = 0.0;
				}
			}
		}
		
	}
}

void fragment() {
	ALPHA = a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
