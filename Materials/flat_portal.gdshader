shader_type spatial;
render_mode world_vertex_coords;

// This is the hard cap from the shader, should mirror uniform portal_count
const int PORTAL_COUNT_SHADER_MAX = 16;

// We need the depth texture to reconstruct world coordinates
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

// Is global coords for all ins
uniform int portal_count;
uniform vec3[PORTAL_COUNT_SHADER_MAX] portal_positions;
uniform vec3[PORTAL_COUNT_SHADER_MAX] portal_norms;
uniform bool is_dimension = true;


void vertex() {
	
}

// p = target point
// pivot = center of portal
// vec3 = axis, likely y because up
// angle
vec3 rotatePointAboutAxis(vec3 p, vec3 pivot, vec3 axis, float angle) {
    // 1. Translate the point relative to the pivot
    vec3 v = p - pivot;
    
    // 2. Ensure the axis (normal) is a unit vector
    vec3 n = normalize(axis);
    
    // 3. Rodrigues' Rotation Formula components
    float cosTheta = cos(angle);
    float sinTheta = sin(angle);
    
    vec3 vCos = v * cosTheta;
    vec3 vCross = cross(n, v) * sinTheta;
    vec3 vDot = n * dot(n, v) * (1.0 - cosTheta);
    
    // 4. Combine components and translate back to the pivot
    return vCos + vCross + vDot + pivot;
}

void fragment() {
	
	// Define your target plane using a Center Position and Normal vector
	vec3 plane_center = portal_positions[0]; // Absolute center point in World Space
	vec3 plane_normal = portal_norms[0];
    
    // 4. Convert View Space to World Space (Object Hit Point)
    vec4 world_pos = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
    vec3 hit_point_world = world_pos.xyz;
    
    // 6. Calculate Ray Direction (Camera -> Object Hit Point)
    vec3 ray_dir = normalize(hit_point_world - CAMERA_POSITION_WORLD);
    
    // 7. Calculate Ray-Plane Intersection using the Plane Center
    // Formula: t = dot(plane_center - ray_origin, normal) / dot(ray_dir, normal)
    float denominator = dot(ray_dir, plane_normal);
    
    // Prevent division by zero if ray runs perfectly parallel to the plane
    if (abs(denominator) > 0.0001) {
        float t = dot(plane_center - CAMERA_POSITION_WORLD, plane_normal) / denominator;
        
        // Check if the intersection happens in front of the camera (t >= 0)
        if (t >= 0.0) {
			// Intersect point in world space
            vec3 intersection_world = CAMERA_POSITION_WORLD + ray_dir * t;
            
            vec3 relative_pos = intersection_world - plane_center;
			bool in_bounds = intersection_world.x < plane_center.x + 2.5 && intersection_world.x > plane_center.x -2.5;
		 	// needs updating
			bool in_front = world_pos.z < 0.0;
			if (in_bounds && in_front) {
				ALBEDO = portal_positions[0];
			}
            
        } else {
            ALBEDO = vec3(1.0,0.0,0.0); // Intersection point is behind the camera view
        }
    } else {
        discard; // Ray is parallel to the plane, it will never hit
    }
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
