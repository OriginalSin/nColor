// Gradient magnitude and direction
#iChannel0 "file://../../../../assets/334.jpg"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 uvAndOffset = vec4(fragCoord,0.5,0.5) / iChannelResolution[0].xyxy;
    
    vec3 hp = texture(iChannel0, uvAndOffset.xy + uvAndOffset.zw * vec2( 1, 0)).rgb;
    vec3 hn = texture(iChannel0, uvAndOffset.xy + uvAndOffset.zw * vec2(-1, 0)).rgb;
    vec3 vp = texture(iChannel0, uvAndOffset.xy + uvAndOffset.zw * vec2( 0, 1)).rgb;
    vec3 vn = texture(iChannel0, uvAndOffset.xy + uvAndOffset.zw * vec2( 0,-1)).rgb;
     
    vec3 h = hp-hn;
    vec3 v = vp-vn;
    
    float magnitude = sqrt(dot(h,h) + dot(v,v));
    vec2 vec = vec2( dot(h,vec3(1)), dot(v,vec3(1)) );
    float len = max(0.000001,length(vec));
    vec /= len;
     
    fragColor = vec4(vec, magnitude, 1);
}