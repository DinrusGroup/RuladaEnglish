// simple toon vertex shader
// www.lighthouse3d.com


varying vec3 normal, lightDir;
varying vec4 vcolor;

void main()
{   
    lightDir = normalize(vec3(gl_LightSource[0].position));
    normal = normalize(gl_NormalMatrix * gl_Normal);
        
    gl_Position = ftransform();
    vcolor = gl_Color;
}
