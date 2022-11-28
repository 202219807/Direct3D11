//--------------------------------------------------------------------------------------
// File: Tutorial04.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------

cbuffer ConstantBuffer : register(b0)
{
    matrix World;
    matrix View;
    matrix Projection;
}

Texture2D tx0 : register(t0);
Texture2D tx1 : register(t1);

SamplerState txSampler : register(s0);
SamplerState txSampler1 : register(s1);

//--------------------------------------------------------------------------------------
struct VS_INPUT
{
    float4 Pos : POSITION;
    float4 Color : COLOR;
    float3 Normal : NORMAL;
    float2 TexCoord : TEXCOORD;
};

struct VS_OUTPUT
{
    float4 Pos : SV_POSITION;
    float2 Tex : TEXCOORD0;
    float3 Nor : TEXCOORD1;
    float3 PixelPos : TEXCOORD2;
    float4 Col : COLOR0;
};

float time;
//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
VS_OUTPUT VS(VS_INPUT input)
{
    VS_OUTPUT output = (VS_OUTPUT) 0;
    
    // float3 inPos = input.Pos.xyz;
    
    output.PixelPos = input.Pos.xyz;
    output.Tex = input.TexCoord;
    
    // Position
    float4x4 ModelViewProjectionMatrix = mul(mul(World, View), Projection);
    output.Pos = mul(input.Pos, ModelViewProjectionMatrix);
    
    // output.Pos = mul(inPos, World);
    // output.Pos = mul(output.Pos, View);
    // output.Pos = mul(output.Pos, Projection);
    
    // Normal
    output.Nor = mul(float4(input.Normal, 1), World);
    // output.Nor = input.Normal;
    
    // Vertex color
    // output.Col = input.Col;

    return output;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS(VS_OUTPUT input) : SV_Target
{
    float4 finalColor = 0;
    
    // Texture -- Bump/Normal Mapping
    float heightScale = 20;
    float4 bumpMap = tx1.Sample(txSampler, input.Tex).r;
    float3 normalMap = heightScale * bumpMap;
    
    // Update pixel position
    float3 inPos = input.PixelPos.xyz;
    inPos.z += normalMap * input.Nor;
    
    float4 matCol = tx0.Sample(txSampler, input.Tex);
    float4 lightCol = float4(1.0, 1.0, 1.0, 0.1);
    float3 L = float3(1.0f, 1.0f, -1.0f);
    float3 N = normalize(normalMap + input.Nor);
    float diff = max(0.0, dot(L, N));
    finalColor = matCol * lightCol * diff;
    
    // Specular light
    float3 eyePos = float3(0.0f, 2.0f, -8.0f);
    float3 R = normalize(reflect(-L, N));
    float V = normalize(eyePos - inPos.xyz);
    float spec = max(0.0, dot(V, R));
    spec = pow(spec, 100);
    float4 specCol = matCol * lightCol * spec;
    
    finalColor += specCol;
    finalColor.a = 1;
    return finalColor;
}
