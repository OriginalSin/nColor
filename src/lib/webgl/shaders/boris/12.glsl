vec2 gridSize = vec2(5,4);

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;
        
    // vec2 g = fract((uv + 0.005) * gridSize);
    vec2 g = fract(uv * gridSize);

	fragColor = vec4(min(g.x , g.y) < 0.05);  
}