#iChannel0 "file://./b.glsl"
#iChannel3 "file://./im.glsl"


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    vec2 uv = fragCoord / iResolution.xy;

    vec4 data = texture(iChannel0, uv);
    vec2 uvOffs = data.xy / iResolution.xy;
    
    uvOffs = uvOffs.yx;
    uvOffs.y = -uvOffs.y;
    
    
    vec4 posData = texture(iChannel0, uv + uvOffs);// * posMask.x;
    vec4 negData = texture(iChannel0, uv - uvOffs);// * negMask.x;

    float state = texture(iChannel3, uv).z;

    float posDot = max(0., dot(posData.xy, data.xy));
    float negDot = max(0., dot(negData.xy, data.xy));

  
    float pos = texture(iChannel3, uv + uvOffs).z * posDot;// * posMask.x;
    float neg = texture(iChannel3, uv - uvOffs).z * negDot;// * negMask.x;
    
    if(data.z > 0.55)
        state = 1.;
    else if(data.z < 0.15)
        state = 0.;
    else
    {
        if(pos > 0.)
            state =1.;
        if(neg > 0.)
            state = 1.;
    }
        
    fragColor = vec4(state,state,state,state);
}