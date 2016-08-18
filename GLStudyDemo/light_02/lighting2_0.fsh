
varying highp vec3 Normal;
varying highp vec3 FragPos;

uniform highp vec3 lightPos;
uniform highp vec3 objectColor;
uniform highp vec3 lightColor;

void main()
{
    
    // Ambient
    highp float ambientStrength = 0.1;   //环境因子
    highp vec3 ambient = ambientStrength * lightColor;
//    highp vec3 result = ambient * objectColor;
    
    // Diffuse
    highp vec3 norm = normalize(Normal);
    highp vec3 lightDir = normalize(lightPos - FragPos);
    highp float diff = max(dot(norm, lightDir), 0.0);
    highp vec3 diffuse = diff * lightColor;
    
    highp vec3 result = (ambient + diffuse) * objectColor;
    
    gl_FragColor = vec4(result,1.0);
}