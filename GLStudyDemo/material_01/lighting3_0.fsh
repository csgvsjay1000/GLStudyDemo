
struct Material {
    highp vec3 ambient;
    highp vec3 diffuse;
    highp vec3 specular;
    highp float shininess;
};

struct Light {
    highp vec3 position;
    
    highp vec3 ambient;
    highp vec3 diffuse;
    highp vec3 specular;
};

varying highp vec3 Normal;
varying highp vec3 FragPos;

uniform highp vec3 viewPos;

uniform Material material;
uniform Light light;

void main(){
    
    highp vec3 ambient = light.ambient * material.ambient;
    
    // Diffuse
    highp vec3 norm = normalize(Normal);
    highp vec3 lightDir = normalize(light.position - FragPos);
    highp float diff = max(dot(norm, lightDir), 0.0);
    highp vec3 diffuse = light.diffuse * (diff * material.diffuse);
    
    // Specular
    highp vec3 viewDir = normalize(viewPos - FragPos);
    highp vec3 reflectDir = reflect(-lightDir, norm);
    highp float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    highp vec3 specular = light.specular * (spec * material.specular);
    
    highp vec3 result = ambient + diffuse + specular;
    
    gl_FragColor = vec4(result,1.0);

}


