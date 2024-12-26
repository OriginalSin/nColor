precision highp float;

vec4 blur(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
  vec4 color = vec4(0.);
  vec2 off1 = vec2(1.3333333333333333) * direction;
  color += texture2D(image, uv) * 0.29411764705882354;
  color += texture2D(image, uv + (off1 / resolution)) * 0.35294117647058826;
  color += texture2D(image, uv - (off1 / resolution)) * 0.35294117647058826;
  return color; 
}

const mat3 X_COMPONENT_MATRIX = mat3(
  1., 0., -1.,
  2., 0., -2.,
  1., 0., -1.
);
const mat3 Y_COMPONENT_MATRIX = mat3(
  1., 2., 1.,
  0., 0., 0.,
  -1., -2., -1.
);

float convoluteMatrices(mat3 A, mat3 B) {
  return dot(A[0], B[0]) + dot(A[1], B[1]) + dot(A[2], B[2]);
}

/**
 * Get the color of a texture after
 * a Guassian blur with a radius of 5 pixels
 */
vec3 getBlurredTextureColor(
  sampler2D textureSampler,
  vec2 textureCoord,
  vec2 resolution
) {
  return blur(
    textureSampler,
    textureCoord,
    resolution,
    normalize(textureCoord - vec2(0.5))).xyz;
}

/**
 * Get the intensity of the color on a
 * texture after a guassian blur is applied
 */
float getTextureIntensity(
  sampler2D textureSampler,
  vec2 textureCoord,
  vec2 resolution
) {
  vec3 color = getBlurredTextureColor(textureSampler, textureCoord, resolution);
  return pow(length(clamp(color, vec3(0.), vec3(1.))), 2.) / 3.;
}

/**
 * Get the gradient of the textures intensity
 * as a function of the texture coordinate
 */
vec2 gradient(
  sampler2D textureSampler,
  vec2 textureCoord,
  vec2 resolution
) {
  vec2 gradientStep = vec2(1.) / resolution;

  mat3 imgMat = mat3(0.);

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      vec2 ds = vec2(
        -gradientStep.x + (float(i) * gradientStep.x),
        -gradientStep.y + (float(j) * gradientStep.y));
      imgMat[i][j] = getTextureIntensity(
        textureSampler, clamp(textureCoord + ds, vec2(0.), vec2(1.)), resolution);
    }
  }

  float gradX = convoluteMatrices(X_COMPONENT_MATRIX, imgMat);
  float gradY = convoluteMatrices(Y_COMPONENT_MATRIX, imgMat);

  return vec2(gradX, gradY);
}

uniform sampler2D texture;
uniform vec2 px;
varying vec2 vUv;


void main() {
  // returns 1. if it is an edge, 0. otherwise
  vec2 grad = gradient(texture, vUv, px);
  gl_FragColor = vec4(length(grad), 0., 0., 1.);
}
