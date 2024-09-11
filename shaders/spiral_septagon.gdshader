shader_type canvas_item;

uniform int iterations = 40;
uniform vec2 pos = vec2(0.0, 0.0);
uniform float zoom = 1.0;
uniform float aspect_ratio;
uniform float brightness = 1.0;

uniform vec3 starting_color = vec3(0.0, 0.0, 0.0);
uniform vec3 ending_color = vec3(0.4, 0.8, 0.6);

vec2 mult(vec2 a, vec2 b) {
	vec2 res;
	res.x = a.x * b.x - a.y * b.y;
	res.y = a.x * b.y + a.y * b.x;
	return res;
}

vec2 div(vec2 v1, vec2 v2) {
	float a = v2.x;
	float b = v2.y;
	float c = v1.x;
	float d = v1.y;
	
	return vec2((c * a + b * d) / (a * a + b * b), ((a * d - c * b) / (a * a + b * b)));
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 z;
	z.x = ((UV.x) * 2.0 - 1.0) * aspect_ratio * zoom - pos.x * aspect_ratio;
	z.y = ((UV.y) * 2.0 - 1.0) * zoom + pos.y;
	
	float total = 0.0;
	vec3 color = vec3(0.4, 0.8, 0.6);
	bool escaped = false;
	float phi = -0.7/5.0;
	
	for (int i = 0; i < iterations; i++) {
		vec2 product = z;
		for (int j = 0; j < 6; j++) {
			product = mult(z, product);
		}
		z = div(vec2(product.x + phi, product.y), z);
		
		if (length(z) > 256.0) {
			total = float(i);
			escaped = true;
			break;
		}
	}
	
	if (escaped) {
		float smooth_iterations = (total+1.0) - log(log(length(z)) / log(256.0)) / log(2.0);
		color = mix(starting_color, ending_color, float(smooth_iterations) / float(iterations));
	} else {
		color = vec3(0.0);
	}
	
	COLOR = vec4(color * brightness, 1.0);
}

void light() {}
void vertex() {}