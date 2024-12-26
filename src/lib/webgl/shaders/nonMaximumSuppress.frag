precision highp float;
varying vec2 vUv;
uniform sampler2D texture;
uniform vec2 px;

void main(void) {
	vec4 c22 = texture2D(texture, vec2(vUv.x - 1., vUv.y - 1.));									// mid center
	gl_FragColor = c22;

	float pix0 = c22.b;
	float pix1;
	float pix2;
		vec4 c23;
		vec4 c24;

	float nb = c22.g;
	if (nb == 0.) {		// {x:1, y:2},	{x:1, y:0}
		// c23 = texture2D(texture, vec2(vUv.x + 1., vUv.y + 2.) );
		// c24 = texture2D(texture, vec2(vUv.x + 1., vUv.y) );
		c23 = texture2D(texture, vec2(vUv.x, vUv.y + 1.) );
		c24 = texture2D(texture, vec2(vUv.x, vUv.y - 1.) );
		pix1 = c23.b;
		pix2 = c24.b;
	}
	if (nb == 0.1) {	// {x: 0, y: 2}, {x: 2, y: 0}
		c23 = texture2D(texture, vec2(vUv.x - 1., vUv.y + 1.) );
		c24 = texture2D(texture, vec2(vUv.x + 1., vUv.y - 1.) );
		pix1 = c23.b;
		pix2 = c24.b;
	}
	if (nb == 0.2) {	// {x: 0, y: 1}, {x: 2, y: 1}
		c23 = texture2D(texture, vec2(vUv.x - 1., vUv.y) );
		c24 = texture2D(texture, vec2(vUv.x + 1., vUv.y ) );
		pix1 = c23.b;
		pix2 = c24.b;
	}
	if (nb == 0.3) {	//{x: 0, y: 0}, {x: 2, y: 2}
		c23 = texture2D(texture, vec2(vUv.x - 1., vUv.y - 1.) );
		c24 = texture2D(texture, vec2(vUv.x + 1., vUv.y + 1.) );
		pix1 = c23.b;
		pix2 = c24.b;

	}
	if (
		pix1 > pix0 ||
		pix2 > pix0 ||
		(pix2 == pix0 && pix1 < pix0)
	) {
		gl_FragColor = vec4(0., c22.g, c22.b, c22.a);
	}

}
