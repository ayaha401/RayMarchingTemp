#version 150

uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;
uniform vec3 spectrum;

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform sampler2D prevFrame;
uniform sampler2D prevPass;

in VertexData
{
    vec4 v_position;
    vec3 v_normal;
    vec2 v_texcoord;
} inData;

out vec4 fragColor;
//define=============================================================================
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))

//const==============================================================================
const float PI=3.1415926536;
const float TAU=PI*2;
const float eps=0.0001;
const float DEG2RAD = PI/180;

//Math===============================================================================

float bevel(float x)
{
    return max(.1,abs(x));
}

float bevelMax(float a,float b)
{
    return (a+b+bevel(a-b))*.5;
}

vec2 pmod(vec2 p,float n)
{
    float a=mod(atan(p.y,p.x),TAU/n)-.5*TAU/n;
    return length(p)*vec2(sin(a),cos(a));
}

vec3 rep(vec3 p,float n)
{
    return abs(mod(p,n))-n*.5;
}

float remap(float val, vec2 inMinMax, vec2 outMinMax)
{
    return clamp(outMinMax.x+(val-inMinMax.x)*(outMinMax.y-outMinMax.x)/(inMinMax.y-inMinMax.x), outMinMax.x, outMinMax.y);
}

//SDF================================================================================

float sdSphere(vec3 p,float r)
{
    return length(p)-r;
}

float sdBox(vec3 p,vec3 s)
{
    vec3 q=abs(p)-s;
    return length(max(q,0))+min(max(max(q.y,q.z),q.x),0);
}

//Map================================================================================

float map(vec3 p)
{
    return sdSphere(p,.5);
}

//Normal=============================================================================

vec3 makeN(vec3 p)
{
    vec2 eps = vec2(.0001, 0.);
    return normalize(vec3(map(p+eps.xyy)-map(p-eps.xyy),
                          map(p+eps.yxy)-map(p-eps.yxy),
                          map(p+eps.yyx)-map(p-eps.yyx)));
}


//Main==============================================================================

void main(void)
{
    vec2 uv=(2.*gl_FragCoord.xy-resolution)/resolution.y;
    float dist,hit,i=0;
    vec3 ro=vec3(0,0,5.),
         rd=normalize(vec3(uv,-1)),
         rp=ro+rd*dist,
         col=vec3(0),
         L=normalize(vec3(1));
    for(;i<64;i++)
    {
        dist=map(rp);
        hit+=dist;
        rp=ro+rd*hit;
        if(dist<eps)
        {
            vec3 N=makeN(rp);
            float diff=dot(N,L);
            col=vec3(1)*diff;
        }
    }
    fragColor = vec4(col,1.);
}
