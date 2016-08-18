attribute vec3 position;
attribute vec3 normalLocal;

varying vec3 Normal;
varying vec3 FragPos;

uniform highp mat4 model;
uniform highp mat4 view;
uniform highp mat4 projection;


void main()
{
    gl_Position = projection*view*model * vec4(position,1.0);
    FragPos = vec3(model*vec4(position,1.0));
    Normal = normalLocal;
}