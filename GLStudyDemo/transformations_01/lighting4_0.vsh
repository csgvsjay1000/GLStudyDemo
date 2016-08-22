attribute vec3 position;
attribute vec2 inputTextureCoordinate;

varying vec2 textureCoordinate;

uniform highp mat4 transform;
uniform highp mat4 model;
uniform highp mat4 view;
uniform highp mat4 projection;


void main()
{
    gl_Position =  projection*view*model  * vec4(position,1.0);
    
    textureCoordinate = inputTextureCoordinate;

}