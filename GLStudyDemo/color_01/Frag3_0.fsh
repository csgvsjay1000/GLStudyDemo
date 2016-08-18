varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

uniform highp vec2 center;
//uniform highp float radius;
uniform highp float aspectRatio;
//uniform highp float refractiveIndex;
uniform highp float fs;
uniform highp float fx;

const highp vec3 lightPosition = vec3(-0.5, 0.5, 1.0);
const highp vec3 ambientLightPosition = vec3(0.0, 0.0, 1.0);

void main()
{
    
    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
}