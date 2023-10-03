
varying vec3 v_EyeDir;

mediump vec2 octahedralProjection(mediump vec3 dir) {
	dir/= dot(vec3(1.0), abs(dir));
	mediump vec2 rev = abs(dir.zx) - vec2(1.0,1.0);
	mediump vec2 neg = vec2(dir.x < 0.0 ? rev.x : -rev.x,
	dir.z < 0.0 ? rev.y : -rev.y);
	mediump vec2 uv = dir.y < 0.0 ? neg : dir.xz;
	return 0.5*uv + vec2(0.5,0.5);
}

void main() {
    gl_FragColor = texture2D(gm_BaseTexture, octahedralProjection(v_EyeDir.xzy));
}
