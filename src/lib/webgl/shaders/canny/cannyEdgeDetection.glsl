precision mediump float;

#include intensity-gradient.glsl;
#include canny-edge-detection.glsl;

// #pragma glslify: gradient = require('../lib/intensity-gradient.glsl');
// #pragma glslify: cannyEdgeDetection = require('../lib/canny-edge-detection');

uniform sampler2D texture;

void main() {
  vec2 grad = gradient(texture, vec2(0.), vec2(512., 512.));
  float edge = cannyEdgeDetection(
    texture, vec2(0.), vec2(512., 512.), .15, .3);
}