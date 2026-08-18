shader_type spatial;
render_mode cull_back;

// ONE MORE FLOOR v1.60 — character-only mobile surface shader r5.1.
// Mirrors the established v160 surface-depth lighting with subtle optional
// object-space tonal/roughness breakup for authored character bodies only.
// No textures, screen-space effects or extra passes; GL Compatibility friendly.

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

uniform vec4 detail_color : source_color = vec4(0.25, 0.27, 0.32, 1.0);
uniform float detail_strength : hint_range(0.0, 0.12) = 0.0;
uniform float detail_scale : hint_range(1.0, 20.0) = 7.0;
uniform float roughness_variation : hint_range(0.0, 0.16) = 0.0;
uniform float directional_detail : hint_range(0.0, 1.0) = 0.0;

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

	// r5.1 keeps the richer body-surface signal but deliberately avoids the
	// visible camouflage/blotch read seen in the first r5 gallery. Color breakup
	// is now a tiny signed/tint modulation; roughness carries most of the effect.
	float detail_a = sin(dot(local_position, vec3(1.11, 1.73, 1.29)) * detail_scale);
	float detail_b = sin(dot(local_position, vec3(-1.37, 0.71, 1.91)) * detail_scale * 0.73);
	float micro_signed = detail_a * detail_b;
	float vertical_signed = sin(local_position.y * detail_scale * 1.21 + local_position.x * 0.43);
	float pattern_signed = mix(micro_signed, micro_signed * 0.62 + vertical_signed * 0.38, directional_detail);
	float pattern = clamp(pattern_signed * 0.5 + 0.5, 0.0, 1.0);

	vec3 tint_delta = detail_color.rgb - base_color.rgb;
	shaded += tint_delta * (detail_strength * pattern * 0.42);
	shaded *= 1.0 + pattern_signed * detail_strength * 0.14;

	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float rim = pow(1.0 - facing, 2.30);
	shaded = mix(shaded, edge_color.rgb, clamp(rim * edge_strength, 0.0, 0.65));

	ALBEDO = shaded;
	METALLIC = metallic;
	ROUGHNESS = clamp(roughness + pattern_signed * roughness_variation * 0.50, 0.0, 1.0);
	SPECULAR = specular_level;
	EMISSION = emission_color.rgb * emission_strength * (0.76 + top_light * 0.24);
}
