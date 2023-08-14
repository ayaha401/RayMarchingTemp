#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))

const float PI=3.1415926536;
const float TAU=PI*2.;
const float eps=0.0001;
const float DEG2RAD = PI/180.;

float sdSphere(vec3 p,float r)
{
    return length(p)-r;
}

float map(vec3 p)
{
    return sdSphere(p,.5);
}

vec3 makeN(vec3 p)
{
    vec2 eps = vec2(.0001, 0.);
    return normalize(vec3(map(p+eps.xyy)-map(p-eps.xyy),
                          map(p+eps.yxy)-map(p-eps.yxy),
                          map(p+eps.yyx)-map(p-eps.yyx)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv=(2.*fragCoord.xy-iResolution.xy)/iResolution.y;

    float dist, hit, i = 0.;
    vec3 cPos = vec3(0., 0., 5.);
    vec3 cDir = normalize(vec3(0., 0., -1.));
    vec3 cUp = vec3(0., 1., 0.);
    vec3 cSide = cross(cDir, cUp);
    vec3 ray = normalize(cSide*uv.x+cUp*uv.y+cDir); 
    vec3 L = normalize(vec3(1));
    vec3 col=vec3(0);
    
    for(;i<64.;i++)
    {
        vec3 rp=cPos+ray*hit;
        dist=map(rp);
        hit+=dist;
        if(dist<eps)
        {
            vec3 N=makeN(rp);
            float diff=dot(N,L);
            col=vec3(1)*diff;
        }
    }
    
    fragColor = vec4(col,1.);
}
