Texture2D shaderTextures[2];
SamplerState txSamplerState;

cbuffer ConstantBuffer : register(b0)
{
	matrix worldMatrix;
	matrix viewMatrix;
	matrix projectionMatrix;
}

cbuffer LightBuffer : register(b1)
{
    float4 lightDirection[2];
    float4 lightColor[2];
	
}

struct VS_INPUT
{
	float4 position : POSITION;
	float4 color : COLOR;
	float3 normal : NORMAL;
	float2 tex : TEXCOORD0;
	float3 tangent : TANGENT;
};

struct PS_INPUT
{
	float4 position : SV_Position;
	float4 color : COLOR0;
	float2 tex : TEXCOORD0;
	float3 viewDirInTang:TEXCOORD1;
	float3 lightDirInTang : TEXCOORD2;
};

PS_INPUT VS(VS_INPUT input)
{
    PS_INPUT output = (PS_INPUT) 0;
	
	// Change the position vector to be 4 units for proper matrix calculations.
    input.position.w = 1.0f;
	
	// Calculate the position of the vertex against the world, view, and projection matrices.
    output.position = mul(input.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
	
	// Store the vertex color for the pixel shader.
    output.color = input.color;
	
	// Store the texture coordinates for the pixel shader.
    output.tex = input.tex;
	
    float3 viewDirW = lightDirection[1].xyz - input.position.xyz;
	float3 lightDirW = lightDirection[0] - input.position; 
	
    float3 N = normalize(input.normal);
    float3 T = normalize(input.tangent);
    float3 B = normalize(cross(N, T));
 
    float3x3 mat2Tang = float3x3(T, B, N);
 
    output.viewDirInTang = mul(mat2Tang, viewDirW);
    output.lightDirInTang = mul(mat2Tang, lightDirW);

    return output;
}

static const float radius = 0.6;

float3 bumpNormal(float2 xy)
{
    float3 N = float3(0.0, 0.0, 1.0);
    
    //map xy to [-1, 1]x[-1, 1]:
    
    float2 st = 2.0 * frac(xy) - 1.0;
    float r2 = radius * radius - dot(st, st);
    
        if (r2 > 0.0)
    {
        N.xy = st / sqrt(r2);
    }
    return normalize(N);
}

float2 rayMarching(float2 startTexCoord, float3 viewDir)
{
    float3 invertedView = -viewDir;
    float stepSize = 0.001;
    
    float maxBumpHeight = 1.0;
    float3 P0 = float3(startTexCoord, maxBumpHeight);
    float H0 = maxBumpHeight * shaderTextures[1].Sample(txSamplerState, P0.xy).r;
    
    for (int i = 0; i < 60; i++)
    {
        if(P0.z > H0)
        {
            P0 += stepSize * invertedView;
            H0 = maxBumpHeight * shaderTextures[1].Sample(txSamplerState, P0.xy).r;
        } 
        else
        {
            break;
        }
    }
        return P0.xy;
}



float4 PS(PS_INPUT input) : SV_TARGET
{
	float4 finalColor;
	
    float4 textureColor = shaderTextures[0].Sample(txSamplerState, input.tex);
    float4 bumpMap = shaderTextures[1].Sample(txSamplerState, input.tex);

    // Parallax mapping
    float H = bumpMap.r;
    float scale = 1.0;
    float bias0 = 1.0;
    H = scale * H - bias0;
    float2 texCorrected = rayMarching(input.tex, normalize(input.viewDirInTang));
    textureColor = shaderTextures[0].Sample(txSamplerState, texCorrected);
    bumpMap = shaderTextures[1].Sample(txSamplerState, texCorrected);
    float3 N = 2.0 - bumpMap.xyz - 1.0;
    
    
    
    
    
    
    
	
	// Normal mapping
    // float3 N = normalize(2.0 * bumpMap.xyz - 1.0);
	
	// Height mapping
    // float H = bumpMap.r;
    // float dx = ddx(H);
    // float dy = ddy(H);
    // float N = normalize(float3(-dx, -dy, 0.4));
	
	// Procedural mapping
	// float BumpDensity = 5.5;
    // float2 xy = float2(BumpDensity * input.tex.x, BumpDensity * input.tex.y);
    // float3 N = bumpNormal(xy);
	
	// Diffuse light
    float3 L = normalize(input.lightDirInTang);
    float diffuse = max(0.0, dot(L, N));
    finalColor = diffuse * textureColor * lightColor[0];
	
    // Specular light
    float3 R = normalize(reflect(-L, N));
    float V = normalize(input.viewDirInTang);
    float spec = max(0.0, dot(V, R));
    spec = pow(spec, 100);
    float4 specCol = spec * textureColor * lightColor[1];
    finalColor += specCol;

	
    return finalColor;
}