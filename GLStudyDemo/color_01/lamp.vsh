attribute vec3 position;

uniform highp mat4 model;
uniform highp mat4 view;
uniform highp mat4 projection;


void main()
{
    gl_Position = projection*view*model * vec4(position,1.0);
}