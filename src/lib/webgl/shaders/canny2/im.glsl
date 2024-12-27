void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
    vec4 c0 = texture(iChannel0, uv); // Gradients
    vec4 c1 = texture(iChannel1, uv); // Anti-aliased non-maxima suppression
    vec4 c2 = texture(iChannel2, uv); // Hysteresis via cellular automata
    c1 /= c1.a; // antialiasing is accumulative.
    
    //fragColor = texture(iChannel1, uv) * pow(vec4(1)-fragColor, vec4(5.0));
    
    fragColor = vec4(c0.z * c1.x * c2.x);
}