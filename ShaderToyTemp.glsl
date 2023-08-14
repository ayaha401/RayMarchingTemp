// https://www.shadertoy.com/view/WslGWl
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))

const float PI=3.1415926536;
const float TAU=PI*2.;
const float eps=0.01;
const float DEG2RAD = PI/180.;

mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64);

float hash(float n)
{
    return fract(sin(n) * 43758.5453);
}

float noise(in vec3 x)
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f * f * (3.0 - 2.0 * f);

    float n = p.x + p.y * 57.0 + 113.0 * p.z;

    float res = mix(mix(mix(hash(n +   0.0), hash(n +   1.0), f.x),
                        mix(hash(n +  57.0), hash(n +  58.0), f.x), f.y),
                    mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
                        mix(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
    return res;
}

float fbm(vec3 p)
{
    float f;
    f  = 0.5000 * noise(p); p = m * p * 2.02;
    f += 0.2500 * noise(p); p = m * p * 2.03;
    f += 0.1250 * noise(p);
    return f;
}

float sphere(vec3 p, float r)
{
    return length(p) - r;
}

float chain(vec3 p, vec3 s)
{
    p.x-=clamp(p.x, -s.x, s.x);
    return length(vec2(length(p.xy)-s.y,p.z))-s.z;
}

float map(vec3 p)
{
    p.xy *= rot(iTime);
    p.xz *= rot(iTime);
    
    float d0 = -sphere(p, 10.5) * 0.05 + fbm(p * 0.3);
    float d1 = -chain(p, vec3(15.5, 13.2, .1)) * 0.05 + fbm(p * 0.3);
    float d = mix(d1, d0, max(0., sin(iTime)));
    
    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv=(2.*fragCoord.xy-iResolution.xy)/iResolution.y;

    float dist, hit, i = 0.;
    vec3 cPos = vec3(0., 0., 35.);
    vec3 cDir = normalize(vec3(0., 0., -1.));
    vec3 cUp = vec3(0., 1., 0.);
    vec3 cSide = cross(cDir, cUp);
    vec3 ray = normalize(cSide * uv.x + cUp * uv.y + cDir); 
    vec3 L = normalize(vec3(1));
    vec3 col=vec3(0);
    float sampleCount = 64.0;
    float zMax = 65.0;
    float zStep = zMax / sampleCount;
    // Substantially transparency parameter.
    float absorption = 100.0;
    // Transmittance
    float T = 1.0;
    
    for(;i<64.;i++)
    {
        vec3 rp = cPos + ray * hit;
        dist=map(rp);
        hit+=zStep;
        if(dist > eps)
        {
            float tmp = dist / sampleCount;
            T *= 1.0 - (tmp * absorption);
            if (T <= 0.01)
            {
                break;
            }
            float opaity = 50.0;
            float k = opaity * tmp * T;
            vec3 cloudColor = vec3(1.0);
            col += cloudColor * k;
        }
    }
    vec3 bg = mix(vec3(0.3, 0.1, 0.8), vec3(0.7, 0.7, 1.0), 1.0 - (uv.y + 1.0) * 0.5);
    col += bg;
    fragColor = vec4(col,1.);
}
