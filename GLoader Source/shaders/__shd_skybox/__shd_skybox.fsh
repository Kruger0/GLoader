
varying vec3	v_view_dir;

mediump vec2 octahedralProjection(mediump vec3 dir) {
	dir = vec3(dir.x, -dir.y, dir.z);	// Flip the projection if the octmap has ground or sky on center
	dir/= dot(vec3(1.0), abs(dir));
	mediump vec2 rev = abs(dir.zx) - vec2(1.0,1.0);
	mediump vec2 neg = vec2(dir.x < 0.0 ? rev.x : -rev.x,
	dir.z < 0.0 ? rev.y : -rev.y);
	mediump vec2 uv = dir.y < 0.0 ? neg : dir.xz;
	return 0.5*uv + vec2(0.5,0.5);
}

void main() {
	vec3 sky_color = texture2D(gm_BaseTexture, octahedralProjection(v_view_dir.xzy)).rgb;
	//sky_color = pow(sky_color, vec3(1.0/2.2));
    gl_FragColor = vec4(sky_color, 1.0);
}
