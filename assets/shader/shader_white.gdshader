shader_type canvas_item;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	// 强制 RGB 为白色，保留原始 Alpha
	COLOR = vec4(1.0, 1.0, 1.0, tex.a);
}
