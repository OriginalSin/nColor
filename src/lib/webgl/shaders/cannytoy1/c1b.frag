/** 
 * Canny Edge Detection by Ruofei Du (DuRuofei.com)
 * Step 1B: Apply (Vertical) Gaussian filter to smooth the image in order to remove the noise
 *          Meanwhile, convert the smoothed image to gray scale
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
#iChannel0 "file://./c1a.frag"

#include "./c1.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec3 col = pgause(fragCoord, 1);

    float gray = dot(col, vec3(0.2126, 0.7152, 0.0722));
    fragColor = vec4(vec3(gray), 1.0);
}