shader_type spatial;
render_mode cull_back;

// ONE MORE FLOOR v1.60 — lightweight authored-surface depth shader.
// Designed for the GL Compatibility/mobile path: no texture lookups, no
// screen-space effects and no extra passes. The imported mesh geometry stays
// authoritative while subtle normal/height/rim variation removes flat plastic
// shading from the production tower assets.

uniform vec4 base_color : source_color = vec4(0.25, 0.27, 0.32, 1.0);
uniform vec4 edge_color : source_color = vec4(0.48, 0.52, 0.62, 1.0);
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.75;
uniform float specular_level : hint_range(0.0, 1.0) = 0.30;
uniform float edge_strength : hint_range(0.0, 0.65) = 0.18;
uniform float height_strength : hint_range(0.0, 0.20) = 0.04;
uniform float variation_strength : hint_range(0.0, 0.08) = 0.02;
uniform vec4 emission_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_strength : hint_range(0.0, 1.0) = 0.0;

varying vec3 local_position;
varying vec3 local_normal;

void vertex() {
	local_position = VERTEX;
	local_normal = NORMAL;
}

void fragment() {
	vec3 n_local = normalize(local_normal);
	float top_light = smoothstep(-0.20, 0.90, n_local.y);
	float underside = 1.0 - smoothstep(-0.78, 0.16, n_local.y);
	float height_factor = clamp(local_position.y * 0.18 + 0.50, 0.0, 1.0);
	float variation = sin(local_position.x * 2.10 + local_position.z * 1.30)
		* sin(local_position.z * 2.60 - local_position.y * 1.70);

	float shade = 0.88
		+ top_light * 0.11
		+ height_factor * height_strength
		+ variation * variation_strength
		- underside * 0.10;

	vec3 shaded = base_color.rgb * shade;
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float rim = pow(1.0 - facing, 2.30);
	shaded = mix(shaded, edge_color.rgb, clamp(rim * edge_strength, 0.0, 0.65));

	ALBEDO = shaded;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular_level;
	EMISSION = emission_color.rgb * emission_strength * (0.76 + top_light * 0.24);
}
