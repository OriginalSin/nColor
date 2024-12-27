#define offset 0.001

//#define EdgeDetection
#define Scharr

#iChannel0 "file://../../../../assets/334.jpg"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float edgeThreshold = .5;

    vec2 uv = fragCoord/iResolution.xy;
    vec3 col = texture(iChannel0, uv).rgb;
    
    vec3 topLeft = texture(iChannel0, uv + vec2(-offset, offset)).rgb;
    vec3 topMiddle = texture(iChannel0, uv + vec2(0., offset)).rgb;
    vec3 topRight = texture(iChannel0, uv + vec2(offset, offset)).rgb;
    
    vec3 right = texture(iChannel0, uv + vec2(offset,0.)).rgb;
    vec3 left = texture(iChannel0, uv + vec2(-offset, 0.)).rgb;
    
    vec3 botLeft = texture(iChannel0, uv + vec2(-offset, -offset)).rgb;
    vec3 botMiddle = texture(iChannel0, uv + vec2(0., -offset)).rgb;
    vec3 botRight = texture(iChannel0, uv + vec2(offset, -offset)).rgb;
    
#ifdef EdgeDetection
    //Sobel Operator Vertical
    //1 0 -1
    //2 0 -2
    //1 0 -1
    vec3 verticalGradiant = topLeft + (2. * topMiddle) + topRight -botLeft - (2. * botMiddle) - botRight; 
    
    //Sobel Vertical
    // 1  2  1
    // 0  0  0
    //-1 -2 -1
    vec3 horizontalGradiant = -topLeft + topRight + (2. * right) + (-2. * left) - botLeft + botRight;
    
    vec3 gradiantmMagnitude = sqrt(verticalGradiant * verticalGradiant + horizontalGradiant * horizontalGradiant);
    
    float edgeValue = (0.299*gradiantmMagnitude.r + 0.587*gradiantmMagnitude.g + .114*gradiantmMagnitude.b) > edgeThreshold ? 1. : 0.;
    
    fragColor = vec4(edgeValue);
#endif
#ifdef Scharr
    //Sobel Vertical
    //47 0 -47
    //162 0 -162
    //47 0 -47
    vec3 verticalGradiant = (47. * topLeft) + (-47. * topRight) + (162. * right) + (-162. * left) + (47. * botLeft) + (-47. * botRight); 
    
    
    //Sobel Vertical
    // 47  162  47
    // 0   0    0
    //-47 -162 -47
    vec3 horizontalGradiant = (47. * topLeft) + (162. * topMiddle) + (47. * topRight) + (-47. * botLeft) - (162. * botMiddle) + (-47. * botRight);
    
    vec3 gradiantmMagnitude = sqrt(verticalGradiant * verticalGradiant + horizontalGradiant * horizontalGradiant);
    
    float edgeValue = (0.299*gradiantmMagnitude.r + 0.587*gradiantmMagnitude.g + .114*gradiantmMagnitude.b) / 35. > edgeThreshold ? 1. : 0.;
    
    fragColor = vec4(edgeValue);
#endif
}