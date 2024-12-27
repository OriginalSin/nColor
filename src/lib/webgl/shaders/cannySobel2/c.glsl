// Thresholding and edge tracking
// Threshold values range from 0-1

// sets RGB based on edge angle
#define COLOR_ANGLE 0
#define OUTLINE_COL 0.0f,0.5f,1.0f

bool hasStrong(sampler2D channel, ivec2 coord) {
    bool strong = false;
    strong = strong || (texelFetch(channel, coord + ivec2(-1,-1), 0).x > 0.5);
    strong = strong || (texelFetch(channel, coord + ivec2(0,-1), 0).x > 0.5);
    strong = strong || (texelFetch(channel, coord + ivec2(1,-1), 0).x > 0.5);
    strong = strong || (texelFetch(channel, coord + ivec2(-1,0), 0).x > 0.5);
    strong = strong || (texelFetch(channel, coord + ivec2(1,0), 0).x > 0.5);
    strong = strong || (texelFetch(channel, coord + ivec2(-1,1), 0).x > 0.5);
    strong = strong || (texelFetch(channel, coord + ivec2(0,1), 0).x > 0.5);
    strong = strong || (texelFetch(channel, coord + ivec2(1,1), 0).x > 0.5);
    return strong;
}

bool threshold(float angle, sampler2D channel, ivec2 coord) {
    if (angle < 22.5 || angle >= 157.5) {
        float current = length(texelFetch(channel, coord, 0));
        float left = length(texelFetch(channel, coord + ivec2(-1,0), 0));
        float right = length(texelFetch(channel, coord + ivec2(1,0), 0));
        return current >= left && current >= right;
    } else if (angle < 67.5) {
        float current = length(texelFetch(channel, coord, 0));
        float left = length(texelFetch(channel, coord + ivec2(-1,-1), 0));
        float right = length(texelFetch(channel, coord + ivec2(1,1), 0));
        return current >= left && current >= right;
    } else if (angle < 112.5) {
        float current = length(texelFetch(channel, coord, 0));
        float left = length(texelFetch(channel, coord + ivec2(0,-1), 0));
        float right = length(texelFetch(channel, coord + ivec2(0,1), 0));
        return current >= left && current >= right;
    } else if (angle < 157.5) {
        float current = length(texelFetch(channel, coord, 0));
        float left = length(texelFetch(channel, coord + ivec2(-1,1), 0));
        float right = length(texelFetch(channel, coord + ivec2(1,-1), 0));
        return current >= left && current >= right;
    } else {
        return false;
    }
}

#iChannel2 "file://./b.glsl"
#iChannel3 "self"

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 sobel = texelFetch(iChannel2, ivec2(fragCoord), 0);
    float mag = length(sobel.xy);
    float angle = 57.2957795131*abs(atan(sobel.y,sobel.x));
    
    bool isMax = threshold(angle, iChannel2, ivec2(fragCoord));
    vec4 thresholded = vec4(0.0,0.0,0.0,1.0);
    if (iMouse.z>0.){
        if (isMax && mag >= 0.5*iMouse.y/iResolution.y) {
            thresholded = vec4(1.0);
        } else if (isMax && mag >= .5*iMouse.x/iResolution.x && hasStrong(iChannel3, ivec2(fragCoord))) {
            thresholded = vec4(1.0);
        }
    }
    else{
        if (isMax && mag >= .4) {
            thresholded = vec4(1.);
        } else if (isMax && mag >= .4 && hasStrong(iChannel3, ivec2(fragCoord))) {
            thresholded = vec4(1.);
        }
    }
    
    #if COLOR_ANGLE
        vec3 outlineCol = vec3(sin(angle), sin(angle + 2.0f*M_PI/3.0f),sin(angle + 2.f*M_PI/3.0f * 2.0f));
	#else
        vec3 outlineCol = vec3(OUTLINE_COL);
    #endif
    //highlight edges of different direction
    outlineCol/=(angle)/110.;
    // Output to screen
    fragColor = vec4(outlineCol*float(thresholded),1.);   
}