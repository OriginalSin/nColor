/** 
 * Canny Edge Detection by Ruofei Du (DuRuofei.com)
 * Step 2: Find the intensity gradients of the image
 * Link to demo: https://www.shadertoy.com/view/Xly3DV
 * starea @ ShaderToy, License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
 *
 * Reference: 
 * [1] Canny, J., A Computational Approach To Edge Detection, IEEE Trans. Pattern Analysis and Machine Intelligence, 8(6):679–698, 1986.
 * [2] Canny edge detector, Wikipedia. https://en.wikipedia.org/wiki/Canny_edge_detector
 *
 * Related & Better Implementation:
 * [1] stduhpf's Canny filter (3pass): https://www.shadertoy.com/view/MsyXzt
 **/
#iChannel0 "file://./c1b.frag"
#include "./c1.glsl"

#define A(X,Y) (tap(iChannel0,vec2(X,Y)))
vec3 tap(sampler2D tex,vec2 xy) { return texture(tex,xy).xyz; }

#define FLT_MAX 3.402823466e+38
#define FLT_MIN 1.175494351e-38

float epsx = 0.02;
float epsy = 0.02;
int count = 8;
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    float minDx = FLT_MIN;
    float maxDx = FLT_MAX;
    float minDy = FLT_MIN;
    float maxDy = FLT_MAX;

    vec2 uv = fragCoord.xy / iResolution.xy;
    float pr = texture(iChannel0, uv).r;
    float dX = dFdx(pr);
    float dY = dFdy(pr);
    float magnitude = length(vec2(dX, dY)); 
    vec4 nul = vec4(vec3(0.0), 1.0);

    for (int i = -count; i <= count; ++i) {
        for (int j = -count; j <= count; ++j) {
            if (i == 0 && j == 0) continue;
            uv = (fragCoord.xy + vec2(i , j)) / iResolution.xy;
            pr = texture(iChannel0, uv).r;
            float dX1 = dFdx(pr);
            float dY1 = dFdy(pr);
            minDx = max(minDx, dX1);
            maxDx = min(maxDx, dX1);
 
            minDy = max(minDy, dY1);
            maxDy = min(maxDy, dY1);
            // clamp(dY, minDy - 0.01, maxDy + 0.01);


        }
    }
    if (dX < (minDx - epsx) || dX > (maxDx + epsx)) {
        fragColor = nul;
        return;
    }
    if (dY < (minDy - epsy) || dY > (maxDy + epsy)) {
        fragColor = nul;
        return;
    }



	// vec2 uv1x = (fragCoord.xy + vec2(1. , 0.)) / iResolution.xy;
    // float p1r = texture(iChannel0, uv1x).r;
    // float dX1 = dFdx(p1r);
    // float dY1 = dFdy(p1r);

    vec3 col = vec3(dX / magnitude, dY / magnitude, magnitude); 
    // vec3 col = vec3(dX / magnitude,dY / magnitude, 0.0); 
    if (magnitude < level) col = vec3(0.0);
	fragColor = vec4(col, 1.0);
}