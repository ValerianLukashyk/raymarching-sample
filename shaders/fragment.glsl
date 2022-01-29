uniform float time;
uniform vec2 mouse;
uniform sampler2D matcap,matcap2;
uniform vec4 resolution;
varying vec2 vUv;

float PI=3.141592653589793238;

mat4 rotationMatrix(vec3 axis,float angle){
    axis=normalize(axis);
    float s=sin(angle);
    float c=cos(angle);
    float oc=1.-c;
    
    return mat4(oc*axis.x*axis.x+c,oc*axis.x*axis.y-axis.z*s,oc*axis.z*axis.x+axis.y*s,0.,
        oc*axis.x*axis.y+axis.z*s,oc*axis.y*axis.y+c,oc*axis.y*axis.z-axis.x*s,0.,
        oc*axis.z*axis.x-axis.y*s,oc*axis.y*axis.z+axis.x*s,oc*axis.z*axis.z+c,0.,
    0.,0.,0.,1.);
}

vec2 getmatcap(vec3 eye,vec3 normal){
    vec3 reflected=reflect(eye,normal);
    float m=2.8284271247461903*sqrt(reflected.z+1.);
    return reflected.xy/m+.5;
}

vec3 rotate(vec3 v,vec3 axis,float angle){
    mat4 m=rotationMatrix(axis,angle);
    return(m*vec4(v,1.)).xyz;
}
float smin(float a,float b,float k){
    float h=clamp(.5+.5*(b-a)/k,0.,1.);
    return mix(b,a,h)-k*h*(1.-h);
}
float sdSphere(vec3 p,float r){
    return length(p)-r;
}
float sdBox(vec3 p,vec3 b){
    vec3 q=abs(p)-b;
    return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.);
}

float sdf(vec3 p){
    vec3 p1=rotate(p,vec3(1.),time/5.);
    
    float box=smin(sdBox(p1,vec3(.25)),sdSphere(p,.25),.25);
    float sphere=sdSphere(p-vec3(mouse*2.,0.),.25);
    
    return smin(box,sphere,.25);
}

vec3 calcNormal(in vec3 p){
    const float eps=.0001;
    const vec2 h=vec2(eps,0);
    return normalize(vec3(sdf(p+h.xyy)-sdf(p-h.xyy),
    sdf(p+h.yxy)-sdf(p-h.yxy),
    sdf(p+h.yyx)-sdf(p-h.yyx)
));
}

void main(){
float dist=length(vUv-vec2(.5))*1.25;
vec3 bg=mix(vec3(.3),vec3(0.),dist);
vec2 newUV=(vUv-vec2(.5))*resolution.zw+vec2(.5);

vec3 camPos=vec3(0.,0.,2.);
vec3 ray=normalize(vec3((vUv-vec2(.5))*resolution.zw,-1));

vec3 rayPos=camPos;
float t=0.;
float tMax=5.;

for(int i=0;i<256;++i){
    vec3 pos=camPos+t*ray;
    float h=sdf(pos);
    if(h<.0001||t>tMax)break;
    t+=h;
}

vec3 color=bg;
if(t<tMax){
    vec3 pos=camPos+t*ray;
    color=vec3(1.);
    vec3 normal=calcNormal(pos);
    color=normal;
    float diff=dot(vec3(1.),normal);
    vec2 matcapUV=getmatcap(ray,normal);
    color=vec3(diff);
    // color=vec3(matcapUV,0.);
    color=texture2D(matcap2,matcapUV).rgb;
    
    float fresnel=pow(1.+dot(ray,normal),3.);
    // color=vec3(fresnel);
    color=mix(color,bg,fresnel);
}

gl_FragColor=vec4(color,1.);

}