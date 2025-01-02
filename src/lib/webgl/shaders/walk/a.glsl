// Buffer A
#iChannel0 "self"

const float N = 10.0;
const float d = 1.0 / 60.0;
const float R = d / 2.0;
const float W = R * 0.15;
const float r = R * cos(radians(30.0));

float random(vec2 seed) {
    // https://thebookofshaders.com/10/
    return fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float cross2(vec2 p, vec2 q) {
    return p.x * q.y - p.y * q.x;
}

bool in_tri(vec2 uv, vec2 v1, vec2 v2, vec2 v3) {
    // https://mathworld.wolfram.com/TriangleInterior.html
    // http://www.sunshine2k.de/coding/java/pointInTriangle/pointInTriangle.html
    vec2 w1 = v2 - v1;
    vec2 w2 = v3 - v1;
    float d = determinant(mat2(w1, w2));
    // check for d ≈ 0.0 ?
    float s = determinant(mat2(uv - v1, w2)) / d;
    float t = determinant(mat2(w1, uv - v2)) / d;
    return s >= 0.0 && t >= 0.0 && (s + t) <= 1.0;
}

bool in_reg(vec2 uv, vec2 c, float n, float R, float theta) {
    // break-up regular polygon into triangles
    float dt = radians(360.0 / n);
    for (float i = 0.0, j = 1.0; i < n; i++, j++) {
        vec2 a = R * vec2(cos(dt * i + theta), sin(dt * i + theta)) + c;
        vec2 b = R * vec2(cos(dt * j + theta), sin(dt * j + theta)) + c;
        if (in_tri(uv, a, b, c)) {
            return true;
        }
    }
    return false;
}

bool in_cir(vec2 uv, vec2 c, float R) {
    return distance(uv, c) < R;
}

bool in_hex(vec2 uv, vec2 c, float R) {
    return in_reg(uv, c, 6.0, R, radians(30.0));
}

vec2 uv_to_cir(vec2 uv, float R) {
    return (1.0 + floor(uv / d)) * d - R;
}

vec2 uv_to_hex(vec2 uv, float R) {
    float theta = radians(30.0);
    float r = R * cos(theta);
    mat2 b = mat2(2.0 * r, 0.0, r, 1.5 * R);
    vec2 hex = b * round(inverse(b) * uv);
    bool inhex = in_reg(uv, hex, 6.0, R, theta);
    // adjust hex coordinate due to overlap
    if (!inhex)
        if (cross2(vec2(r, 0.5 * R), hex - uv) < 0.)
            hex += (uv.x > hex.x) ? b[1] : -b[0];
        else
            hex += (uv.x > hex.x) ? b[0] : -b[1];
    return hex;
}

vec3 rcir(vec2 seed, vec3 n, vec3 e, vec3 w, vec3 s) {
    // select random available direction
    vec3[] dir = vec3[4] (n, e, w, s);
    int i = 0;
    if (n == vec3(0)) dir[i++] = vec3(1, 0, 0);
    if (e == vec3(0)) dir[i++] = vec3(0, 1, 1);
    if (w == vec3(0)) dir[i++] = vec3(0, 1, 0);
    if (s == vec3(0)) dir[i++] = vec3(0, 0, 1);
    return dir[int(float(i) * random(seed))];
}

vec3 rhex(vec2 seed, vec3 nw, vec3 ne, vec3 wc, vec3 ec, vec3 sw, vec3 se) {
    // select random available direction
    vec3[] dir = vec3[6] (nw, ne, wc, ec, sw, se);
    int i = 0;
    if (nw == vec3(0)) dir[i++] = vec3(1, 1, 0);
    if (ne == vec3(0)) dir[i++] = vec3(1, 0, 1);
    if (wc == vec3(0)) dir[i++] = vec3(1, 0, 0);
    if (ec == vec3(0)) dir[i++] = vec3(0, 1, 1);
    if (sw == vec3(0)) dir[i++] = vec3(0, 1, 0);
    if (se == vec3(0)) dir[i++] = vec3(0, 0, 1);
    return dir[int(float(i) * random(seed))];
}

vec2 y_to_xy(vec2 uv) {
    return uv / (iResolution.xy / iResolution.y) * (iResolution.xy / iResolution.xy);
}

vec4 main_cir(in vec2 uv, vec2 range) {
    vec2 cell = uv_to_cir(uv, R);
    
    vec3 col1 = texture(iChannel0, y_to_xy(uv)).rgb;
    vec3 col2 = vec3(0);
    
    if (mod(float(iFrame), N) == 0.0) {
        if (col1 == vec3(0)) {
            // initialize random cell and direction
            vec2 rcell = uv_to_cir(vec2(range.x + range.y * random(iTime + iDate.xy), random(iTime * iDate.xy)), R);
            if (cell == rcell) {
                col2 = rcir(rcell * iTime, vec3(0), vec3(0), vec3(0), vec3(0));
            }
        }
    }  
    
    if (col1 == vec3(0)) {
        // von Neumann neighborhood state
        vec3 n = texture(iChannel0, y_to_xy(cell + vec2(0., +d))).rgb;
        vec3 e = texture(iChannel0, y_to_xy(cell + vec2(+d, 0.))).rgb;
        vec3 w = texture(iChannel0, y_to_xy(cell + vec2(-d, 0.))).rgb;
        vec3 s = texture(iChannel0, y_to_xy(cell + vec2(0., -d))).rgb;
        // is there an instruction?
        if (n == vec3(0, 0, 1) || e == vec3(0, 1, 0) || w == vec3(0, 1, 1) || s == vec3(1, 0, 0)) {
            col2 = rcir(cell * iTime, n, e, w, s);
        }
    } else {
        col2 = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4)) - vec3(.01);
    }
     
    
    float aa = 2.0 / iResolution.y; 
    float dist = distance(uv, cell) - (R - W);
    // col2 = in_cir(uv, cell, R - W) ? col2 : vec3(0); // anit-alias off
    col2 *= smoothstep(aa, 0.0, dist);                  // anit-alias on
    
    return vec4(col2, 1.0);
}

vec4 main_hex(in vec2 uv, vec2 range) {
    vec2 cell = uv_to_hex(uv, R);
    vec3 col = vec3(0);
    // on grid
    if (in_hex(uv, cell, R - W)) {
        // previous color
        col = texture(iChannel0, y_to_xy(uv)).rgb;
        if (mod(float(iFrame), N) == 0.0) {
            if (col == vec3(0)) {
                // initialize random cell and direction
                vec2 rcell = uv_to_hex(vec2(range.x + range.y * random(iTime + iDate.xy), random(iTime * iDate.xy)), R);
                if (cell == rcell) {
                    col = rhex(rcell * iTime, vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), vec3(0));
                }
            }
        } else {
            if (col == vec3(0)) {
                // hexagonal neighborhood state
                vec3 nw = texture(iChannel0, y_to_xy(cell + vec2(-(1.0 * r), +(1.5 * R)))).rgb;
                vec3 ne = texture(iChannel0, y_to_xy(cell + vec2(+(1.0 * r), +(1.5 * R)))).rgb;
                vec3 wc = texture(iChannel0, y_to_xy(cell + vec2(-(2.0 * r), (0.000000)))).rgb;
                vec3 ec = texture(iChannel0, y_to_xy(cell + vec2(+(2.0 * r), (0.000000)))).rgb;
                vec3 sw = texture(iChannel0, y_to_xy(cell + vec2(-(1.0 * r), -(1.5 * R)))).rgb;
                vec3 se = texture(iChannel0, y_to_xy(cell + vec2(+(1.0 * r), -(1.5 * R)))).rgb;
                // is there an instruction?
                if (nw == vec3(0, 0, 1) || ne == vec3(0, 1, 0) || wc == vec3(0, 1, 1) || 
                    ec == vec3(1, 0, 0) || sw == vec3(1, 0, 1) || se == vec3(1, 1, 0)) {
                    col = rhex(cell * iTime, nw, ne, wc, ec, sw, se);
                }
            } else {
                col = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4)) - vec3(.01);
            }
        }
    }
    return vec4(col, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord / iResolution.y;
    float mid = iResolution.x / iResolution.y / 2.0;
    vec2 range = uv.x < mid ? vec2(0.0, mid) : vec2(mid, mid);
    fragColor = fragCoord.x < iResolution.x / 2.0 ? main_cir(uv, range) : main_hex(uv, range);
}
