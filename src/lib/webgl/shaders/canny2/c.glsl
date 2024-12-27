// 
#iChannel0 "file://./b.glsl"
// #iChannel1 "file://./c.glsl"
#iChannel2 "file://./d.glsl"
// #iChannel3 "file://./im.glsl"

#define TECHNIQUE 1
#include "./utils.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
#if TECHNIQUE == 0
    vec2 uv = fragCoord / iResolution.xy;
    
    vec2 dir = texture(iChannel0, uv).xy / iResolution.xy;
    
    float center = texture(iChannel0, uv).z;
    float pos = texture(iChannel0, uv + dir).z;
    float neg = texture(iChannel0, uv - dir).z;
    
    fragColor = vec4(vec3(max(0., center * 2. - pos - neg)), 1);
#elif TECHNIQUE == 1   
    vec2 uv = fragCoord / iResolution.xy;
    vec2 uvWithOffset = uv;
    
    uint rngState = uint
    (
        uint(iFrame) * uint(1973) 
    ) | uint(1);
    
    // Using time-varying blue noise as subpixel offsets 
    // will kill persistent moire patterns.
    // If you modify the shader to accumulate,
    // it'll converge on a nice image with no aliasing.
    // (It uses gaussian windowing, not an ideal lowpass filter however.)
    vec4 blueNoise = sampleBlueNoise(iChannel2, fragCoord, rngState);
    uvWithOffset += (blueNoise.xy - 0.5)*1.0 / iResolution.xy; 
    
    vec2 dir = normalize(texture(iChannel0, uvWithOffset).xy) / iResolution.xy;
    
    float center = texture(iChannel0, uvWithOffset).z;
    float pos = texture(iChannel0, uvWithOffset + dir).z;
    float neg = texture(iChannel0, uvWithOffset - dir).z;
    
    fragColor = texture(iChannel3, uv) + vec4(vec3(center > pos && center > neg ? 1. : 0.), 1);
#endif
}