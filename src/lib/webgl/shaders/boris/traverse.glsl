// Created by genis sole - 2017
// License Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.

const float w = 2.;

float grid(vec2 uv, float e) 
{
   vec2 g = smoothstep(0.0, w*e, abs(fract(uv + 0.5) - 0.5)); 
   return g.x * g.y;
}

float point(vec2 uv, float e, vec2 p) 
{
	return smoothstep(0.07, 0.07 + w*e, length(uv - p)); 
}

float segment(vec2 uv, float e, vec2 d, vec2 p, float l) 
{
    return max(1.0 - min(step(0.0, dot(d, uv - p)), 
                         step(0.0, dot(d, p + d*l - uv))),
   		       smoothstep(0.015, 0.015 + w*e, abs(dot(vec2(-d.y, d.x), p - uv))));
}

float refract_index(vec2 c) 
{
    return 1.0 + step(-3.2, -length(c - vec2(7.0, 6.0)))*1.7;
}

vec2 traversal(vec2 uv, float e, vec2 ro, vec2 rd) 
{   
    vec2 v = vec2(1.0);
    
    vec2 n = vec2(0.0);
    vec2 c = floor(ro) + 0.5;
    ro -= c;
    
    float refri = refract_index(c - 0.5);
    
    for( int s = 32; s > 0; --s ){
        vec2 d = (sign(rd)*0.5 - ro) / rd;
        
        v.x = min(v.x, segment(uv, e, rd, c + ro, min(d.x, d.y))); // Draw segments.
        
        ro += min(d.x, d.y) * rd;
        n = -sign(rd) * step(d.xy, d.yx);

        // Refraction part.
        #if 1
        float nrefri = refract_index(c - 0.5 - n);
        
        vec2 reflrd = reflect(rd, n);
        rd = refract(rd, n, refri/nrefri);
        
        float t = step(0.0, -dot(rd, rd));
       	refri = mix(nrefri, refri, t);
        rd += reflrd*t;
        n *= 1.0 - t;
        #endif
        
        c -= n;
       	ro += n;
        
        // Draw cells and points.
        v = min(v, 
                vec2(point(uv, e, c + ro), 
                	 step(0.5, length(floor(uv) - c + 0.5))));
    }
    
    return v;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float e = 25.0 / iResolution.x;
    vec2 offset = vec2(5.0, 3.0);
	vec2 uv = fragCoord.xy*e - offset;
    
    vec2 ro = vec2(1.7, 1.2);
    
    vec2 rd = (length(iMouse.xy) < 10.0)
        	? normalize(vec2(1.0, sin(iTime*0.2) + 1.5))
    		: normalize(iMouse.xy*e - offset - ro);
    
    float ri = refract_index(floor(uv));
    vec3 c = vec3(1.0 - step(0.0, 1.0 - ri), 0.2, 
                  step(0.0, 1.0 - ri)) + 0.3;
   
    vec2 t = traversal(uv, e, ro, rd);
    c += (1.0 - t.y) * 0.2;
    c *= t.x;
    c *= grid(uv, e);
    c *= point(uv, e, ro);
    
	fragColor = vec4(pow(clamp(c, 0.0, 1.0), vec3(0.4545)), 1.0);
}