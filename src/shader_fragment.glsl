#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

in vec3 interpolated_color;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define PLANE 0
#define COW 1
#define CACTUS 2
uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
uniform sampler2D TextureImage2;

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec3 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

void main()
{
    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);

    // Fonte de luz direcional
    vec4 l = normalize(vec4(-1.0,1.0,0.0,0.0));
    
    vec3 I = vec3(1.0, 1.0, 1.0);

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    // if ( object_id == 5 )
    // {
    //     vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

    //     vec4 vec_p = (position_model - bbox_center) / length(position_model - bbox_center);

    //     float theta = atan(vec_p.x, vec_p.z);
    //     float phi = asin(vec_p.y);

    //     U = (theta + M_PI) / (2 * M_PI);
    //     V = (phi + M_PI_2) / M_PI;
    // }
    if ( object_id == COW)
    {
        vec3 Kd = vec3(0.35, 0.27, 0.16);

        vec3 Ka = Kd;
        vec3 Ia = vec3(0.3, 0.3, 0.3);

        vec3 Ks = vec3(0.5, 0.5, 0.5);
        float q = 150.0;

        vec4 h = normalize(v + l);

        vec3 lambert = Kd*I*max(0, dot(n,l));
        vec3 ambient = Ka*Ia;
        vec3 blinn_phong = Ks*I*pow(max(0, dot(n, h)), q);

        color = lambert + ambient + blinn_phong;
    }
    else if ( object_id == PLANE )
    {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;

        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage0
        vec3 Kd = texture(TextureImage0, vec2(U,V)).rgb;

        color = Kd*I*max(0,dot(n,l));

        // Cor final com correção gamma, considerando monitor sRGB.
        // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
        color = pow(color, vec3(1.0,1.0,1.0)/2.2);
    }
    else if (object_id == CACTUS ) {
        // Modelo de interpolação de Gourad
        color = interpolated_color;
    }
} 