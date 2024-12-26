/** 
    Определение функций
**/
#include "./c0.glsl"

float normpdf(in float x, in float sigma) {
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

vec3 pgause(in vec2 fragCoord, in int y) {
       vec3 col = vec3(0.0);
    float Z = 0.0;
    for (int j = 0; j <= kSize; ++j) {
        kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
    }

    for (int j = 0; j < mSize; ++j) {
        Z += kernel[j];
    }

    for (int i = -kSize; i <= kSize; ++i) {
        vec2 xy = vec2(0.0);
        xy[y] = float(i);
        col += kernel[kSize+i] * pow(texture(iChannel0, (fragCoord.xy + xy ) / iResolution.xy).rgb , vec3(GAMMA));
    }

	return pow(col / Z, vec3(1.0 / GAMMA));
}
