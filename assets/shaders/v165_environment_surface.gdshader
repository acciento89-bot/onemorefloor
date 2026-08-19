shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.12, 0.13, 0.16, 1.0);
uniform vec4 detail_color : source_color = vec4(0.20, 0.22, 0.27, 1.0);
uniform vec4 emission_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_strength : hint_range(0.0, 2.0) = 0.0;
uniform float metallic_level : hint_range(0.0, 1.0) = 0.0;
uniform float roughness_level : hint_range(0.05, 1.0) = 0.88;
uniform float variation_scale : hint_range(0.25, 8.0) = 2.0;
uniform float variation_strength : hint_range(0.0, 0.5) = 0.16;
uniform float edge_response : hint_range(0.0, 0.18) = 0.035;
uniform float ground_ao_strength : hint_range(0.0, 0.35) = 0.10;

varying vec3 world_pos;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_pos.xz * variation_scale;
	float broad = 0.5 + 0.5 * sin(p.x * 1.21 + sin(p.y * 0.77) * 1.7) * cos(p.y * 1.43);
	float cell = hash21(floor(p * 2.35));
	float fine = 0.5 + 0.5 * sin(p.x * 5.1 + p.y * 3.7 + cell * 2.6);
	float wear = clamp(broad * 0.52 + fine * 0.27 + cell * 0.21, 0.0, 1.0);
	float blend_amount = clamp((wear - 0.28) * variation_strength, 0.0, 0.42);
	vec3 color = mix(base_color.rgb, detail_color.rgb, blend_amount);

	float ground_band = 1.0 - smoothstep(0.02, 0.42, max(world_pos.y, 0.0));
	color *= 1.0 - ground_band * ground_ao_strength;

	float view_edge = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	color += detail_color.rgb * view_edge * edge_response;

	ALBEDO = color;
	METALLIC = metallic_level;
	ROUGHNESS = clamp(roughness_level - (broad - 0.5) * 0.08, 0.05, 1.0);
	EMISSION = emission_color.rgb * emission_strength * (0.88 + broad * 0.22);
}
