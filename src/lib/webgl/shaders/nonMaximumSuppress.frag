precision highp float;
varying vec2 vUv;
uniform sampler2D texture;
uniform vec2 px;
uniform float mx[9];
uniform float my[9];

float PI = 3.14159265;
//округляет градусы до 4 возможных ориентаций: горизонтальная, вертикальная и 2 диагональные
float roundDir(float deg) {
	if (deg < 0.) {deg = deg + 180.;}
	if (deg >= 0. && deg <= 22.5) { 	return 0.; }
	if (deg > 157.5 && deg <= 180.) {	return 0.; }
	if (deg > 22.5 && deg <= 67.5) {	return 0.1;	} // 45
	if (deg > 67.5 && deg <= 112.5) { 	return 0.2;	} // 90
	if (deg > 112.5 && deg <= 157.5) { 	return 0.3; } // 135
// 	// if (
// 	// 	(deg >= 0. && deg <= 22.5) ||
// 	// 	(deg > 157.5 && deg <= 180.)
// 	// ) {
// 	// 	return 0.;
// 	// } else if (deg > 22.5 && deg <= 67.5) {
// 	// 	return 45.;
// 	// } else if (deg > 67.5 && deg <= 112.5) {
// 	// 	return 90.;
// 	// } else if (deg > 112.5 && deg <= 157.5) {
// 	// 	return 135.;
// 	// }
}

//   const getPixelNeighbors = function(dir) {
//     var degrees = {
// 		0 : [
// 			{x:1, y:2},
// 			{x:1, y:0}
// 			],
// 		45: [
// 			{x: 0, y: 2},
// 			{x: 2, y: 0}
// 			],
// 		90: [
// 			{x: 0, y: 1},
// 			{x: 2, y: 1}
// 			],
// 		135:[
// 			{x: 0, y: 0},
// 			{x: 2, y: 2}
// 			]
// 		};
//     return degrees[dir];
//   };


void main(void) {
	vec4 c11 = texture2D(texture, vUv - px);							// top left
	vec4 c12 = texture2D(texture, vec2(vUv.x, vUv.y - px.y));			// top center
	vec4 c13 = texture2D(texture, vec2(vUv.x + px.x, vUv.y - px.y));	// top right

	vec4 c21 = texture2D(texture, vec2(vUv.x - px.x, vUv.y) );			// mid left
	vec4 c22 = texture2D(texture, vUv);									// mid center
	vec4 c23 = texture2D(texture, vec2(vUv.x + px.x, vUv.y) );			// mid right

	vec4 c31 = texture2D(texture, vec2(vUv.x - px.x, vUv.y + px.y) );	// bottom left
	vec4 c32 = texture2D(texture, vec2(vUv.x, vUv.y + px.y) );			// bottom center
	vec4 c33 = texture2D(texture, vUv + px );							// bottom right

	float edgeX = 	(c11 * mx[0] + c12 * mx[1] + c13 * mx[2] +
					c21 * mx[3] + c22 * mx[4] + c23 * mx[5] +
					c31 * mx[6] + c32 * mx[7] + c33 * mx[8]).r;

	float edgeY = 	(c11 * my[0] + c12 * my[1] + c13 * my[2] +
					c21 * my[3] + c22 * my[4] + c23 * my[5] +
					c31 * my[6] + c32 * my[7] + c33 * my[8]).r;
// edgeX += imgData.data[neighbors[i][j]] * OPERATORS[op]["x"][i][j];
// edgeY += imgData.data[neighbors[i][j]] * OPERATORS[op]["y"][i][j];

	float dm = roundDir(atan(edgeY, edgeX) * (180./PI));
	float gm = floor(sqrt(edgeX * edgeX + edgeY * edgeY));
// dirMap[current] = Helpers.roundDir(Math.atan2(edgeY, edgeX) * (180/Math.PI));;
// gradMap[current] = Math.round(Math.sqrt(edgeX * edgeX + edgeY * edgeY));

	// gl_FragColor = 
	// 	c11 * mx[0] + c12 * mx[1] + c13 * mx[2] +
	// 	c21 * mx[3] + c22 * mx[4] + c23 * mx[5] +
	// 	c31 * mx[6] + c32 * mx[7] + c33 * mx[8];
	gl_FragColor = c22;
	gl_FragColor.g = dm; // направление
	gl_FragColor.b = gm; // градиент

	// gl_FragColor.a = c22.a;
}


//   Canny.prototype.nonMaximumSuppress = function() {
//     var imgDataCopy = this.canvas.getCurrImgData(),
//         that = this;

//     console.time('NMS Time');
//     this.canvas.runImg(3, function(current, neighbors) {
//       var pixNeighbors = Helpers.getPixelNeighbors(that.canvas.dirMap[current]);

//       //pixel neighbors to compare
//       var pix1 = that.canvas.gradMap[neighbors[pixNeighbors[0].x][pixNeighbors[0].y]];
//       var pix2 = that.canvas.gradMap[neighbors[pixNeighbors[1].x][pixNeighbors[1].y]];

//       if (pix1 > that.canvas.gradMap[current] ||
//           pix2 > that.canvas.gradMap[current] ||
//           (pix2 === that.canvas.gradMap[current] &&
//           pix1 < that.canvas.gradMap[current])) {
//         that.canvas.setPixel(current, 0, imgDataCopy);
//       }
//     });
//     console.timeEnd('NMS Time');

//     return imgDataCopy;
//   };

//отметить сильные и слабые ребра, отбросить остальные как ложные ребра; оставить только слабые ребра, соединенные с сильными ребрами
  //mark strong and weak edges, discard others as false edges; only keep weak edges that are connected to strong edges
//   Canny.prototype.hysteresis = function(){
//     var that = this,
//         imgDataCopy = this.canvas.getCurrImgData(),
//         realEdges = [], //where real edges will be stored with the 1st pass
//         t1 = Helpers.fastOtsu(this.canvas), //high threshold value
//         t2 = t1/2; //low threshold value

//     //first pass
//     console.time('Hysteresis Time');
//     this.canvas.runImg(null, function(current) {
//       if (imgDataCopy.data[current] > t1 && realEdges[current] === undefined) {//accept as a definite edge
//         var group = that._traverseEdge(current, imgDataCopy, t2, []);
//         for(var i = 0; i < group.length; i++){
//           realEdges[group[i]] = true;
//         }
//       }
//     });

//     //second pass
//     this.canvas.runImg(null, function(current) {
//       if (realEdges[current] === undefined) {
//         that.canvas.setPixel(current, 0, imgDataCopy);
//       } else {
//         that.canvas.setPixel(current, 255, imgDataCopy);
//       }
//     });
//     console.timeEnd('Hysteresis Time');

//     return imgDataCopy;
//   };