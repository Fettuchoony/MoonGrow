
shader_type spatial;
render_mode cull_disabled;

const int PORTAL_COUNT_SHADER_MAX = 16;
const int IN_OVERWORLD = 1;
const int IN_UNDERWORLD = 2;

uniform int portal_count = 0;
uniform vec3 portal_positions[16];
uniform vec3 portal_norms[16];
uniform vec3 portal_rights[16];
uniform vec3 portal_ups[16];

uniform vec2 portal_half_size = vec2(2.5, 2.5);
uniform float portal_plane_epsilon = 0.02;
uniform float portal_parallel_epsilon = 0.0000001;
uniform int player_dimension = 1;
instance uniform int visual_layer = 1;
// TODO : change the clip plane pos and norm to portal pos and norm

instance uniform bool portal_clipping_enabled = false;
instance uniform vec3 clip_plane_position = vec3(0.0);
instance uniform vec3 clip_plane_normal = vec3(0.0, 0.0, 1.0);
instance uniform float clip_side = 1.0;
instance uniform bool is_transition_object = false;
instance uniform int debug_copy_type = 0;
instance uniform bool debug_dimension = true;


uniform bool debug_portal_intersection = false;


// Test whether a point is inside one portal's rectangular bounds.
// All vectors must be in world space.
bool point_inside_portal(
    vec3 point,
    vec3 center,
    vec3 normal,
    vec3 right,
    vec3 up,
    vec2 half_size
) {
    vec3 relative = point - center;

    vec3 n = normalize(normal);
    vec3 r = normalize(right);
    vec3 u = normalize(up);

    // The intersection should lie on the portal plane.
    float plane_distance = abs(dot(relative, n));
    if (plane_distance > portal_plane_epsilon) {
        return false;
    }

    float local_x = dot(relative, r);
    float local_y = dot(relative, u);

    return abs(local_x) <= half_size.x
        && abs(local_y) <= half_size.y;
}


// Intersect a camera ray with one portal.
// Returns the intersection distance along the normalized ray.
bool ray_hits_portal(
    vec3 ray_origin,
    vec3 ray_direction,
    vec3 center,
    vec3 normal,
    vec3 right,
    vec3 up,
    vec2 half_size,
    out vec3 intersection,
    out float distance_to_portal
) {
    intersection = vec3(0.0);
    distance_to_portal = 0.0;

    float normal_length = length(normal);
    if (normal_length < 0.00001) {
        return false;
    }

    vec3 n = normal / normal_length;
    float denominator = dot(ray_direction, n);

	// Reject rays that are nearly parallel to the portal plane.
	if (abs(denominator) < portal_parallel_epsilon) {
	    return false;
	}

	float t = dot(center - ray_origin, n) / denominator;

	if (t <= 0.0) {
	    return false;
	}

	intersection = ray_origin + ray_direction * t;

	if (!point_inside_portal(
	    intersection, center, n, right, up, half_size
	)) {
	    return false;
	}

	distance_to_portal = t;
	return true;
}


void vertex() {
}


void fragment() {
	//if (debug_copy_type == 1) {
	    //ALBEDO = vec3(1.0, 0.0, 0.0); // Source copy: red
//
	//}
//
	//if (debug_copy_type == 2) {
	    //ALBEDO = vec3(0.0, 0.0, 1.0); // Destination copy: blue
//
	//}
    int active_portals = clamp(
        portal_count,
        0,
        PORTAL_COUNT_SHADER_MAX
    );
	
	vec3 world_hit = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 fragment_world_position = world_hit;

	if (portal_clipping_enabled) {
	    float normal_length = length(clip_plane_normal);

	    if (normal_length > 0.00001) {
	        vec3 plane_normal = clip_plane_normal / normal_length;

	        float signed_distance = dot(
	            fragment_world_position - clip_plane_position,
	            plane_normal
	        );

	        // Keep the side selected by clip_side.
	        if (signed_distance * clip_side < 0.0) {
	            discard;
	        }
	    }
	}

    bool same_dimension = (player_dimension == visual_layer);

    vec3 ray_origin = CAMERA_POSITION_WORLD;
    vec3 ray_vector = world_hit - ray_origin;
    float fragment_distance = length(ray_vector);

    if (fragment_distance < 0.0001) {
        discard;
    }

    vec3 ray_direction = normalize(ray_vector);

    bool through_portal = false;
    float nearest_portal_distance = 1e20;

    // Each portal is tested with its own transform and bounds.
    for (int i = 0; i < PORTAL_COUNT_SHADER_MAX; i++) {
        if (i >= active_portals) {
            break;
        }

        vec3 normal = portal_norms[i];
        vec3 right = portal_rights[i];
        vec3 up = portal_ups[i];

        if (length(normal) < 0.00001
            || length(right) < 0.00001
            || length(up) < 0.00001) {
            continue;
        }

        vec3 intersection;
        float distance_to_portal;

        if (ray_hits_portal(
            ray_origin,
            ray_direction,
            portal_positions[i],
            normal,
            right,
            up,
            portal_half_size,
            intersection,
            distance_to_portal
        )) {
            // Only portals closer than this terrain fragment count.
            if (
                distance_to_portal < fragment_distance
                && distance_to_portal < nearest_portal_distance
            ) {
                nearest_portal_distance = distance_to_portal;
                through_portal = true;
            }
        }
    }

	bool visible = (same_dimension && !through_portal)
	    || (!same_dimension && through_portal);

	if (debug_portal_intersection) {
	    if (!through_portal) {
	        ALBEDO = vec3(1.0, 0.0, 1.0); // Magenta: no portal hit
	    } else if (same_dimension) {
	        ALBEDO = vec3(1.0, 0.0, 0.0); // Red: current dimension
	    } else {
	        ALBEDO = vec3(0.0, 1.0, 0.0); // Green: other dimension
	    }

	    	EMISSION = ALBEDO * 0.2;
	}
	
	
	if (debug_dimension) {
		if (visual_layer == 2) {
			ALBEDO = vec3(1.0, 0.0, 0.0); // Red if underworld 
		} else if (visual_layer == 1) {
			ALBEDO = vec3(0.0, 1.0, 0.0); // Green if overworld
		} else {
			ALBEDO = vec3(0.0, 0.0, 1.0); // Blue if invalid dimension
		}
		EMISSION = ALBEDO * 0.2;
	}

	if (!visible) {
    	discard;
	}
	
}
