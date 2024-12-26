/** 
 * Canny Edge Detection by Ruofei Du (DuRuofei.com)
 * Step 1A: Apply (Horizontal) Gaussian filter to smooth the image in order to remove the noise
 * Link to demo: https://www.shadertoy.com/view/Xly3DV
 * starea @ ShaderToy, License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
 *
 * Reference: 
 * [1] Canny, J., A Computational Approach To Edge Detection, IEEE Trans. Pattern Analysis and Machine Intelligence, 8(6):679–698, 1986.
 * [2] Canny edge detector, Wikipedia. https://en.wikipedia.org/wiki/Canny_edge_detector
 *
 * Related & Better Implementation:
 * [1] https://www.shadertoy.com/view/4ssXDS
 * [2] stduhpf's Canny filter (3pass): https://www.shadertoy.com/view/MsyXzt
http://duruofei.com/Public/course/CMSC733/Du_Ruofei_PS1.pdf
 * 
 **/
//#iChannel0 "file://../../../../assets/c.jpg"
//#iChannel0 "file://../../../../assets/svetof.png"
#iChannel0 "file://../../../../assets/334.jpg"

#include "./c1.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec3 col =pgause(fragCoord, 0);

    fragColor = vec4(col, 1.0);
}