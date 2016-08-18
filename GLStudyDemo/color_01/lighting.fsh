
uniform highp vec3 objectColor;
uniform highp vec3 lightColor;

void main()
{
    
    highp float ambientStrength = 0.1;   //环境因子
    highp vec3 ambient = ambientStrength * lightColor;
    highp vec3 result = ambient * objectColor;
    
    gl_FragColor = vec4(result,1.0);
}