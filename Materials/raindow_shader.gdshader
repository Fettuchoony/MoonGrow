shader_type spatial;

vec4 hsv_to_rgb(float h, float s, float v, float a){
	//based on 
	//https://stackoverflow.com/questions/51203917/math-behind-hsv-to-rgb-conversion-of-colors
    // So it needs values from 0 to 1
	float r;
	float g;
	float b;
	
	float i = floor(h*6.0);
	float f = h*6.0 -i;
	float p = v*(1.0-s);
	float q = v*(1.0-f*s);
	float t = v* (1.0-(1.0-f)*s);
	
	int cond = int(i)%6;
	
	if (cond == 0){
		r = v; g = t; b = p;
	}
	else if (cond == 1){
		r = q; g = v; b = p;
	}
	else if (cond == 2){
		r = p; g = v; b = t;
	}
	else if (cond == 3){
		r = p; g = q; b = v;
	}
	else if (cond == 4){
		r = t; g = p; b = v;
	}
	else if (cond == 5){
		r = v; g = p; b = q;
	}
	else {
		// THIS SHOULD NEVER HAPPEN
		r = 0.0; g = 0.0; b = 0.0;
	}
	return vec4(r,g,b,a);
}
	
float atan2(float x, float y){
	if (x > 0.0){
		return atan(y/x);
	}
	else if (x < 0.0){
		if (y >= 0.0){
			return atan(y/x) + PI;
		}
		else {
			return atan(y/x) - PI;
		}
	}
	else { // This is x=0
		if(y > 0.0){
			return PI/2.0;
		}
		else {
			// This includes the actually undefined x=y=0 case
			return -PI/2.0;
		}
	}
	return 1.0;
}

vec2 cartesian_to_polar(vec2 XY){
	float r = length(XY);
	float phi = (atan2(XY[0],XY[1]) + PI)/(2.0*PI);
	// We shift the atan2 to the [0,2pi] range and then normalize
	return vec2(r,phi);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Center coordinates
	vec2 XY = 2.0*UV - 1.0;
	vec2 RPhi = cartesian_to_polar(XY);
	float r = RPhi[0];
	float phi = RPhi[1];
	ALBEDO = hsv_to_rgb(TIME + phi,r,1.0,0.5).xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
