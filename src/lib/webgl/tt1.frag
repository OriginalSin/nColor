uniform sampler2D texture;
uniform vec2 delta;
varying vec2 texCoord;
// + s + 

void main() {
    vec2 color = vec2(0.0);
    vec2 total = vec2(0.0);
    float offset = random(vec3(12.9898, 78.233, 151.7182), 0.0);
    for(float t = -30.0; t <= 30.0; t++) {
        float percent = (t + offset - 0.5) / 30.0;
        float weight = 1.0 - abs(percent);
        vec3 sample = texture2D(texture, texCoord + delta * percent).rgb;
        float average = (sample.r + sample.g + sample.b) / 3.0;
        color.x += average * weight;
        total.x += weight;
        if(abs(t) < 15.0) {
            weight = weight * 2.0 - 1.0;
            color.y += average * weight;
            total.y += weight;
        }
    }
    gl_FragColor = vec4(color / total, 0.0, 1.0);
}

uniform sampler2D texture;
uniform vec2 delta;
varying vec2 texCoord;

float random(vec3 scale, float seed){
    return fract(sin(dot(gl_FragCoord.xyz + seed, scale)) * 43758.5453 + seed);
}

void main() {
    vec2 color = vec2(0.0);
    vec2 total = vec2(0.0);
    float offset = random(vec3(12.9898, 78.233, 151.7182), 0.0);
    for(float t = - 30.0; t <= 30.0; t ++) {
        float percent = (t + offset - 0.5) / 30.0;
        float weight = 1.0 - abs(percent);
        vec2 sample = texture2D(texture, texCoord + delta * percent).xy;
        color.x += sample.x * weight;
        total.x += weight;
        if(abs(t) < 15.0) {
            weight = weight * 2.0 - 1.0;
            color.y += sample.y * weight;
            total.y += weight;
        }
    }
    float c = clamp(10000.0 * (color.y / total.y - color.x / total.x) + 0.5, 0.0, 1.0);
    gl_FragColor = vec4(c, c, c, 1.0);
}