precision highp float;
varying vec2 vUv;
uniform sampler2D texture;
uniform vec2 px;
uniform float m[9];

void main(void) {
	vec4 p = texture2D(texture, vUv);
	float gray = ((0.3 * p.r) + (0.59 * p.g) + (0.11 * p.b));	// gray значение
	gl_FragColor = vec4(gray, gray, gray, p.a);
}