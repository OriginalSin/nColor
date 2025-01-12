#iChannel0 "file://../../../../assets/334_256.jpg"
// #iChannel0 "file://../../../../assets/334_256mono.bmp"
#define EPS 0.01
// #define T(U)             texelFetch( iChannel0, ivec2(U), 0)
#define P           vec4(.2, 0.0001, 0.001, 0.001)

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 resol = iResolution.xy;
    vec4 uvAndOffset = vec4(fragCoord,0.5,0.5) / resol.xyxy;
    
    vec2 pos = fragCoord / iChannelResolution[0].xy;
    vec3 cp = texture(iChannel0, fragCoord / resol.xy).rgb;

    vec3 hp = texture(iChannel0, (fragCoord + vec2( 1, 0)) / resol.xy).rgb;
    vec3 hn = texture(iChannel0, (fragCoord + vec2(-1, 0)) / resol.xy).rgb;
    vec3 vp = texture(iChannel0, (fragCoord + vec2( 0, 1)) / resol.xy).rgb;
    vec3 vn = texture(iChannel0, (fragCoord + vec2( 0, -1)) / resol.xy).rgb;
     
    vec3 h1 = hp - cp;
    vec3 h2 = hn - cp;
    vec3 v1 = vp - cp;
    vec3 v2 = vn - cp;
 
    float magnitude = sqrt(
        P.x * dot(h1, h1) + 
        P.y * dot(h2 ,h2) + 
        P.z * dot(v1 ,v1) + 
        P.w * dot(v2 ,v2)
        ) / (P.x + P.y + P.z + P.w);
    vec3 magnitude2 = h1 + h2 + v1 + v2;

    if (magnitude2.x < EPS) {fragColor = vec4(0.8745, 0.8863, 0.5098, 1.0); }
    // if (magnitude2.x < EPS) {fragColor = vec4(cp, 0.); }
    if (magnitude < EPS) {fragColor = vec4(0.8863, 0.6235, 0.5098, 1.0); }


    // fragColor = vec4(cp, 0.);
}

