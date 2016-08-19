
varying highp vec3 Normal;
varying highp vec3 FragPos;

uniform highp vec3 lightPos;
uniform highp vec3 viewPos;

uniform highp vec3 objectColor;
uniform highp vec3 lightColor;



void main()
{
    
    // Ambient  环境光
    highp float ambientStrength = 0.1;   //环境因子
    highp vec3 ambient = ambientStrength * lightColor;
//    highp vec3 result = ambient * objectColor;
    
    // Diffuse  漫反射
    highp vec3 norm = normalize(Normal);
    highp vec3 lightDir = normalize(lightPos - FragPos);
    highp float diff = max(dot(norm, lightDir), 0.0);
    highp vec3 diffuse = diff * lightColor;
//    highp vec3 result = (ambient + diffuse) * objectColor;
    
    // Specular 镜面反射
    highp float specularStrength = 0.5;
    highp vec3 viewDir = normalize(viewPos - FragPos);
    highp vec3 reflectDir = reflect(-lightDir, norm);
    highp float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
    highp vec3 specular = specularStrength * spec * lightColor;
    
    highp vec3 result = (ambient + diffuse + specular) * objectColor;
    
    gl_FragColor = vec4(result,1.0);
}