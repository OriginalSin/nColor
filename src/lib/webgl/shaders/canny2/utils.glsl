// https://www.shadertoy.com/view/lcc3Df
///////////////////////////////////////////////
// HELPER FUNCTIONS
///////////////////////////////////////////////

// Constants ----------------------------------

const float Pi = 3.14159265358979;
const float Tau = Pi * 2.0;
const float InvPi = 1.0 / 3.14159265358979;

// HLSL support -------------------------------

#define float2 vec2
#define float3 vec3
#define float4 vec4

#define half  float
#define half2 vec2
#define half3 vec3
#define half4 vec4

#define fixed  float
#define fixed2 vec2
#define fixed3 vec3
#define fixed4 vec4

#define int2 ivec2
#define int3 ivec3
#define int4 ivec4

#define bool2 bvec2
#define bool3 bvec3
#define bool4 bvec4

#define lerp mix

#define decl_saturate(type)            \
type saturate(type x)                  \
{                                      \
    return clamp(x, type(0), type(1)); \
} 

decl_saturate(float)
decl_saturate(vec2)
decl_saturate(vec3)
decl_saturate(vec4)

// Boolean -------------------------------

bool  isinf2(float v) { return isinf(v); } 
bvec2 isinf2(vec2 v)
{
    return bvec2
    (
        isinf(v.x),
        isinf(v.y)
    );
}
bvec3 isinf2(vec3 v)
{
    return bvec3
    (
        isinf(v.x),
        isinf(v.y),
        isinf(v.z)
    );
}
bvec4 isinf2(vec4 v)
{
    return bvec4
    (
        isinf(v.x),
        isinf(v.y),
        isinf(v.z),
        isinf(v.w)
    );
}

bool  isnan2(float v) { return isnan(v); } 
bvec2 isnan2(vec2 v)
{
    return bvec2
    (
        isnan(v.x),
        isnan(v.y)
    );
}
bvec3 isnan2(vec3 v)
{
    return bvec3
    (
        isnan(v.x),
        isnan(v.y),
        isnan(v.z)
    );
}
bvec4 isnan2(vec4 v)
{
    return bvec4
    (
        isnan(v.x),
        isnan(v.y),
        isnan(v.z),
        isnan(v.w)
    );
}

bool bnot(bool b) { return !b; }
bvec2 bnot(bvec2 b) 
{ 
    return bvec2(!b.x, !b.y); 
}
bvec3 bnot(bvec3 b) 
{ 
    return bvec3(!b.x, !b.y, !b.z); 
}
bvec4 bnot(bvec4 b) 
{ 
    return bvec4(!b.x, !b.y, !b.z, !b.w); 
}

bool band(bool a, bool b) { return a && b; }
bvec2 band(bvec2 a, bvec2 b) 
{ 
    return bvec2
    (
        a.x && b.x,
        a.y && b.y
    ); 
}
bvec3 band(bvec3 a, bvec3 b) 
{ 
    return bvec3
    (
        a.x && b.x,
        a.y && b.y,
        a.z && b.z
    ); 
}
bvec4 band(bvec4 a, bvec4 b) 
{ 
    return bvec4
    (
        a.x && b.x,
        a.y && b.y,
        a.z && b.z,
        a.w && b.w
    ); 
}

bool bor(bool a, bool b) { return a || b; }
bvec2 bor(bvec2 a, bvec2 b) 
{ 
    return bvec2
    (
        a.x || b.x,
        a.y || b.y
    ); 
}
bvec3 bor(bvec3 a, bvec3 b) 
{ 
    return bvec3
    (
        a.x || b.x,
        a.y || b.y,
        a.z || b.z
    ); 
}
bvec4 bor(bvec4 a, bvec4 b) 
{ 
    return bvec4
    (
        a.x || b.x,
        a.y || b.y,
        a.z || b.z,
        a.w || b.w
    ); 
}

bool bxor(bool a, bool b) { return a != b; }
bvec2 bxor(bvec2 a, bvec2 b) 
{ 
    return bvec2
    (
        a.x != b.x,
        a.y != b.y
    ); 
}
bvec3 bxor(bvec3 a, bvec3 b) 
{ 
    return bvec3
    (
        a.x != b.x,
        a.y != b.y,
        a.z != b.z
    ); 
}
bvec4 bxor(bvec4 a, bvec4 b) 
{ 
    return bvec4
    (
        a.x != b.x,
        a.y != b.y,
        a.z != b.z,
        a.w != b.w
    ); 
}

#define decl_isfinite(retType, type) \
retType isfinite(type v)             \
{                                    \
    return band                      \
    (                                \
        bnot(isinf2(v)),             \
        bnot(isnan2(v))              \
    );                               \
} 
decl_isfinite(bool, float)
decl_isfinite(bvec2, vec2)
decl_isfinite(bvec3, vec3)
decl_isfinite(bvec4, vec4)

float select(bool s, float a, float b)
{
    return s ? a : b;
}

vec2 select(bvec2 s, vec2 a, vec2 b)
{
    return vec2
    (
        s.x ? a.x : b.x,
        s.y ? a.y : b.y
    );  
}

vec3 select(bvec3 s, vec3 a, vec3 b)
{
    return vec3
    (
        s.x ? a.x : b.x,
        s.y ? a.y : b.y,
        s.z ? a.z : b.z
    );  
}

vec4 select(bvec4 s, vec4 a, vec4 b)
{
    return vec4
    (
        s.x ? a.x : b.x,
        s.y ? a.y : b.y,
        s.z ? a.z : b.z,
        s.w ? a.w : b.w
    );  
}

// Vector math -------------------

float dot2(vec2 a, vec2 b) { return a.x * b.x + a.y * b.y; }
float dot2(vec3 a, vec3 b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
float dot2(vec4 a, vec4 b) { return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w; }
int dot2(ivec2 a, ivec2 b) { return a.x * b.x + a.y * b.y; }
int dot2(ivec3 a, ivec3 b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
int dot2(ivec4 a, ivec4 b) { return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w; }

#define decl_lengthSqr(retType, type) \
retType lengthSqr(type a)             \
{                                     \
    return dot2(a,a);                 \
}                                     

decl_lengthSqr(float, vec2)
decl_lengthSqr(float, vec3)
decl_lengthSqr(float, vec4)
decl_lengthSqr(int, ivec2)
decl_lengthSqr(int, ivec3)
decl_lengthSqr(int, ivec4)

#define decl_distSqr(retType, type) \
retType distSqr(type a, type b)     \
{                                   \
    type diff = a-b;                \
    return lengthSqr(diff);         \
}                                   

decl_distSqr(float, vec2)
decl_distSqr(float, vec3)
decl_distSqr(float, vec4)
decl_distSqr(int, ivec2)
decl_distSqr(int, ivec3)
decl_distSqr(int, ivec4)

// Borrowed from UnityEngine
#define decl_safeNormalize(type)                 \
type safeNormalize(type inVec)                   \
{                                                \
    float dp3 = max(0.001f, dot2(inVec, inVec)); \
    return inVec / sqrt(dp3);                    \
}
decl_safeNormalize(vec2)
decl_safeNormalize(vec3)
decl_safeNormalize(vec4)

// Trig Math ----------------------

#define decl_cosToTan(type)\
type cosToTan(type cosine)\
{\
    return (sqrt(type(1.0)-cosine)*sqrt(cosine+type(1.0))) / cosine;\
}
decl_cosToTan(float)
decl_cosToTan(vec2)
decl_cosToTan(vec3)
decl_cosToTan(vec4)

#define decl_tanToCos(type)\
type tanToCos(type tangent)\
{\
    return type(1.0)/sqrt(tangent*tangent+type(1.0));\
}
decl_tanToCos(float)
decl_tanToCos(vec2)
decl_tanToCos(vec3)
decl_tanToCos(vec4)

// Misc. math --------------------

// I don't trust int(floor(x)).
// So, for positive values:
//
// x = floor(x)
//
// Add 0.5 in case floor(x) rounded it to some floating point garbage like 23.99999
// x += 0.5
//
// ix = int(x) // THEN cast to an int.
//
// Similar thing happens for negative values.
#define decl_floorToInt(retType, type)              \
retType floorToInt(type a)                          \
{                                                   \
    return retType(floor(a) + sign(a) * type(0.5)); \
}                                                   

decl_floorToInt(int, float)
decl_floorToInt(ivec2, vec2)
decl_floorToInt(ivec3, vec3)
decl_floorToInt(ivec4, vec4)

#define decl_invMix(type) \
type invMix(type a, type b, type t) \
{                                   \
    type result = (t-a)/(b-a);      \
    return select(isfinite(result), result, type(0.5)); \
}

decl_invMix(float)
decl_invMix(vec2)
decl_invMix(vec3)
decl_invMix(vec4)

#define invLerp invMix

#define decl_square(type)\
type square(type a)\
{\
    return a*a;\
}

decl_square(int)
decl_square(ivec2)
decl_square(ivec3)
decl_square(ivec4)
decl_square(float)
decl_square(vec2)
decl_square(vec3)
decl_square(vec4)

half Pow5 (half x)
{
    return x*x * x*x * x;
}

half2 Pow5 (half2 x)
{
    return x*x * x*x * x;
}

half3 Pow5 (half3 x)
{
    return x*x * x*x * x;
}

half4 Pow5 (half4 x)
{
    return x*x * x*x * x;
}

// RNG ----------------------------------------

uint wang_hash(inout uint seed)
{
    seed = uint(seed ^ uint(61)) ^ uint(seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> 4);
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> 15);
    return seed;
}

float RandomFloat01(inout uint state)
{
    return float(wang_hash(state)) / 4294967296.0;
}

vec2 uniform01ToGauss(vec2 value)
{
    float magnitude = sqrt(-2.0 * log(value.x));
    
    value.y *= 6.28318530718;
    vec2 direction = vec2(cos(value.y),sin(value.y));
    return magnitude * direction;
}

vec4 sampleRandom(sampler2D tex, vec2 fragCoord, inout uint rngState)
{
    fragCoord /= vec2(textureSize(tex, 0));
    fragCoord += vec2
    (
        RandomFloat01(rngState),
        RandomFloat01(rngState)
    );
    
    return textureLod(tex, fragCoord, 0.0);
}

vec4 sampleBlueNoise(sampler2D blueNoiseTex, vec2 fragCoord, inout uint rngState)
{
    vec4 value = sampleRandom(blueNoiseTex, fragCoord, rngState);
    
    // The blue noise texture is limited to integer steps between
    // 0 and 255 (inclusive).
    // We need to add randomization to fill in the missing
    // intermediate values.
    value = mix(vec4(0.5 / 255.0), vec4(254.5 / 255.0), value);
    value += 
    (
        vec4
        (
            RandomFloat01(rngState), RandomFloat01(rngState),
            RandomFloat01(rngState), RandomFloat01(rngState)
        ) - 0.5
    ) * (1.0 / 255.0);
    
    return value;
}

// Color -------------------------------

#define decl_linearToGamma(type) \
type linearToGamma(type v)       \
{                               \
    return pow(v, type(1.0 / 2.2));   \
}

decl_linearToGamma(float)
decl_linearToGamma(vec2)
decl_linearToGamma(vec3)
decl_linearToGamma(vec4)

#define decl_gammaToLinear(type)    \
type gammaToLinear(type v)          \
{                                   \
    return pow(v, type(2.2)); \
}

decl_gammaToLinear(float)
decl_gammaToLinear(vec2)
decl_gammaToLinear(vec3)
decl_gammaToLinear(vec4)

// Credit: https://www.shadertoy.com/view/DsBGzy by sh1boot
vec3 hsv2rgb(vec3 hsv) 
{
    vec3 h3 = mod(6.0 * hsv.x + vec3(5.0, 3.0, 1.0), 6.0);
    h3 = min(h3, 4.0 - h3);
    h3 = clamp(h3, 0.0, 1.0);
    return hsv.z - hsv.z * hsv.y * h3;
}

// Credit: https://www.shadertoy.com/view/DsBGzy by sh1boot
vec3 palette(int i) 
{
    float f = float(i);
    float h =  mod(1.618033988749894848204586834 * f, 1.0);
    float s = exp(-0.00025 * f) * 0.65 + 0.25;
    float v = 1.0;
    return hsv2rgb(vec3(h, s, v));
}

vec4 cube(samplerCube cube, vec2 uv)
{
    uv -= floor(uv);
    uv = uv * 2.0 - 1.0;
    
    vec3 ray = vec3(uv, 1);
    
    return texture(cube, ray);
}

vec4 cubeFetch(samplerCube cube, ivec2 coord, int mip)
{
    vec2 uv = (vec2(coord) + vec2(0.5)) / vec2(textureSize(cube, mip));
    //uv = clamp(uv, vec2(0), vec2(1));
    uv -= floor(uv);
    uv = uv * 2.0 - 1.0;
    
    vec3 ray = vec3(uv, 1);
    
    return textureLod(cube, ray, float(mip));
}

vec4 cubeLod(samplerCube cube, vec2 uv, float mip)
{
    //uv = clamp(uv, vec2(0), vec2(1));
    uv -= floor(uv);
    uv = uv * 2.0 - 1.0;
    
    vec3 ray = vec3(uv, 1);
    
    return textureLod(cube, ray, mip);
}

struct quaternion
{
    vec4 value;
};

struct bounds
{
    vec3 mini, maxi;
};

bool rayIntersectBounds
(
    bounds b, 
    vec3 rayOrig, 
    vec3 rayDir,
    out vec3 nearHit,
    out vec3 farHit
)
{
    b.mini -= rayOrig;
    b.maxi -= rayOrig;
    
    vec3 signs = sign(rayDir);
    
   
    b.mini *= signs;
    b.maxi *= signs;
    rayDir *= signs;
    
    vec3 maxBounds = max((b.mini), (b.maxi));
    
    rayDir *= max(max(maxBounds.x, maxBounds.y),maxBounds.z) * 2.0; 
    
    
    
    {
        farHit = rayDir;
        vec3 clamped = min(farHit, maxBounds);
    
        vec3 scale = max(vec3(0.0), clamped / farHit);
        float minScale = min(min(scale.x, scale.y),scale.z); 
        farHit = (farHit * minScale) * signs + rayOrig;
    }
    
    /*{
        nearHit = -rayDir;
        vec3 clamped = clamp(nearHit, b.mini, b.maxi);
    
        vec3 scale = abs(clamped / nearHit);
        float minScale = max(max(scale.x, scale.y),scale.z); 
        nearHit = nearHit * minScale + rayOrig;
    }*/
    
    nearHit = rayOrig;

    return true;
}

quaternion mul(quaternion a, quaternion b)
{
    quaternion q;
    q.value = vec4
    (
        a.value.wwww * b.value 
      + (a.value.xyzx * b.value.wwwx + a.value.yzxy * b.value.zxyy) * vec4(1.0, 1.0, 1.0, -1.0) 
      - a.value.zxyz * b.value.yzxz
    );
    return q;
}

vec3 mul(quaternion q, vec3 v)
{
    vec3 t = 2.0 * cross(q.value.xyz, v);
    return v + vec3(q.value.w * t) + cross(q.value.xyz, t);
}

quaternion FromAngleAxis(vec3 angleAxis)
{
    float mag = length(angleAxis);
    float halfAngle = mag * 0.5;
    float scalar = sin(halfAngle) / max(mag, 0.00001);
        
    quaternion q;
    q.value = vec4(angleAxis * scalar, cos(halfAngle));
    return q;
}

quaternion FromToRotation(vec3 from, vec3 to)
{
    vec3 xyz = cross(from, to);
    float w = sqrt(dot(from, from) * dot(to, to)) + dot(from, to);
    vec4 value = vec4(xyz, w);
    quaternion q;
    q.value = normalize(value);
    return q;
}

quaternion LookRotation(float3 forward, float3 up)
{
    quaternion q;
    forward = safeNormalize(forward);
    q = FromToRotation(vec3(0,0,1), forward);
    up = up - dot(forward, up) * forward;
    vec3 upFrom = mul(q, vec3(0,1,0));
    q = mul(FromToRotation(upFrom, up), q);
    return q;
}

void sincos(vec3 x, out vec3 s, out vec3 c)
{
    s = sin(x);
    c = cos(x);
}
        
quaternion EulerZXY(float3 xyz)
{
    vec3 s, c;
    sincos(vec3(0.5) * xyz, s, c);

    return quaternion
    (
        vec4(s.xyz, c.x) * c.yxxy * c.zzyz 
      + s.yxxy * s.zzyz * vec4(c.xyz, s.x) * vec4(1, -1, -1, 1)
    );
}

mat4x4 RotationMatrix(quaternion q)
{
    float q0 = q.value.x;
    float q1 = q.value.y;
    float q2 = q.value.z;
    float q3 = q.value.w;
        
    /*# First row of the rotation matrix
    r00 = 2 * (q0 * q0 + q1 * q1) - 1
    r01 = 2 * (q1 * q2 - q0 * q3)
    r02 = 2 * (q1 * q3 + q0 * q2)
     
    # Second row of the rotation matrix
    r10 = 2 * (q1 * q2 + q0 * q3)
    r11 = 2 * (q0 * q0 + q2 * q2) - 1
    r12 = 2 * (q2 * q3 - q0 * q1)
     
    # Third row of the rotation matrix
    r20 = 2 * (q1 * q3 - q0 * q2)
    r21 = 2 * (q2 * q3 + q0 * q1)
    r22 = 2 * (q0 * q0 + q3 * q3) - 1*/
        
    float r00 = 2. * (q0 * q0 + q1 * q1) - 1.;
    float r01 = 2. * (q1 * q2 - q0 * q3);
    float r02 = 2. * (q1 * q3 + q0 * q2);
                                        
    float r10 = 2. * (q1 * q2 + q0 * q3);
    float r11 = 2. * (q0 * q0 + q2 * q2) - 1.;
    float r12 = 2. * (q2 * q3 - q0 * q1);
                                         
    float r20 = 2. * (q1 * q3 - q0 * q2);
    float r21 = 2. * (q2 * q3 + q0 * q1);
    float r22 = 2. * (q0 * q0 + q3 * q3) - 1.;
                             
    return mat4x4
    (
        mul(q, vec3(1,0,0)), 0,
        mul(q, vec3(0,1,0)), 0,
        mul(q, vec3(0,0,1)), 0,
        0,   0,   0,   1
    );
}

mat4x4 TRS(vec3 translation, quaternion rotation, vec3 scale)
{
    mat4x4 float3x = RotationMatrix(rotation);
    return mat4x4
    (
        vec4(float3x[0] * scale.x), 
        vec4(float3x[1] * scale.y), 
        vec4(float3x[2] * scale.z), 
        vec4(translation, 1)
    );
}

// Drawing helpers --------------------------------

void blend(in vec4 src, inout vec4 dest)
{
    dest.rgb = mix(dest.rgb, src.rgb, src.a);
    dest.a = mix(dest.a, 1.0, src.a);    
}

void drawCircle(vec2 center, vec2 frag, float radius, float lineWidth, vec4 lineColor, inout vec4 color)
{
    float distanceToEdge = abs(radius - distance(frag, center));

    float circle = smoothstep
    (
        0.0, 
        1.0,
        1.0 - (distanceToEdge / lineWidth) 
    );
                
    lineColor.a *= circle;
    blend(lineColor, color);
}

void drawSDF(vec3 diff_dist, inout vec4 color)
{
    float d = diff_dist.z;
    vec2 grad = diff_dist.xy/(d);
    
    vec3 c = normalize(vec3(grad,sign(d))) * 0.5 + 0.5;
	c *= 1. - exp2(-12. * abs(d));
	c *= .8 + .2 * cos(120.*d);

    color.rgb = c;
}

vec3 unsignedValueToColor(float value)
{
    float valueLog = log2(value + 0.0625);
    valueLog /= 16.0;
    //value /= 1. + abs(valueLog);
    valueLog = valueLog * 0.5 + 0.5;
    
    value *= 10.0;
    value += 0.125;
    value /= 1. + abs(value);
    
    return hsv2rgb(vec3(valueLog, 1, value));
}

// Font helpers ------------------------------
#define FONTSAMPLERSIZE vec2(1024, 1024)
#define FONTSAMPLERSIZEI ivec2(1024, 1024)
#define FONTELEMENTCOUNT  vec2(16, 16)
#define FONTELEMENTCOUNTI  ivec2(16, 16)
#define FONTELEMENTSIZE  vec2(64, 64)
#define FONTELEMENTSIZEI  ivec2(64, 64)
vec4 sampleFontElement(sampler2D fontSampler, in vec2 fragCoord, in ivec2 element)
{
    vec2 samplerCoordMin = vec2(element * FONTELEMENTSIZEI); 
    vec2 samplerCoordMax = vec2(element * FONTELEMENTSIZEI + FONTELEMENTSIZEI); 
    
    vec2 elementUV = (fragCoord - samplerCoordMin) / FONTELEMENTSIZE;
    elementUV -= floor(elementUV);
    
    vec2 samplerCoord = mix(samplerCoordMin, samplerCoordMax, elementUV);
    vec2 samplerUV = samplerCoord / FONTSAMPLERSIZE;
    
    return texture(fontSampler, samplerUV);
}

vec4 sampleFontElementColor(sampler2D fontSampler, in vec2 fragCoord, in ivec2 element, in vec4 color)
{
    float opacity = sampleFontElement(fontSampler, fragCoord, element).r;
    
    color.a *= opacity;
    
    return color;
}

vec3 getNoise(int iFrame)
{
    vec3 noise = vec3(0);

    // Calculate oising over time.
    vec3 temporalNoise;
    {
        // Use the golden ratio as it should land
        // on all fractional values eventually.
        temporalNoise = vec3(iFrame, iFrame+1, iFrame+2);
        temporalNoise *= vec3(0.7548776662, 0.56984029, 0.618033988749);

        // We floor this one early to prevent
        // loss of precision when iFrame becomes large.
        temporalNoise -= floor(noise);
    }
    noise += temporalNoise;

    #ifdef SPATIAL_NOISE
    // Add noising over space.
    // (Currently disabled; messes up the
    // gradient and especially the curvature
    // of the resulting map.)
    vec3 spatialNoise;
    {
        // Noise is added to vary the threshold
        // per pixel to speed up apparent convergence,
        // but the converged result shouldn't change.

        vec2 noiseUV = fragCoord.xy / iChannelResolution[1].xy;
        spatialNoise = texture(iChannel1, noiseUV).r;
    }
    noise += spatialNoise;
    #endif

    // Wrap values around from 0 to 1.
    noise -= floor(noise);

    // Center the sampling position offset
    // to a range within -0.5 to +0.5.
    noise.xy -= 0.5f;
    
    return noise;
}

// PBR Lighting ------------------------------
// Borrowed from UnityEngine
struct MaterialMetallic
{
    fixed3 albedo;      // base (diffuse or specular) color
    half metallic;      // 0=non-metal, 1=metal
    half smoothness;    // 0=rough, 1=smooth
};

struct Material
{
    vec3 albedo;
    vec3 specColor;
    float oneMinusReflectivity;
    float smoothness;
};

struct Light
{
    half3 color;
    half3 dir;
};

struct Indirect
{
    half3 diffuse;
    half3 specular;
};

const float4 dielectricSpec = float4(0.04, 0.04, 0.04, 1.0 - 0.04);

half OneMinusReflectivityFromMetallic(half metallic)
{
    half oneMinusDielectricSpec = dielectricSpec.a;
    return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
}

half3 DiffuseAndSpecularFromMetallic (half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)
{
    specColor = lerp (dielectricSpec.rgb, albedo, metallic);
    oneMinusReflectivity = OneMinusReflectivityFromMetallic(metallic);
    return albedo * oneMinusReflectivity;
}

Material toMaterial(MaterialMetallic i)
{
    Material o;
    
    o.albedo = i.albedo;
    o.smoothness = i.smoothness;
    
    half oneMinusReflectivity;
    half3 specColor;
    o.albedo = DiffuseAndSpecularFromMetallic (o.albedo, i.metallic, o.specColor, o.oneMinusReflectivity);
    
    return o;
}

float SmoothnessToPerceptualRoughness(float smoothness)
{
    return (1.0 - smoothness);
}

// Note: Disney diffuse must be multiply by diffuseAlbedo / PI. This is done outside of this function.
half DisneyDiffuse(half NdotV, half NdotL, half LdotH, half perceptualRoughness)
{
    half fd90 = 0.5 + 2.0 * LdotH * LdotH * perceptualRoughness;
    // Two schlick fresnel term
    half lightScatter   = (1.0 + (fd90 - 1.0) * Pow5(1.0 - NdotL));
    half viewScatter    = (1.0 + (fd90 - 1.0) * Pow5(1.0 - NdotV));

    return lightScatter * viewScatter;
}

float PerceptualRoughnessToRoughness(float perceptualRoughness)
{
    return perceptualRoughness * perceptualRoughness;
}

float SmithJointGGXVisibilityTerm (float NdotL, float NdotV, float roughness)
{
    // Original formulation:
    //  lambda_v    = (-1 + sqrt(a2 * (1 - NdotL2) / NdotL2 + 1)) * 0.5f;
    //  lambda_l    = (-1 + sqrt(a2 * (1 - NdotV2) / NdotV2 + 1)) * 0.5f;
    //  G           = 1 / (1 + lambda_v + lambda_l);

    // Reorder code to be more optimal
    half a          = roughness;
    half a2         = a * a;

    half lambdaV    = NdotL * sqrt((-NdotV * a2 + NdotV) * NdotV + a2);
    half lambdaL    = NdotV * sqrt((-NdotL * a2 + NdotL) * NdotL + a2);

    // Simplify visibility term: (2.0f * NdotL * NdotV) /  ((4.0f * NdotL * NdotV) * (lambda_v + lambda_l + 1e-5f));
    return 0.5f / (lambdaV + lambdaL + 1e-5f);  // This function is not intended to be running on Mobile,
                                                // therefore epsilon is smaller than can be represented by half
}

float GGXTerm (float NdotH, float roughness)
{
    float a2 = roughness * roughness;
    float d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
    return InvPi * a2 / (d * d + 1e-7f); // This function is not intended to be running on Mobile,
                                            // therefore epsilon is smaller than what can be represented by half
}

half3 FresnelTerm (half3 F0, half cosA)
{
    half t = Pow5 (1.0 - cosA);   // ala Schlick interpoliation
    return F0 + (1.0-F0) * t;
}

half3 FresnelLerp (half3 F0, half3 F90, half cosA)
{
    half t = Pow5 (1.0 - cosA);   // ala Schlick interpoliation
    return lerp (F0, F90, t);
}


half3 brdf (half3 albedo, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir,
    Light light, Indirect gi)
{
    float perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    float3 halfDir = safeNormalize(float3(light.dir) + viewDir);

    // The amount we shift the normal toward the view vector is defined by the dot product.
    half shiftAmount = dot(normal, viewDir);
    normal = shiftAmount < 0.0f ? normal + viewDir * (-shiftAmount + 1e-5f) : normal;
    normal = normalize(normal);

    float nv = saturate(dot(normal, viewDir)); // TODO: this saturate should no be necessary here

    float nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));

    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

    // Diffuse term
    half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl / 3.1415927;

    // Specular term
    float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
    
    // GGX with roughtness to 0 would mean no specular at all, using max(roughness, 0.002) here to match HDrenderloop roughtness remapping.
    roughness = max(roughness, 0.002);
    float V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    float D = GGXTerm (nh, roughness);

    float specularTerm = V*D; // Torrance-Sparrow model, Fresnel is applied later

    // specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
    specularTerm = max(0.0, specularTerm * nl);

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    half surfaceReduction;
    surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]

    // To provide true Lambert lighting, we need to be able to kill specular completely.
    //specularTerm *= (specColor != vec3(0)) ? 1.0 : 0.0;

    half grazingTerm = saturate(smoothness + (1.0-oneMinusReflectivity));
    half3 color =   albedo * (gi.diffuse + light.color * diffuseTerm)
                    + specularTerm * light.color * FresnelTerm (specColor, lh)
                    + surfaceReduction * gi.specular * FresnelLerp (specColor, vec3(grazingTerm), nv)
                    ;

    return half3(color);
}

vec3 lighting(MaterialMetallic mat, vec3 normal, vec3 viewDir, Light light, Indirect indirect)
{
    Material m = toMaterial(mat);
    
    return brdf(m.albedo, m.specColor, m.oneMinusReflectivity, m.smoothness,
    normal, viewDir, light, indirect);
}

// RAYTRACING -----------------------------
// Taken from https://www.shadertoy.com/view/MtcXWr
// Credit: Zavie

struct Ray
{
    vec3 origin;	
    vec3 direction;		
};

struct Hit
{
    float distance;
    vec3 normal;	
};
const Hit noHit = Hit(1e10, vec3(0.));

struct Plane
{
    float offset;
    vec3 normal;
};

struct Sphere
{
	float radius;
    vec3 center;
};

struct Cone
{
    float cosa;	// cosine of half cone angle
    float height;
    float thickness;
    vec3 origin;
    vec3 axis;
};

struct Capsule
{
    vec3 start;
    vec3 end;
    float startRadius;
    float endRadius;
};

struct HeightPlane
{
    mat4x4 localToWorld;
    vec2 uvOffset;
};

vec3 getPoint(in Ray r, float dist)
{
    return r.origin + r.direction * dist;
}

vec3 getPoint(in Ray r, in Hit hit)
{
    return r.origin + r.direction * hit.distance;
}

bool swapIfCloser(inout Hit current, Hit candidate)
{
    if (candidate.distance < current.distance && candidate.distance >= 0.0)
    {
        current = candidate;
        return true;
    }
    return false;
}

Hit intersectPlane(Plane plane, Ray ray)
{
    float dotnd = -dot(plane.normal, ray.direction);
    float heightAbovePlane = dot(ray.origin, plane.normal) - plane.offset;

    float t = heightAbovePlane / dotnd;
    //if(!(t >= 0.0))
    //    return noHit;
        
    return Hit(t, plane.normal * sign(dotnd));
}

Hit intersectSphere(Sphere sphere, Ray ray)
{
	vec3 op = sphere.center - ray.origin;
    float b = dot(op, ray.direction);
    float det = b * b - dot(op, op) + sphere.radius * sphere.radius;
    if (det < 0.) return noHit;

    det = sqrt(det);
    float t = b - det;
    if (t < 0.) t = b + det;
    if (t < 0.) return noHit;

    return Hit(t, (ray.origin + t*ray.direction - sphere.center) / sphere.radius);
}

Hit intersectCapsule(Capsule capsule, Ray ray)
{
    vec3 rayDirection = ray.direction;
    vec3 relativeOrigin = ray.origin - capsule.start;
    vec3 coneDirection = normalize(capsule.end - capsule.start);
    float coneLength = distance(capsule.end, capsule.start);
    float changeInRadiusWithLength = (capsule.endRadius - capsule.startRadius) / coneLength;
    float whatever = 1.0 - square(changeInRadiusWithLength);
    
    if(whatever <= 0.0)
    {
    	if(capsule.endRadius < capsule.startRadius)
    	{
    		Sphere s = Sphere(capsule.startRadius, capsule.start);
    		return intersectSphere(s, ray);    
        }
   		else
        {
            Sphere s = Sphere(capsule.endRadius, capsule.end);
            return intersectSphere(s, ray);   
        } 
    }
    
    float sideB = sqrt(whatever);
    float changeInThicknessWithLength = changeInRadiusWithLength / sideB;
    
    float radiusToThickness = changeInThicknessWithLength/changeInRadiusWithLength;
    float startThickness = capsule.startRadius * radiusToThickness;
    float endThickness = capsule.endRadius * radiusToThickness;
    
    if((coneLength+capsule.endRadius) < capsule.startRadius)
    {
    	Sphere s = Sphere(capsule.startRadius, capsule.start);
    	return intersectSphere(s, ray);    
    }
    if((coneLength+capsule.startRadius) < capsule.endRadius)
    {
    	Sphere s = Sphere(capsule.endRadius, capsule.end);
    	return intersectSphere(s, ray);    
    }
    
    float c = lengthSqr(relativeOrigin)
            - square(dot(relativeOrigin, coneDirection))
            - square(dot(relativeOrigin, coneDirection*changeInThicknessWithLength))
            - square(startThickness) 
            - 2.0*changeInThicknessWithLength*startThickness*dot(relativeOrigin, coneDirection);

    float b = 2.0*dot(relativeOrigin, rayDirection)
            - 2.0*dot(relativeOrigin, coneDirection)*dot(rayDirection, coneDirection)
            - 2.0*dot(relativeOrigin, coneDirection*changeInThicknessWithLength)*dot(rayDirection, coneDirection*changeInThicknessWithLength)
            - 2.0*changeInThicknessWithLength*startThickness*dot(rayDirection, coneDirection);

    float a = 1.0
            - square(dot(rayDirection, coneDirection))
            - square(dot(rayDirection, coneDirection*changeInThicknessWithLength));
        
    float det = b*b - 4.*a*c;
    if (det < 0.) return noHit;

    det = sqrt(det);
    float t1 = (-b - det) / (2. * a);
    float t2 = (-b + det) / (2. * a);

    float t = t1;
    if (t < 0. || t2 > 0. && t2 < t) t = t2;
    if (t < 0.) return noHit;
    
    vec3 relativeRayHit = ray.origin + t*ray.direction - capsule.start;
    float actualDistanceOfPointAlongAxis = dot(relativeRayHit, coneDirection);
    float distanceOfPointAlongAxis = actualDistanceOfPointAlongAxis;//square(fract(iTime * 0.25 / coneLength)) * coneLength;//dot(relativeRayHit, coneDirection);
    
    
    float thicknessAtPoint = distanceOfPointAlongAxis * changeInThicknessWithLength + startThickness;
    
    Hit hit1;
    
    if(actualDistanceOfPointAlongAxis < distanceOfPointAlongAxis)
    {
    	hit1 = Hit(t*0.25, vec3(1));    
    }
    else
    {
    	hit1 = Hit(t, vec3(-1));  
    }
    
    float distanceOfSphereAlongAxis = distanceOfPointAlongAxis + (thicknessAtPoint * changeInRadiusWithLength / sideB);
    
    distanceOfSphereAlongAxis = clamp(distanceOfSphereAlongAxis, 0.0, coneLength);

    float sphereRadius = distanceOfSphereAlongAxis * changeInRadiusWithLength + capsule.startRadius;

    Sphere s = Sphere(sphereRadius, capsule.start + coneDirection * distanceOfSphereAlongAxis);
    
    Hit hit2 = intersectSphere(s, ray);
    hit2.distance *= 0.5;
    swapIfCloser(hit1, hit2);
    
    return hit2;
}

Hit intersectHeightPlane(HeightPlane plane, Ray ray, sampler2D heightMap, vec2 heightMapSize)
{
    Ray origRay = ray;
    mat4x4 worldToLocal = inverse(plane.localToWorld);

    ray.origin = (worldToLocal * vec4(ray.origin, 1)).xyz; 
    ray.direction = normalize((worldToLocal * vec4(ray.direction, 0)).xyz); 

    Plane maxPlane = Plane(-1.0, vec3(0,0,1));
    Plane minPlane = Plane( 0.0, vec3(0,0,1));
    
    Hit maxHit = intersectPlane(maxPlane, ray);
    Hit minHit = intersectPlane(minPlane, ray);
    
    
    //if(maxHit == noHit || minHit == noHit)
    //    return noHit;
    
    float nearDist = min(minHit.distance, maxHit.distance);
    float farDist  = max(minHit.distance, maxHit.distance);
    
    if(farDist < 0.0)
        return noHit;
        
    if(nearDist < 0.0)
        nearDist = 0.0;
        
    //return maxHit;
    
    //vec3 nearHit = ray.origin + ray.direction * nearDist;
    //vec3 farHit = ray.origin + ray.direction * farDist;
    
    vec3 hitPos;
    
    
    bool hit = false;
    float increment = max(0.00001, 0.0001 / abs(nearDist-farDist));
    for(float i = 0.0; i <= 1.0; i += increment)
    {
        float marchDist = mix(nearDist, farDist, i);
        hitPos = ray.origin + ray.direction * marchDist;
        
        vec2 uv = hitPos.xy;
        float depth = textureLod(heightMap, uv + plane.uvOffset, 0.0).r*1.0 - 1.0;
        
        if(hitPos.z <= depth)
        {
            hitPos.z = depth;
            farDist = marchDist;
            hit = true;
            break;
        }
        else
        {
            nearDist = marchDist;
        }
    }
    
    if(!hit) return noHit;
    
    farDist = (nearDist + farDist) * 0.5;
    float stepSize = (farDist - nearDist) * 0.5;
    for(int i = 0; i < 12; i++, stepSize *= 0.5)
    {
        hitPos = ray.origin + ray.direction * farDist;
        
        vec2 uv = hitPos.xy;
        float depth = textureLod(heightMap, uv + plane.uvOffset, 0.0).r - 1.0;
        
        if(hitPos.z > depth)
        {
            nearDist = farDist;
            farDist += stepSize;
        }
        else
        {
            hitPos.z = depth;
            farDist -= stepSize;
        }
    }
    
    ray = origRay;
    
    const float sampleSpacing = 0.5;
    vec4 uvOffset = vec4(-sampleSpacing, -sampleSpacing, sampleSpacing, sampleSpacing) / heightMapSize.xyxy;
    
    vec3 p00, p10, p01, p11;
    p00 = vec3(hitPos.xy + uvOffset.xy, 0);
    p10 = vec3(hitPos.xy + uvOffset.zy, 0);
    p01 = vec3(hitPos.xy + uvOffset.xw, 0);
    p11 = vec3(hitPos.xy + uvOffset.zw, 0);
    
    p00.z = textureLod(heightMap, p00.xy + plane.uvOffset, 0.0).r - 1.0;
    p10.z = textureLod(heightMap, p10.xy + plane.uvOffset, 0.0).r - 1.0;
    p01.z = textureLod(heightMap, p01.xy + plane.uvOffset, 0.0).r - 1.0;
    p11.z = textureLod(heightMap, p11.xy + plane.uvOffset, 0.0).r - 1.0;
    
    p00 = (plane.localToWorld * vec4(p00, 1)).xyz;
    p10 = (plane.localToWorld * vec4(p10, 1)).xyz;
    p01 = (plane.localToWorld * vec4(p01, 1)).xyz;
    p11 = (plane.localToWorld * vec4(p11, 1)).xyz;
    
    Hit outHit;
    outHit.normal = cross(p11 - p00, p01 - p10);
    
    hitPos = (plane.localToWorld * vec4(hitPos, 1)).xyz; 
    outHit.normal = normalize(outHit.normal);
    outHit.distance = dot(hitPos - ray.origin, ray.direction);
    
    return outHit;
}

vec2[4] getMSAACoords()
{
    float o1 = 0.25;
    float o2 = 0.75;
    vec2 msaa[4];
    msaa[0] = vec2( o1,  o2);
    msaa[1] = vec2( o2, -o1);
    msaa[2] = vec2(-o1, -o2);
    msaa[3] = vec2(-o2,  o1);
    return msaa;
}

Ray uvToRay(vec2 uv, float aspect, float zoom, vec2 offset)
{
    uv = uv * vec2(2.0) - 1.0;
    uv.x *= aspect;
    uv += offset;
    return Ray(vec3(0), normalize(vec3(uv,zoom)));
}

#define render(color, scene, camtf, frag, res, zoom, msaa, count, data)\
{\
    color = vec3(0.);\
    vec2 r = res;\
    vec2 f = frag;\
    vec2 uv = f / r;\
    const int c = count;\
    vec2[c] m = msaa;\
    float weight = 1.0 / float(c);\
    for (int i = 0; i < c; ++i)\
    {\
        Ray r = uvToRay\
        (\
            uv,\
            r.x/r.y,\
            zoom,\
            m[i] / r.y\
        );\
        r = camtf(r,f,data);\
        color += scene(r,f,data);\
    }\
    color *= weight;\
}
