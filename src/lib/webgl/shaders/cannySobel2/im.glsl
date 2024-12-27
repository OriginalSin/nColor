/*****************************************************
Interaction enabled

Change source image in Buffer A, not here.

*****************************************************/


#iChannel1 "file://./a.glsl"
#iChannel2 "file://./b.glsl"
#iChannel3 "file://./c.glsl"

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    float textureWidth = 1.0 / 3.0;
    int textureIndex = int(uv.x * 3.0);
    vec2 texCoord = vec2((uv.x * 3.0 - float(textureIndex)) * textureWidth, uv.y);
    

    
    // separate into 3 part
    vec4 color;
    if (textureIndex == 0) {
        color = texture(iChannel1, texCoord); // Gaussian filter
    } else if (textureIndex == 1) {
        color = texture(iChannel2, texCoord); // Sobel 
    } else if (textureIndex == 2) {
        color = texture(iChannel3, texCoord); // Canny 
    }
    // Full screen display of selected area
    if (iMouse.w>0. && textureIndex == int(iMouse.x/iResolution.x * 3.0)) {
        texCoord = vec2(uv.x, uv.y * iResolution.y / iResolution.x);
    }
    if(iMouse.z>0. && int(abs(iMouse.z)/iResolution.x * 3.) ==0)
    {
    color=texture(iChannel1, uv);
    }
    if(iMouse.z>0. && int(abs(iMouse.z)/iResolution.x * 3.) ==1)
    {
    color=texture(iChannel2, uv);
    }
    if(iMouse.z>0. && int(abs(iMouse.z)/iResolution.x * 3.) ==2)
    {
    color=texture(iChannel3, uv);
    }
    // 输出纹素颜色
    fragColor = color;
}

