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

struct VertexInputType
{
	float4 position : POSITION;
	float4 color : COLOR;
	float3 normal : NORMAL;
	float2 tex : TEXCOORD0;
	float3 tangent : TANGENT;
};

struct PixelInputType
{
	float4 position : SV_Position;
	float4 color : COLOR0;
	float3 normal : NORMAL;
	float3 tangent : TANGENT;
	float2 tex : TEXCOORD0;
	
	float3 viewDirInTang:TEXCOORD1;
	float3 lightDirInTang : TEXCOORD2;
};

//PixelInputType NormalMapVertexShader(VertexInputType input)
//{
//	PixelInputType output = (PixelInputType) 0;
	
//	// Change the position vector to be 4 units for proper matrix calculations.
//	input.position.w = 1.0f;
	
//	// Calculate the position of the vertex against the world, view, and projection matrices.
//	output.position = mul(input.position, worldMatrix);
//    output.position = mul(output.position, viewMatrix);
//    output.position = mul(output.position, projectionMatrix);
	
//	// Store the vertex color for the pixel shader.
//	output.color = input.color;
	
//	// Store the texture coordinates for the pixel shader.
//	output.tex = input.tex;
		
//	// Calculate the normal vector against the world matrix only and then normalize the final value.
//    output.normal = mul(input.normal, (float3x3) worldMatrix);
//    output.normal = normalize(output.normal);
	
//    // Calculate the tangent vector against the world matrix only and then normalize the final value.
//    output.tangent = mul(input.tangent, (float3x3) worldMatrix);
//    output.tangent = normalize(output.tangent);
	
//	return output;
//}


PixelInputType NormalMapVertexShader(VertexInputType input)
{
    PixelInputType output = (PixelInputType) 0;
	
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

// Given a local normal, transform it into a tangent space given by surface normal and tangent
float3 calNormal(float3 localNormal, float3 surfaceNormalWS, float3 surfaceTangentWS)
{
    float3 normal = normalize(surfaceNormalWS);
    float3 tangent = normalize(surfaceTangentWS);
    float3 binormal = cross(normal, tangent); // reconstructed from normal & tangent
	
    float3x3 TBN = { tangent, binormal, normal }; // world "frame" for local normal 

    return mul(localNormal, TBN); // transform to local to world (tangent space)
}

// This function converts the R and G channels from a normal texture map
// Assumes the input data is "UNORM" (i.e. needs a x2 bias to get back -1..1)
// Also reconstructs the B channel in case the normal map was compressed as BC5_UNORM
float3 TwoChannelNormalX2(float2 normal)
{
    float2 xy = 2.0 * normal - 1.0f;
	float z = sqrt(1 - dot(xy, xy));
    return float3(xy.x, xy.y, z);
}

float4 NormalMapPixelShader(PixelInputType input) : SV_TARGET
{
	float4 finalColor;
	float4 textureColor = shaderTextures[0].Sample(txSamplerState, input.tex);
	
	float4 bumpMap = shaderTextures[1].Sample(txSamplerState, input.tex);
    float3 N = normalize(2.0 * bumpMap.xyz - 1.0);
	
    float3 L = normalize(input.lightDirInTang);
    float diffuse = max(0.0, dot(L, N));
    finalColor = diffuse * textureColor * lightColor[0];
	
	
	
    
    float3 R = normalize(reflect(-L, N));
    float V = normalize(input.viewDirInTang);
    float spec = max(0.0, dot(V, R));
    spec = pow(spec, 100);
    float4 specCol = spec * textureColor * lightColor[1];
    finalColor += specCol;

	
    return finalColor;
}