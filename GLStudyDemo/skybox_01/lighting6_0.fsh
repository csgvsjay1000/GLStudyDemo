
varying highp vec3 textureCoordinate;

uniform samplerCube inputImageTexture;

void main(){
    
    
    gl_FragColor = textureCube(inputImageTexture, textureCoordinate);

    
}