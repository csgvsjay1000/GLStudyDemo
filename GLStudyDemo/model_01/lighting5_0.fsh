
varying highp vec2 textureCoordinate;
varying highp vec3 Normal;
varying highp vec3 FragPos;

uniform sampler2D inputImageTexture;
uniform highp vec3 lightPos;

uniform highp vec3 objectColor;
uniform highp vec3 lightColor;

void main(){
    
    
//    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
    // Diffuse  漫反射
    highp vec3 norm = normalize(Normal);
    highp vec3 lightDir = normalize(lightPos - FragPos);
    highp float diff = max(dot(norm, lightDir), 0.0);
    highp vec3 diffuse = diff * lightColor;
    highp vec3 result = (diffuse) * objectColor;
    
    gl_FragColor = vec4(result,1.0);
    
}