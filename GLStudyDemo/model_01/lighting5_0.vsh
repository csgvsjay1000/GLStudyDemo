attribute vec3 position;
attribute vec2 inputTextureCoordinate;
attribute vec3 normalLocal;

varying vec2 textureCoordinate;
varying vec3 Normal;
varying vec3 FragPos;

uniform highp mat4 model;
uniform highp mat4 view;
uniform highp mat4 projection;


void main()
{
    gl_Position =  projection*view*model  * vec4(position,1.0);
    Normal = normalLocal;
    FragPos = vec3(model*vec4(position,1.0));

    textureCoordinate = inputTextureCoordinate;
    
}