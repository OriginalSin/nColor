precision highp float;
varying vec2 vUv;
uniform sampler2D texture;
uniform vec2 px;
uniform float m[9];

void main(void) {
	vec4 c22 = texture2D(texture, vUv);

	gl_FragColor.r = c22.r * m[0] + c22.g * m[1] + c22.b * m[2];
	gl_FragColor.g = c22.r * m[3] + c22.g * m[4] + c22.b * m[5];
	gl_FragColor.b = c22.r * m[6] + c22.g * m[7] + c22.b * m[8];

	// gl_FragColor.r = clamp(c22.r * m[0] + c22.g * m[1] + c22.b * m[2], 0., 1.);
	// gl_FragColor.g = clamp(c22.r * m[3] + c22.g * m[4] + c22.b * m[5], 0., 1.);
	// gl_FragColor.b = clamp(c22.r * m[6] + c22.g * m[7] + c22.b * m[8], 0., 1.);

	gl_FragColor.a = c22.a;
}