
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float blur_strength : hint_range(0.0, 5.0) = 1.5;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.65;
uniform float vignette_radius : hint_range(0.1, 1.0) = 0.48;
uniform float darkness : hint_range(0.0, 1.0) = 0.18;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 pixel = SCREEN_PIXEL_SIZE * blur_strength;

    // Мягкое размытие
    vec3 color = textureLod(screen_texture, uv, 0.0).rgb * 0.28;

    color += textureLod(screen_texture, uv + vec2(pixel.x, 0.0), 0.0).rgb * 0.12;
    color += textureLod(screen_texture, uv - vec2(pixel.x, 0.0), 0.0).rgb * 0.12;

    color += textureLod(screen_texture, uv + vec2(0.0, pixel.y), 0.0).rgb * 0.12;
    color += textureLod(screen_texture, uv - vec2(0.0, pixel.y), 0.0).rgb * 0.12;

    color += textureLod(screen_texture, uv + pixel, 0.0).rgb * 0.06;
    color += textureLod(screen_texture, uv - pixel, 0.0).rgb * 0.06;

    color += textureLod(screen_texture, uv + vec2(pixel.x, -pixel.y), 0.0).rgb * 0.06;
    color += textureLod(screen_texture, uv + vec2(-pixel.x, pixel.y), 0.0).rgb * 0.06;

    // Затемнение по краям
   vec2 centered_uv = vec2(
    (uv.x - 0.5) * SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x,
    uv.y - 0.5
);

    float distance_from_center = length(centered_uv);

    float vignette = smoothstep(
        vignette_radius * 0.65,
        vignette_radius,
        distance_from_center
    );

    color *= 1.0 - vignette * vignette_strength;
    color *= 1.0 - darkness;

    COLOR = vec4(color, 1.0);
}
