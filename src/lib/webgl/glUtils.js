// import Texture from './Texture.js';
// import earcut from 'earcut';
// import { getMatrix4fv, project } from './Matrix4fv.js';
// import ImageTransform from './ImageTransform';
// import Program from './Program';
// import ColorMatrix from './ColorMatrix';
// import Convolution from './Convolution';
// // import Contrast from './Contrast';
// // import Saturation from './Saturation';
// import RgbChange from './RgbChange';
// import Rgb from './Rgb';

// import ImageFilter from './ImageFilter.js'
// import PolylineRender from './gmx/PolygonsRender.js'
// import PolygonsRender from './gmx/PolygonsRender.js'
// import './viewer.css';
// console.log('gmxWebGL', PolylineRender, gmxWebGL);
// let tileRender = new PolylineRender();

const glOpts = { antialias: true, depth: false, preserveDrawingBuffer: true };
// const glOpts = { antialias: true, depth: false, preserveDrawingBuffer: true };
// const qualityOptions = { anisotropicFiltering: true, mipMapping: true, linearFiltering: true };
let	_anisoExt = null, srcPoints, matrix, glResources, gl;
const _tempFramebuffers = {}, _shaderProgramCache = {}, _drawCount = 0;
const glUtils = {
	programsAttr: {
	},
	createGL: (pars) => {
		const {canvas, bitmap, programs=[]} = pars;
		
		const {width, height} = bitmap;
		canvas.width = width; canvas.height = height;
		// return new Promise(resolve => {
		gl =
			// canvas.getContext('webgl2', glOpts) ||

			canvas.getContext('webgl', glOpts) ||
			canvas.getContext('experimental-webgl', glOpts);
		const out = {gl};
		if(gl) {
			_anisoExt =
				gl.getExtension('EXT_texture_filter_anisotropic') ||
				gl.getExtension('MOZ_EXT_texture_filter_anisotropic') ||
				gl.getExtension('WEBKIT_EXT_texture_filter_anisotropic');

			if(!_anisoExt) {
				console.error('Your browser doesn`t support anisotropic filtering.  Ordinary MIP mapping will be used.');
			}

			gl.viewport(0, 0, canvas.width, canvas.height);
			const screenSize = {
				width: canvas.width, height: canvas.height
			};
			let progs = [];
// 				programs.forEach(info => {
// 					let key = info.key.toLowerCase(),
// 						// out = glUtils.programsAttr[key] || {},
// 						p;
// console.warn('____', info);
// 					switch (key) {
// 						case 'rgb':
// 							p = new Rgb({...info, gl});
// 							break;
// 						case 'rgbchange':
// 							p = new RgbChange({...info, gl});
// 							break;
// 						case 'hue':
// 							p = new ColorMatrix({...info, type: 'hue', gl});
// 							break;
// 						case 'saturation':
// 							p = new ColorMatrix({...info, type: 'saturation', gl});
// 							break;
// 						case 'negative':
// 							p = new ColorMatrix({...info, type: 'negative', gl});
// 							break;
// 						case 'desaturate':
// 							p = new ColorMatrix({...info, type: 'desaturate', gl});
// 							break;
// 						case 'desaturateluminance':
// 							p = new ColorMatrix({...info, type: 'desaturateluminance', gl});
// 							break;
// 						case 'sepia':
// 							p = new ColorMatrix({...info, type: 'sepia', gl});
// 							break;
// 						case 'brownie':
// 							p = new ColorMatrix({...info, type: 'brownie', gl});
// 							break;
// 						case 'vintagepinhole':
// 							p = new ColorMatrix({...info, type: 'vintagepinhole', gl});
// 							break;
// 						case 'kodachrome':
// 							p = new ColorMatrix({...info, type: 'kodachrome', gl});
// 							break;
// 						case 'technicolor':
// 							p = new ColorMatrix({...info, type: 'technicolor', gl});
// 							break;
// 						case 'polaroid':
// 							p = new ColorMatrix({...info, type: 'polaroid', gl});
// 							break;
// 						case 'shifttobgr':
// 							p = new ColorMatrix({...info, type: 'shifttobgr', gl});
// 							break;
// 						case 'contrast':
// 							p = new ColorMatrix({...info, type: 'contrast', gl});
// 							break;
// 						case 'brightness':
// 							p = new ColorMatrix({...info, type: 'brightness', gl});
// 							// p = new Brightness({...info, gl});
// 							// progs.push(p);
// 							break;

// 						case 'detectedges':
// 							p = new Convolution({...info, gl});
// 							break;
// 						case 'sobelx':
// 							p = new Convolution({...info, gl});
// 							break;
// 						case 'sobely':
// 							p = new Convolution({...info, gl});
// 							break;
// 						case 'sharpen':
// 							p = new Convolution({...info, gl});
// 							break;
// 						case 'emboss':
// 							p = new Convolution({...info, gl});
// 							break;

// 						case 'imagetransform':
// 							p = new ImageTransform({...info, gl, resolve});
// 							if (info.url) {
// 								p.getUrl().then(pt => {
// 									gl._nsgx.bitmap = p.texture.bitmap;
// 									gl._nsgx.screenTexture = p.texture.screenTexture;
// 									const { width, height } = p.texture.bitmap;
// 									// canvas.width = width, canvas.height = height;
// 	// gl.viewport(0, 0, width, height);

// 									resolve({ready:true});
// 								});
// 							}
// 							break;
// 						default:
// 							break;
// 					}
// 					progs.push(p);
// 				});
			gl._nsgx = {screenSize, canvas, progs};
		} else {
			console.error('Your browser doesn`t seem to support WebGL.');
		}
		return gl;
		// });
	},
	
	// compileShader: ( opt ) => {
	// 	const {gl, flags, cbIndex, fragmentSource} = opt;
	// 	let _currentProgram;
	// 	if (_shaderProgramCache[fragmentSource]) {
	// 		_currentProgram = _shaderProgramCache[fragmentSource];
	// 		gl.useProgram(_currentProgram.id);
	// 		return _currentProgram;
	// 	}

	// 	// Compile shaders
	// 	_currentProgram = new WebGLProgram( gl, SHADER.VERTEX_IDENTITY, fragmentSource );

	// 	var floatSize = Float32Array.BYTES_PER_ELEMENT;
	// 	var vertSize = 4 * floatSize;
	// 	gl.enableVertexAttribArray(_currentProgram.attribute.pos);
	// 	gl.vertexAttribPointer(_currentProgram.attribute.pos, 2, gl.FLOAT, false, vertSize , 0 * floatSize);
	// 	gl.enableVertexAttribArray(_currentProgram.attribute.uv);
	// 	gl.vertexAttribPointer(_currentProgram.attribute.uv, 2, gl.FLOAT, false, vertSize, 2 * floatSize);

	// 	_shaderProgramCache[fragmentSource] = _currentProgram;
	// 	return _currentProgram;
	// },

	// draw: function(opt) {
	// 	const {gl, flags, cbIndex, sourceTexture} = opt;
	// 	let source = null, target = null, flipY = false;

	// 	// Set up the source
	// 	if( _drawCount == 0 ) {
	// 		source = sourceTexture; // First draw call - use the source texture
	// 	} else {
	// 		source =  glUtils.getTempFramebuffer(opt).texture; // All following draw calls use the temp buffer last drawn to
	// 	}
	// 	_drawCount++;


	// 	// Set up the target
	// 	if( _lastInChain && !(flags & DRAW.INTERMEDIATE) ) {
	// 		// Last filter in our chain - draw directly to the WebGL Canvas. We may
	// 		// also have to flip the image vertically now
	// 		target = null;
	// 		flipY = _drawCount % 2 == 0;
	// 	}
	// 	else {
	// 		// Intermediate draw call - get a temp buffer to draw to
	// 		cbIndex = (cbIndex + 1) % 2;
	// 		target = glUtils.getTempFramebuffer({...opt, cbIndex}).fbo;
	// 	}

	// 	// Bind the source and target and draw the two triangles
	// 	gl.bindTexture(gl.TEXTURE_2D, source);
	// 	gl.bindFramebuffer(gl.FRAMEBUFFER, target);

	// 	gl.uniform1f(_currentProgram.uniform.flipY, (flipY ? -1 : 1) );
	// 	gl.drawArrays(gl.TRIANGLES, 0, 6);
	// },

	getTempFramebuffer: (opt) => {
		const {cbIndex, gl, width, height} = opt;
		_tempFramebuffers[cbIndex] = 
			_tempFramebuffers[cbIndex] || 
			glUtils.createFramebufferTexture(opt);

		return _tempFramebuffers[cbIndex];
	},

	createFramebufferTexture: (opt) => {
		const {gl, width, height} = opt;
		const fbo = gl.createFramebuffer();
		gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);

		const renderbuffer = gl.createRenderbuffer();
		gl.bindRenderbuffer(gl.RENDERBUFFER, renderbuffer);

		const texture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);

		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

		gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);

		gl.bindTexture(gl.TEXTURE_2D, null);
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);

		return {fbo, texture};
	},

	filters: {
		rgbzam: {	// Filter rgbzam замена цвета на другой
			apply: function(hand, zam = {r: 0, g: 1, b: 2}) {
				let p = hand.comp(glUtils.filters.rgbzam.frag);
				gl.uniform1i(p.uniform.rzam, zam.r);
				gl.uniform1i(p.uniform.gzam, zam.g);
				gl.uniform1i(p.uniform.bzam, zam.b);
				hand._draw();
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
	},

    setParams: function (pars) {
		const { anchors, clipPolygon, cmd, filters } = pars;
		if (cmd === 'ImageFilters') {
			const prev = glUtils.programsAttr[cmd] || {};
			const changed = prev.changed || {};
			Object.entries(filters).forEach(([k, v]) => {
				if (v !== prev[k]) changed[k] = true;
			});
			glUtils.programsAttr[cmd] = {filters, changed};
			if (Object.keys(changed).length) glUtils.redrawGl({});
		}
console.log(' ___ setParams ____', pars, glUtils.programsAttr);
	},

    redrawGl: function (pars) {
		let { anchors, clipPolygon } = pars;
		if (!gl) return;
		const progs = gl._nsgx.progs;
		const bitmap = gl._nsgx.bitmap;
		const screenTexture = gl._nsgx.screenTexture;

		gl.clearColor(0, 0, 0, 0);
		gl.viewport(0, 0, bitmap.width, bitmap.height);
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
		let source = {texture: screenTexture}, target, vertices, params = glUtils.programsAttr;
		const parr = progs.filter(p => {
			if ((p.type === 'desaturate' && !params.ImageFilters.filters.desaturate) ||
				(p.type === 'negative' && !params.ImageFilters.filters.negative) ||
				(p.type === 'desaturateLuminance' && !params.ImageFilters.filters.desaturateLuminance) ||
				(p.type === 'sepia' && !params.ImageFilters.filters.sepia) ||
				(p.type === 'brownie' && !params.ImageFilters.filters.brownie) ||
				(p.type === 'vintagePinhole' && !params.ImageFilters.filters.vintagePinhole) ||
				(p.type === 'kodachrome' && !params.ImageFilters.filters.kodachrome) ||
				(p.type === 'technicolor' && !params.ImageFilters.filters.technicolor) ||
				(p.type === 'polaroid' && !params.ImageFilters.filters.polaroid) ||
				(p.type === 'shiftToBGR' && !params.ImageFilters.filters.shiftToBGR) ||

				(p.type === 'detectedges' && !params.ImageFilters.filters.detectedges) ||
				(p.type === 'sobelx' && !params.ImageFilters.filters.sobelx) ||
				(p.type === 'sobely' && !params.ImageFilters.filters.sobely)
				) return false;
			return true;
		});
		const lnum = parr.length - 1;
		for (let i = 0; i < lnum; i++) {
			const p = parr[i];
			let nm = i % 2;
			let flipY = i % 2 == 1;
			target = Program.getTempFramebuffer(gl, bitmap, nm);

			p.apply({...pars, bitmap, source, target, params});

			source = target;
		}
		gl.bindTexture(gl.TEXTURE_2D, source.texture);
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);
		gl.viewport(0, 0, gl._nsgx.screenSize.width, gl._nsgx.screenSize.height);
		parr[lnum].apply({...pars, source, vertices, bitmap});	// imagetransform
    },
};
export default glUtils;

