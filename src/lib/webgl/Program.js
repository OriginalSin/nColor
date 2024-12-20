// import { getMatrix4fv, project } from './Matrix4fv.js';

const attributes = {
	pos: 'pos', 							// полигон обрезки ()
	uv: 'uv', 							// полигон обрезки ()
};
const uniforms = {
	// flipY: 'flipY',	// матрица трансформации ()
	texture: 'texture', 					// uSampler ()
};
const vertices = new Float32Array([
	-1, -1, 0, 1,  1, -1, 1, 1,  -1, 1, 0, 0,
	-1, 1, 0, 0,  1, -1, 1, 1,  1, 1, 1, 0
]);
const floatSize = Float32Array.BYTES_PER_ELEMENT;
const vertSize = 4 * floatSize;

const vss = `
	precision highp float;
	attribute vec2 pos;
	attribute vec2 uv;
	varying vec2 vUv;

	void main(void) {
		vUv = uv;
		gl_Position = vec4(pos.x, -pos.y, 0.0, 1.);
	}
`;
const fss = `
	precision highp float;
	varying vec2 vUv;
	uniform sampler2D texture;

	void main(void) {
		gl_FragColor = texture2D(texture, vUv);
	}
`;

const _tempFramebuffers = [null, null];
  // create 2 textures and attach them to framebuffers.

// let _currentFramebufferIndex = -1;
const _getTempFramebuffer = (gl, bitmap, index) => {
	_tempFramebuffers[index] = _tempFramebuffers[index] ||  _createFramebufferTexture(gl, bitmap);
	return _tempFramebuffers[index];
};

const _createFramebufferTexture = (gl, bitmap) => {
	let fbo = gl.createFramebuffer();
	gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);

	let renderbuffer = gl.createRenderbuffer();
	gl.bindRenderbuffer(gl.RENDERBUFFER, renderbuffer);

	let texture = gl.createTexture();
	gl.bindTexture(gl.TEXTURE_2D, texture);
	// gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.canvas.width, gl.canvas.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
	gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, bitmap.width, bitmap.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);

	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

	gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);

	gl.bindTexture(gl.TEXTURE_2D, null);
	gl.bindFramebuffer(gl.FRAMEBUFFER, null);

	return {fbo, texture};
};

class Program {
	static getTempFramebuffer( gl, bitmap, index ) {
		return _getTempFramebuffer( gl, bitmap, index );
	}
	static compileShader( gl, source, type ) {
		const shader = gl.createShader(type);
		gl.shaderSource(shader, source);
		gl.compileShader(shader);

		if( !gl.getShaderParameter(shader, gl.COMPILE_STATUS) ) {
			console.error(gl.getShaderInfoLog(shader));
			return null;
		}
		return {shader, source};
	}
	static parseShaderSource( gl, source, prefix, id ) {
		const r = new RegExp('\\b' + prefix + ' (\\w+) (\\w+)', 'ig');
		return [...source.matchAll(r)].reduce((a, c) => {
			const [st, type, name] = c;
			const location = prefix === 'uniform' ? gl.getUniformLocation(id, name) : gl.getAttribLocation(id, name);
			if (location === -1) console.error(`Параметр "${name}" не используется`);
			a[name] = { location, type };
			return a;
		}, {});
	}
	static createAndSetupTexture( gl ) {
		const texture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, texture);

		// Set up texture so we can render any size image and so we are
		// working with pixels.
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
		return texture;
	}

	constructor(opt) {
		const { vsSource=vss, fsSource=fss, gl, anchors, clipPolygon, type='' , m } = opt;
		this.gl = gl;
		this.vsSource = vsSource;
		this.fsSource = fsSource;
		this.type = type;
		this.m = m;
        this.vertexBuffer = gl.createBuffer();		// Create a buffer to hold the vertices
		this.init();


	}

    init() {
        const gl = this.gl;
		// debugger
		const vs = Program.compileShader(gl, this.vsSource, gl.VERTEX_SHADER);
		const fs = Program.compileShader(gl, this.fsSource, gl.FRAGMENT_SHADER);
		const id = gl.createProgram();
		this.id = id;
		this.vs = vs;
		this.fs = fs;
// console.error('____', this.type, vs, fs);
		gl.attachShader(id, vs.shader);
		gl.attachShader(id, fs.shader);
		gl.linkProgram(id);

		if( !gl.getProgramParameter(id, gl.LINK_STATUS) ) {
			console.error(gl.getProgramInfoLog(id));
		}
		gl.useProgram(id);
		
		const pt = {attribute: {}, uniform: {}};
		// const attribute = {}, uniform = {};
		[vs, fs].forEach(it => {
			const {source} = it;
			// const pt = ['attribute', 'uniform'].reduce((a, c) => {
			['attribute', 'uniform'].forEach(c => {
				const h = Program.parseShaderSource(gl, source, c, id);
				pt[c] = {...pt[c], ...h};
				// pt[c] = attr;
				// return a;
			});
			// it.attribute = pt.attribute;
			// it.uniform = pt.uniform;
		});
		this.attribute = pt.attribute || {};
		this.uniform = pt.uniform || {};
	}

    // init() {
        // const gl = this.gl;

		// const vs = Program.compileShader(gl, this.vsSource, gl.VERTEX_SHADER);
		// const fs = Program.compileShader(gl, this.fsSource, gl.FRAGMENT_SHADER);
		// const id = gl.createProgram();
		// this.id = id;
		// this.vs = vs;
		// this.fs = fs;
	// }

    bindBuffer(bitmap) {
        const { width, height } = bitmap;
        const gl = this.gl;
		gl.viewport(0, 0, width, height);		 // Tell webgl the viewport setting needed for framebuffer.
		gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);
			// Note sure if this is a good idea; at least it makes texture loading
			// in Ejecta instant.
		// gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, true);
// console.log(' __ bindBuffer ____', vertices);
		this.enableAttribArrays();
    }

    enableAttribArrays() {
        let gl = this.gl;
		const vertAttrib = this.attribute['pos'].location;	// Find and set up the uniforms and attributes
		gl.enableVertexAttribArray(vertAttrib);
		gl.vertexAttribPointer(vertAttrib, 2, gl.FLOAT, false, vertSize , 0);
		const uv = this.attribute['uv'].location;	// Find and set up the uniforms and attributes
		gl.enableVertexAttribArray(uv);
		gl.vertexAttribPointer(uv, 2, gl.FLOAT, false, vertSize, 2 * floatSize);
    }
    bindTexture() {
        // let gl = this.gl;
		// gl.activeTexture(gl.TEXTURE0);
// console.log(' __ bindTexture ____', this.texture.screenTexture);
		// gl.bindTexture(gl.TEXTURE_2D, this.texture.screenTexture);
		// const samplerUniform = this.fs.uniform['texture'].location;
		// gl.uniform1i(samplerUniform, 0);
    }

    apply() {
        let gl = this.gl;
		// gl.useProgram(this.id);
console.log(' __apply____', this);


    }

}

export default Program;

const filters = {
	main: {	// основной
		apply: (opt) => {
			const {gl, hand, zam = {r: 0, g: 1, b: 2}} = opt;
			let p = Program.compileShader(filters.main.frag);
			gl.uniform1i(p.uniform.rzam, zam.r || 0);
			gl.uniform1i(p.uniform.gzam, zam.g || 1);
			gl.uniform1i(p.uniform.bzam, zam.b || 2);
			gl._draw();
		},
		vert: `
	precision highp float;
	attribute vec2 pos;
	attribute vec2 uv;
	varying vec2 vUv;

	void main(void) {
		vUv = uv;
		gl_Position = vec4(pos.x, -pos.y, 0.0, 1.);
	}`,
		frag: `
	precision highp float;
	varying vec2 vUv;
	uniform sampler2D texture;

	void main(void) {
		gl_FragColor = texture2D(texture, vUv);
	}`,
	},
	rgbzam: {	// Filter rgbzam замена цвета на другой
		apply: (opt) => {
			const {gl, hand, zam = {r: 0, g: 1, b: 2}} = opt;
			let p = Program.compileShader(filters.rgbzam.frag);
			gl.uniform1i(p.uniform.rzam, zam.r || 0);
			gl.uniform1i(p.uniform.gzam, zam.g || 1);
			gl.uniform1i(p.uniform.bzam, zam.b || 2);
			gl._draw();
		},
		frag: `
precision highp float;
varying vec2 vUv;
uniform int rzam;
uniform int gzam;
uniform int bzam;
uniform sampler2D texture;

float getcol(vec4 c, int i) {
if (i == 0) return c[0];
else if (i == 1) return c[1];
return c[2];
}

void main(void) {
gl_FragColor = texture2D(texture, vUv);
float r = getcol(gl_FragColor, rzam);
float g = getcol(gl_FragColor, gzam);
float b = getcol(gl_FragColor, bzam);
gl_FragColor.r = r;
gl_FragColor.g = g;
gl_FragColor.b = b;
}`
	},
};
