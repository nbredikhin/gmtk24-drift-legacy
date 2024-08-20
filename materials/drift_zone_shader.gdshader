shader_type canvas_item;
render_mode blend_add;

uniform sampler2D noise: hint_default_white;

void fragment() {
    vec2 uv = UV;
    
	vec4 n = texture(noise, uv);
    uv.x += TIME * 0.05 + n.x * 0.3;
    uv.x *= 5.0;

    float arrowPattern = abs(fract(uv.x) - 0.5);
	float a = pow(0.5 - abs(uv.y - 0.5), 0.8) * 0.4;

    if (arrowPattern < 0.25) {
        COLOR = vec4(1.0, 1.0, 0.0, a);
    } else {
        COLOR = vec4(1.0, 0.5, 0.0, a);
    }
}
