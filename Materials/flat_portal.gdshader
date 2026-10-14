
shader_type spatial;
render_mode cull_disabled;

const int PORTAL_COUNT_SHADER_MAX = 16;
const int IN_OVERWORLD = 1;
const int IN_UNDERWORLD = 2;

uniform vec3 portal_rights[16];
uniform vec3 portal_ups[16];

uniform int portal_count = 0;
uniform vec3 portal_positions[16];
uniform vec3 portal_norms[16];

// Half-width and half-height of every rectangular portal.
uniform vec2 portal_half_size = vec2(2.5, 2.5);

// Small tolerances in world units.
uniform float portal_plane_epsilon = 0.02;
uniform float portal_parallel_epsilon = 0.0001;

uniform int player_dimension = 1;

// Set per material instance / GeometryInstance3D.
instance uniform int visual_layer = 1;

// Optional debugging visualization.
uniform bool debug_portal_intersection = false;


// Test the rectangular bounds only.
// This does not enforce a front/back-facing direction.

bool point_inside_portal(
    vec3 point,
    vec3 center,
    vec3 normal,
    vec3 right,
    vec3 up,
    vec2 half_size
) {
    vec3 n = normalize(normal);
	vec3 r = normalize(right);
	vec3 u = normalize(up);

	vec3 relative = point - center;

	if (abs(dot(relative, n)) > portal_plane_epsilon) {
	    return false;
	}

	float local_x = dot(relative, r);
	float local_y = dot(relative, u);

	return abs(local_x) <= half_size.x
	    && abs(local_y) <= half_size.y;
}



// Intersect a ray with a portal plane and check its finite bounds.
// Returns true only when the intersection is in front of the camera.
bool ray_hits_portal(
    vec3 ray_origin,
    vec3 ray_direction,
    vec3 center,
    vec3 normal,
    vec3 right,
    vec3 up,
    vec2 half_size,
    out vec3 intersection
) {
    float denominator = dot(ray_direction, normal);

    if (abs(denominator) < portal_parallel_epsilon) {
        return false;
    }

    float t = dot(center - ray_origin, normal) / denominator;

    if (t < 0.0) {
        return false;
    }

    intersection = ray_origin + ray_direction * t;

    return point_inside_portal(
        intersection,
        center,
        normal,
        right,
        up,
        half_size
    );
}


void vertex() {
    // With world_vertex_coords, VERTEX is in world coordinates.
}


void fragment() {
    int active_portals = clamp(
        portal_count,
        0,
        PORTAL_COUNT_SHADER_MAX
    );

    bool same_dimension = (player_dimension == visual_layer);

    // Fragment VERTEX is in view space.
    // Convert it to world space exactly once.
    vec3 world_hit = (
        INV_VIEW_MATRIX * vec4(VERTEX, 1.0)
    ).xyz;

    vec3 ray_origin = CAMERA_POSITION_WORLD;
    vec3 ray_vector = world_hit - ray_origin;
    float fragment_distance = length(ray_vector);

    if (fragment_distance < 0.0001) {
        discard;
    }

    vec3 ray_direction = ray_vector / fragment_distance;

    bool through_portal = false;
    float nearest_portal_distance = 1e20;

    for (int i = 0; i < PORTAL_COUNT_SHADER_MAX; i++) {
        if (i >= active_portals) {
            break;
        }

        vec3 normal = normalize(portal_norms[i]);

        if (length(portal_norms[i]) < 0.00001) {
            continue;
        }

        vec3 intersection;

        if (ray_hits_portal(
            ray_origin,
            ray_direction,
            portal_positions[i],
            normal,
            portal_rights[i],
            portal_ups[i],
            portal_half_size,
            intersection
        )) {
            float distance_to_portal =
                length(intersection - ray_origin);

            if (
                distance_to_portal < fragment_distance
                && distance_to_portal < nearest_portal_distance
            ) {
                nearest_portal_distance = distance_to_portal;
                through_portal = true;
            }
        }
    }

	

    if (debug_portal_intersection) {
	    ALBEDO = through_portal
	        ? vec3(0.0, 1.0, 0.0)
	        : vec3(1.0, 0.0, 1.0);
	    EMISSION = ALBEDO * 0.2;
	}

	bool visible = (same_dimension && !through_portal)
	    || (!same_dimension && through_portal);

	if (!visible) {
	    discard;
	}
}
