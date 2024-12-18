import glUtils from './glUtils.js';
import MAIN_VERT from './shaders/main.vert';
import MAIN_FRAG from './shaders/main.frag';
import DETECT_EDGES from './shaders/detectEdges.frag';
import RGB_ZAM from './shaders/rgbzam.frag';
import POVOROT from './shaders/povorot.frag';

import Program from './Program';
import Texture from './Texture';
// import { getMatrix4fv, project } from './Matrix4fv.js';
import earcut from 'earcut';

const _getFlatten = ( rings ) => {
	return Array.isArray(rings[0]) ? rings.map(earcut.flatten) : [{ projected: true, dimensions: 2, holes: [], vertices: rings }];
};

const _getClipTriangles = ( clipPolygon, invMatrix ) => {
	let	_clipFlatten = _getFlatten(clipPolygon);

	var vertices = [];

	for (let i = 0, len = _clipFlatten.length; i < len; i++) {
		let data = _clipFlatten[i],
			len1 = data.vertices.length,
			projected = data.projected,
			size = data.dimensions;

		// if (projected) data._pixelClipPoints = data.vertices;
		// else {
			data._pixelClipPoints = new Array(len1);
			for (let j = 0; j < len1; j += size) {
				// let px = projected ? [data.vertices[j], data.vertices[j + 1]] : project(invMatrix, data.vertices[j], data.vertices[j + 1]);
				let px = project(invMatrix, data.vertices[j], data.vertices[j + 1]);
				data._pixelClipPoints[j] = px[0];
				data._pixelClipPoints[j + 1] = px[1];
			}
		// }
	}
	_clipFlatten.forEach(data => {
		let index = earcut(data.vertices, data.holes, data.dimensions);
		index.forEach(it => {
			let ind = 2 * it;
			vertices.push(data._pixelClipPoints[ind], data._pixelClipPoints[ind + 1]);
		});
	});
	return new Float32Array(vertices);
};

class ImageTransform {
	constructor(opt) {
		// opt.vsSource = vss;
		// opt.fsSource = fss;
		this.gl = glUtils.createGL(opt);
		opt.gl = this.gl;
		// super(opt);
		const { arr=['main'] } = opt;
		// this.clipPolygon = clipPolygon;
		this.texture = new Texture(opt);

		this.start(arr, opt.data);

	}

    start(names, data={}) {
        const {gl} = this;
        // const {delta, points} = data;
		data.width = gl.canvas.width;
		data.height = gl.canvas.height;

		const _this = this;
// debugger
		this.convArr = names.map((name, nm) => {
			const d = FILTERS[name];

			const vs = Program.compileShader(gl, d.vert || FILTERS.main.vert, gl.VERTEX_SHADER);
			const fs = Program.compileShader(gl, d.frag, gl.FRAGMENT_SHADER);
			const p = gl.createProgram();
			
			const _vertexBuffer = gl.createBuffer();
			gl.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
			gl.bufferData(gl.ARRAY_BUFFER, VERTICES, gl.STATIC_DRAW);
			this._vertexBuffer = _vertexBuffer;
			this.vertices = VERTICES;

			// Note sure if this is a good idea; at least it makes texture loading
			// in Ejecta instant.
			gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, true);
			this._attribArrays = [];

			gl.attachShader(p, vs.shader);
			gl.attachShader(p, fs.shader);
			gl.linkProgram(p);

			if( !gl.getProgramParameter(p, gl.LINK_STATUS) ) {
				console.warn(gl.getProgramInfoLog(p));
			}
			gl.useProgram(p);

			let attrs = {};
			[vs, fs].forEach(it => {
				const {source} = it;
				['attribute', 'uniform'].forEach(c => {
					const at = Program.parseShaderSource(gl, source, c, p);
					attrs = {...attrs, ...at};
				});

			});

			d.apply({gl, attrs, data})

			return {name, p, attrs};
		})
		_this.draw();
		return
	}

	draw() {
        const {gl, convArr, texture, delta} = this;
        const {width, height} = texture.bitmap;

		// let source = texture.screenTexture; // 
		// var source = null, 
		// 	target = null,
		// 	flipY = false;
		// debugger

		const lastNm = convArr.length - 1;
		convArr.forEach((c, cbIndex)=>{
			const {name, p, attrs} = c;
			gl.useProgram(p);
			const dc = cbIndex % 2;
			const fboLink = glUtils.getTempFramebuffer({dc, gl, width, height});
			let source = texture.screenTexture;
			let target = fboLink.fbo;
			if (dc) {
				source = fboLink.texture;
			}
			gl.bindTexture(gl.TEXTURE_2D, source);

			if (cbIndex === lastNm) {
				target = null;

			}

			gl.bindFramebuffer(gl.FRAMEBUFFER, target);
			gl.uniform1f(attrs.flipY.location, dc ? -1 : 1 );
			gl.drawArrays(gl.TRIANGLES, 0, 6);		// draw the triangles
			if (target) source = target.texture;
		})
		// return this.texture.getUrl(url);
	}
}

export default ImageTransform;

const FLOATSIZE = Float32Array.BYTES_PER_ELEMENT;
const VERTSIZE = 4 * FLOATSIZE;

var VERTICES = new Float32Array([
	-1, -1, 0, 1,  1, -1, 1, 1,  -1, 1, 0, 0,
	-1, 1, 0, 0,  1, -1, 1, 1,  1, 1, 1, 0
]);

const FILTERS = {
	main: {	// основной
		apply: (opt) => {
			const {gl, attrs} = opt;
			const vertAttrib = attrs['pos'].location;	// Find and set up the uniforms and attributes
			gl.enableVertexAttribArray(vertAttrib);
			gl.vertexAttribPointer(vertAttrib, 2, gl.FLOAT, false, VERTSIZE , 0);
			const uv = attrs['uv'].location;	// Find and set up the uniforms and attributes
			gl.enableVertexAttribArray(uv);
			gl.vertexAttribPointer(uv, 2, gl.FLOAT, false, VERTSIZE, 2 * FLOATSIZE);

			// gl._draw();
		},
		vert: MAIN_VERT,
		frag: MAIN_FRAG,
	},
	detectEdges: {
		apply: (opt) => {
			const {
				gl, attrs,
				data={},
				matrix=[
					0, 1, 0,
					1, -4, 1,
					0, 1, 0
				]
			} = opt || {};
			const {width, height} = data;
			const m = new Float32Array(matrix);
			const pixelSizeX = 1 / width;
			const pixelSizeY = 1 / height;
	
			// var program = _compileShader(_filter.convolution.SHADER);
			gl.uniform1fv(attrs.m.location, m);
			gl.uniform2f(attrs.px.location, pixelSizeX, pixelSizeY);
	
		},
		frag: DETECT_EDGES,
		vert: MAIN_VERT,
	},
	povorot: {
		apply: (opt) => {
			const {
				gl, attrs,
				data={ugol: Math.PI / 4.},
				// matrix=[
				// 	0, 1, 0,
				// 	1, -4, 1,
				// 	0, 1, 0
				// ]
			} = opt || {};
			const ug = data.ugol;
			// debugger
			const cos = Math.cos(ug);
			const sin = Math.sin(ug);
			const matrix=[
				cos,	-sin,	0,
				sin,	cos,	0,
				0, 		0,		1
			];
			console.log('povorot', ug)

			const {width, height} = data;
			const m = new Float32Array(matrix);
			const pixelSizeX = 1 / width;
			const pixelSizeY = 1 / height;
	
			// var program = _compileShader(_filter.convolution.SHADER);
			gl.uniform1fv(attrs.m.location, m);
			gl.uniform2f(attrs.px.location, pixelSizeX, pixelSizeY);
	
		},
		frag: POVOROT,
		vert: MAIN_VERT,
	},
	perestanovka: {
		apply: (opt) => {
			const {
				gl, attrs,
				data={},
			} = opt || {};
			const matrixKind = eval(data.matrixKind) || [0, 1, 2];
			debugger
			console.log('perestanovka', matrixKind)
			let matrix = [
				[0,	0,	0],
				[0,	0,	0],
				[0,	0,	0]
			];
			matrix[0][matrixKind[0]] = 1;
			matrix[1][matrixKind[1]] = 1;
			matrix[2][matrixKind[2]] = 1;

			// let matrix = [
			// 	0,	1,	0, 		// r -> g
			// 	1,	0,	0,		// g -> r
			// 	0,	0,	1 		// b -> b
			// ];
			// if (matrixKind === 1) matrix = [
			// 	1,	0,	0, 		// r -> r
			// 	0,	0,	1,		// g -> b
			// 	0,	1,	0 		// b -> g
			// ];
			// if (matrixKind === 2) matrix = [
			// 	0,	0,	1, 		// r -> b
			// 	0,	1,	0,		// g -> g
			// 	1,	0,	0		// b -> r
			// ];

			const {width, height} = data;
			const m = new Float32Array(matrix);
			const pixelSizeX = 1 / width;
			const pixelSizeY = 1 / height;
	
			// var program = _compileShader(_filter.convolution.SHADER);
			gl.uniform1fv(attrs.m.location, m);
			gl.uniform2f(attrs.px.location, pixelSizeX, pixelSizeY);
	
		},
		frag: POVOROT,
		vert: MAIN_VERT,
	},
	perestanovka1: {
		apply: (opt) => {
			const {
				gl, attrs,
				data={},
			} = opt || {};
			// debugger
			console.log('perestanovka')

			const matrix = [
				0,	1,	0, 		// r -> g
				1,	0,	0,		// g -> r
				0,	0,	1 		// b -> b
			];

			const {width, height} = data;
			const m = new Float32Array(matrix);
			const pixelSizeX = 1 / width;
			const pixelSizeY = 1 / height;
	
			// var program = _compileShader(_filter.convolution.SHADER);
			gl.uniform1fv(attrs.m.location, m);
			gl.uniform2f(attrs.px.location, pixelSizeX, pixelSizeY);
	
		},
		frag: POVOROT,
		vert: MAIN_VERT,
	},

	rgbzam: {	// Filter rgbzam замена цвета на другой
		apply: (opt) => {
			FILTERS.main.apply(opt);
			const {gl, attrs, zam={}} = opt;
			const {r=1, g=1, b=2} = zam;
			gl.uniform1i(attrs.flipY.location, -1);
			gl.uniform1i(attrs.rzam.location, r);
			gl.uniform1i(attrs.gzam.location, g);
			gl.uniform1i(attrs.bzam.location, b);
			// gl._draw();
		},
		vert: MAIN_VERT,
		frag: RGB_ZAM
	},
	oklab_o: {	// Filter oklab https://www.shadertoy.com/view/WlGyDG
		apply: (opt) => {
			FILTERS.main.apply(opt);
			const {gl, attrs, data={}} = opt;
			const {points, delta=0.025} = data;
			let l = 0, c = 0, h = 0;
			if (points && points[0]) {
				const ar = points[0].lch;
				l = ar[0], c = ar[1], h = ar[2];
				// debugger

			}
			gl.uniform1i(attrs.l.location, l);
			gl.uniform1i(attrs.c.location, c);
			gl.uniform1i(attrs.h.location, h);

			        // const {delta, points} = data;

			// const {r=1, g=1, b=1} = zam;
			gl.uniform1i(attrs.delta.location, delta);
			// gl.uniform1i(attrs.rzam.location, r);
			// gl.uniform1i(attrs.gzam.location, g);
			// gl.uniform1i(attrs.bzam.location, b);
			// gl._draw();
		},
		vert: MAIN_VERT,
		frag: `
precision highp float;
	varying vec2 vUv;
	uniform float delta;
	uniform float l;
	uniform float c;
	uniform float h;
	uniform sampler2D texture;

float Linear1(float c){
	return(c<=0.04045)? c/12.92 : pow((c+0.055)/1.055,2.4);
}
vec3 Linear3(vec3 c){
	return vec3(Linear1(c.r), Linear1(c.g), Linear1(c.b));
}
float Srgb1(float c){
	return(c<0.0031308 ? c*12.92 : 1.055*pow(c,0.41666)-0.055);
}
vec3 Srgb3(vec3 c){
	return vec3(Srgb1(c.r), Srgb1(c.g), Srgb1(c.b));
}

vec3 rgb_to_oklab(vec3 c) {
// export const linear_sRGB_to_LMS_M = [
//   [0.4122214694707629, 0.5363325372617349, 0.051445993267502196],
//   [0.2119034958178251, 0.6806995506452345, 0.10739695353694051],
//   [0.08830245919005637, 0.2817188391361215, 0.6299787016738223],
// ];

    float l = 0.4121656120 * c.r + 0.5362752080 * c.g + 0.0514575653 * c.b;
    float m = 0.2118591070 * c.r + 0.6807189584 * c.g + 0.1074065790 * c.b;
    float s = 0.0883097947 * c.r + 0.2818474174 * c.g + 0.6302613616 * c.b;

    float l_ = pow(l, 1./3.);
    float m_ = pow(m, 1./3.);
    float s_ = pow(s, 1./3.);

    vec3 labResult;
    labResult.x = 0.2104542553*l_ + 0.7936177850*m_ - 0.0040720468*s_;
    labResult.y = 1.9779984951*l_ - 2.4285922050*m_ + 0.4505937099*s_;
    labResult.z = 0.0259040371*l_ + 0.7827717662*m_ - 0.8086757660*s_;
    return labResult;
}

vec3 oklab_to_rgb(vec3 c) 
{
    float l_ = c.x + 0.3963377774 * c.y + 0.2158037573 * c.z;
    float m_ = c.x - 0.1055613458 * c.y - 0.0638541728 * c.z;
    float s_ = c.x - 0.0894841775 * c.y - 1.2914855480 * c.z;

    float l = l_*l_*l_;
    float m = m_*m_*m_;
    float s = s_*s_*s_;

    vec3 rgbResult;
    rgbResult.r = + 4.0767245293*l - 3.3072168827*m + 0.2307590544*s;
    rgbResult.g = - 1.2681437731*l + 2.6093323231*m - 0.3411344290*s;
    rgbResult.b = - 0.0041119885*l - 0.7034763098*m + 1.7068625689*s;
    return rgbResult;
}
float modulo(float x) {
    return x - floor(x);
}
void main(void) {
	gl_FragColor = texture2D(texture, vUv);
	vec3 oklab = rgb_to_oklab(gl_FragColor.rgb);
	vec3 lch = vec3(l, c, h);
    gl_FragColor.a = 1.;
    
    float dl = oklab[0] - lch[0];
    float da = oklab[1] - lch[1];
    float db = oklab[2] - lch[2];
    float diff = sqrt(dl * dl + da * da + db * db);
    // float pp = sqrt(diff);
    // float diff = distance(oklab - lch);
    // gl_FragColor = vec4(oklab - lch, 1.);
    if(diff > delta) gl_FragColor = vec4(0.5, 0.5, 0.5, 0.);
}`

	},
	oklab: {	// Filter oklab https://www.shadertoy.com/view/WlGyDG
		apply: (opt) => {
			FILTERS.main.apply(opt);
			const {gl, attrs, data={}} = opt;
			const {points, delta=0.025} = data;
			let l = 0, c = 0, h = 0;
			if (points && points[0]) {
				const ar = points[0].lch;
				l = ar[0], c = ar[1], h = ar[2];
				// debugger

			}
			gl.uniform1i(attrs.d.location, Number(delta));
			gl.uniform1i(attrs.l.location, l);
			gl.uniform1i(attrs.c.location, c);
			gl.uniform1i(attrs.h.location, h);

			        // const {delta, points} = data;

			// const {r=1, g=1, b=1} = zam;
			// gl.uniform1i(attrs.rzam.location, r);
			// gl.uniform1i(attrs.gzam.location, g);
			// gl.uniform1i(attrs.bzam.location, b);
			// gl._draw();
		},
		vert: MAIN_VERT,
		frag: `
precision highp float;
uniform float d;
uniform float l;
uniform float c;
uniform float h;
uniform sampler2D texture;
uniform float u_time;
varying vec2 vUv;

float Linear1(float c){
	return(c<=0.04045)? c/12.92 : pow((c+0.055)/1.055,2.4);
}
vec3 Linear3(vec3 c){
	return vec3(Linear1(c.r), Linear1(c.g), Linear1(c.b));
}
float Srgb1(float c){
	return(c<0.0031308 ? c*12.92 : 1.055*pow(c,0.41666)-0.055);
}
vec3 Srgb3(vec3 c){
	return vec3(Srgb1(c.r), Srgb1(c.g), Srgb1(c.b));
}

vec3 rgb_to_oklab(vec3 c) {
    float l = 0.4122214694707629 * c.r + 0.5363325372617349 * c.g + 0.051445993267502196 * c.b;
    float m = 0.2119034958178251 * c.r + 0.6806995506452345 * c.g + 0.10739695353694051 * c.b;
    float s = 0.08830245919005637 * c.r + 0.2817188391361215 * c.g + 0.6299787016738223 * c.b;

    float l_ = pow(l, 1./3.);
    float m_ = pow(m, 1./3.);
    float s_ = pow(s, 1./3.);

    vec3 labResult;
    labResult.x = 0.210454268309314 * l_ + 0.7936177747023054 * m_ - 0.0040720430116193 * s_;
    labResult.y = 1.9779985324311684 * l_ - 2.42859224204858 * m_ + 0.450593709617411 * s_;
    labResult.z = 0.0259040424655478 * l_ + 0.7827717124575296 * m_ - 0.8086757549230774 * s_;
    return labResult;
}

void main(void) {
	gl_FragColor = texture2D(texture, vUv);
	vec3 oklab = rgb_to_oklab(gl_FragColor.rgb);
	vec3 lch = vec3(l, c, h);
    gl_FragColor.a = 1.;
    
    float dl = oklab[0] - lch[0];
    float da = oklab[1] - lch[1];
    float db = oklab[2] - lch[2];
    float df = step(d, pow(dl * dl + da * da + db * db, 1./3.));
    // float df = step(pow(dl * dl + da * da + db * db, 1./3.), d);
    // gl_FragColor = vec4(vec3(gl_FragColor.rgb), df);
    gl_FragColor = vec4(abs(sin(u_time)), gl_FragColor.g, gl_FragColor.b, df);
}`

	},
};
