shader_type canvas_item;

uniform int iterations = 40;
uniform vec2 pos = vec2(0.0, 0.0);
uniform float zoom = 1.0;
uniform float aspect_ratio;
uniform int order = 2;
uniform float brightness = 1.0;

uniform vec3 starting_color = vec3(0.0, 0.0, 0.0);
uniform vec3 ending_color = vec3(0.4, 0.8, 0.6);

vec2 mult(vec2 a, vec2 b) {
	vec2 res;
	res.x = a.x * b.x - a.y * b.y;
	res.y = a.x * b.y + a.y * b.x;
	return res;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 c;
	c.x = ((UV.x) * 2.0 - 1.0) * aspect_ratio * zoom - pos.x * aspect_ratio;
	c.y = ((UV.y) * 2.0 - 1.0) * zoom + pos.y;
	
	vec2 z = vec2(0.0, 0.0);
	
	float total = 0.0;
	vec3 color = vec3(0.4, 0.8, 0.6);
	bool escaped = false;
	
	for (int i = 0; i < iterations; i++) {
		vec2 product = z;
		for (int j = 0; j < order-1; j++) {
			product = mult(z, product);
		}
		z = product + c;
		
		if (length(z) > 256.0) {
			total = float(i);
			escaped = true;
			break;
		}
	}
	
	if (escaped) {
		float smooth_iterations = (total+1.0) - log(log(length(z)) / log(256.0)) / log(float(order));
		color = mix(starting_color, ending_color, float(smooth_iterations) / float(iterations));
	} else {
		color = vec3(0.0);
	}
	
	COLOR = vec4(color * brightness, 1.0);
}

void light() {}
void vertex() {}