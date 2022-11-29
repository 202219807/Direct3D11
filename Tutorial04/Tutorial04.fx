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
    float3 PxPos : TEXCOORD2;
    float4 Col : COLOR0;
};

static const float radius = 2.0;

float3 bumpNormal(float2 xy)
{
    float3 N = float3(0.0, 0.0, 1.0);
    //map xyto [-1, 1]x[-1, 1]:
    float2 stx = 2.0 * frac(x) - 1.0;
    float2 sty = 2.0 * frac(y) - 1.0;
    float Rx2 = radius * radius - dot(stx, stx);
    float Ry2 = radius * radius - dot(sty, sty);
    if (Rx2 > 0.0 && Ry2 > 0.0)
    {
        N.x = stx / sqrt(Rx2);
        N.y = sty / sqrt(Ry2);
        
    }
    return normalize(N);
}

//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
VS_OUTPUT VS(VS_INPUT input)
{
    VS_OUTPUT output = (VS_OUTPUT) 0;
    
    float4x4 ModelViewProjectionMatrix = mul(mul(World, View), Projection);
    output.Pos = mul(input.Pos, ModelViewProjectionMatrix);
    
    output.Tex = input.TexCoord;
    output.Nor = mul(float4(input.Normal, 1), World);
    output.PxPos = input.Pos.xyz;
    output.Col = input.Color;
    
    return output;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS(VS_OUTPUT input) : SV_Target
{
    float4 finalColor = 0;
    
    // Texture -- 
    float3 bumpMap = tx1.Sample(txSampler, input.Tex).x;
    
    // Normal Mapping
    // float3 normalMap = normalize(2.0 * bumpMap - 1.0);
    
    // Height Mapping
    // float heightScale = 2.0;
    // float heightMap = heightScale * bumpMap;
    
    // float dx = ddx(heightMap);
    // float dy = ddy(heightMap);
    // float3 normalMap = normalize(float3(-dx, -dy, 0.2));
    
    float BumpDensity = 0.5;
    float x = BumpDensity * input.Tex.x,
     y = BumpDensity * input.Tex.y;
    float3 normalMap = bumpNormal(x, y);
    
    // Update pixel position
    float3 inPos = input.PxPos.xyz;
    inPos += normalMap * input.Nor;
    
    // Diffuse light
    float4 matCol = tx0.Sample(txSampler, input.Tex);
    float4 lightCol = float4(1.0, 1.0, 1.0, 1.0);
    float3 L = float3(1.0f, 1.0f, -1.0f);
    float3 N = normalize(normalMap);
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
