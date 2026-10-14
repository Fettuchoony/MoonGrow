shader_type spatial;
render_mode world_vertex_coords;

// This is the hard cap from the shader, should mirror uniform portal_count
const int PORTAL_COUNT_SHADER_MAX = 16;

const int IN_OVERWORLD = 1;
const int IN_UNDERWORLD = 2;

// We need the depth texture to reconstruct world coordinates
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

// Is global coords for all ins
uniform int portal_count;
uniform vec3[PORTAL_COUNT_SHADER_MAX] portal_positions;
uniform vec3[PORTAL_COUNT_SHADER_MAX] portal_norms;
uniform int player_dimension = 1;

// The 'instance' qualifier exposes this per object instance
instance uniform int visual_layer = 1; 


void vertex() {
	
}

// Helper function to build an orthonormal basis (tangent and bitangent) from a normal
void getPlaneBasis(vec3 normal, out vec3 tangent, out vec3 bitangent) {
    vec3 n_abs = abs(normal);
    vec3 v1;
    if (n_abs.x < n_abs.y && n_abs.x < n_abs.z) {
        v1 = vec3(1.0, 0.0, 0.0);
    } else if (n_abs.y < n_abs.z) {
        v1 = vec3(0.0, 1.0, 0.0);
    } else {
        v1 = vec3(0.0, 0.0, 1.0);
    }
    tangent = normalize(cross(normal, v1));
    bitangent = cross(normal, tangent);
}

// Returns true if 'point' is on the finite plane
bool isPointOnFinitePlane(
    vec3 point, 
    vec3 planeCenter, 
    vec3 planeNormal, 
    vec2 halfSize, 
    float thicknessThreshold
) {
    vec3 n = normalize(planeNormal);
    vec3 toPoint = point - planeCenter;
    
    // 1. Check if the point lies on the infinite plane (distance along normal is ~0)
    float distToPlane = dot(toPoint, n);
    if (abs(distToPlane) > thicknessThreshold) {
        return false;
    }
    
    // 2. Build local plane axes
    vec3 tangent, bitangent;
    getPlaneBasis(n, tangent, bitangent);
    
    // 3. Project the vector onto the plane's local 2D coordinates
    float localX = dot(toPoint, tangent);
    float localY = dot(toPoint, bitangent);
    
    // 4. Check if local coordinates fall within the finite bounds (-halfSize to +halfSize)
	// FIX THIS SJKLADHFG;IKLUSBDFG;OIUBH'ILB
    if (abs(localX) <= halfSize.x && abs(localY) <= halfSize.y && dot(normalize(toPoint), n) < -0.01) {
        return true;
    }
    
    return false;
}



void fragment() {
	bool discard_flag = false;
	if (player_dimension != visual_layer) {
		discard_flag = true;
	}
	
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
			bool on_plane = isPointOnFinitePlane(intersection_world, plane_center, plane_normal, vec2(2.5,2.5), 0.1);
			if (on_plane && player_dimension != visual_layer) {
				ALBEDO = vec3(0.0,1.0,0.0);
				discard_flag = false;
			// occlude in dimension
			} else if (on_plane && player_dimension == visual_layer){
				discard_flag = true;
			}
            
        } else {
            //ALBEDO = vec3(1.0,0.0,0.0); // Intersection point is behind the camera view
			
        }
    } else {
         // Ray is parallel to the plane, it will never hit
		
    }
	if (discard_flag) {
		discard;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
