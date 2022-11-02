//--------------------------------------------------------------------------------------
// File: Tutorial04.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------
cbuffer ConstantBuffer : register( b0 )
{
	matrix World;
	matrix View;
	matrix Projection;
    float4 LightPos;
}

//--------------------------------------------------------------------------------------
struct VS_OUTPUT
{
    float4 Pos : SV_POSITION;
    float4 Color : COLOR0;
    //float3 Norm : TEXCOORD0;
    //float3 PosWorld : TEXCOORD1;
};

//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
// VS_OUTPUT MyVertexShader(float4 Pos : POSITION, float4 N : NORMAL)
VS_OUTPUT MyVertexShader(float4 Pos : POSITION, float4 Color : COLOR)
{
    VS_OUTPUT output = (VS_OUTPUT)0;

    // reset
    // float4 inPos = Pos;
    
    //// translate
    //float3 T = float3(1, 0.3, 1.0);
    //inPos.xyz += T;

    //// scale
    //float3 Scale = float3(0.2, 3, 3);
    //inPos.xyz *= Scale;
    
    //// rotation
    //float angle = 150.0f;
    //float3x3 rMatrix = float3x3(
    //    cos(angle), 0, -sin(angle),
    //    0         , 1, 0,
    //    sin(angle), 0, cos(angle)
    //  );
    //inPos.xyz = mul(rMatrix, inPos.xyz);
        
    // resulting matrix
    //float4x4  ModelViewProjectionMatrix = mul(mul(World, View), Projection);
    //output.Pos = mul(inPos, ModelViewProjectionMatrix);

    // color
    output.Color = Color;

    
    output.Pos = mul(Pos, World);
    output.Pos = mul(output.Pos, View);
    output.Pos = mul(output.Pos, Projection);
 
    //output.PosWorld = Pos.xyz;
    //output.Norm = N.xyz;
   
    return output;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
//float4 MyPixelShader1(VS_OUTPUT input) : SV_Target
//{
//    // color and lighting    
//    float4 color = 0;
    
//    float4 materialAmb = float4(0.5, 0.2, 0.8, 1.0);
//    float4 materialDiff = float4(0.9, 0.7, 1.0, 1.0);
//    float4 lightCol = float4(1.0, 1.0, 1.0, 1.0);
//    float3 lightDir = normalize(LightPos.xyz - input.PosWorld.xyz);
//    float3 normal = normalize(input.Norm);
//    float diff = max(0.0, dot(lightDir, normal));
    
//    color = (materialAmb + diff * materialDiff) * lightCol;
//    return color;
//}

float4 MyPixelShader1(VS_OUTPUT input) : SV_Target
{
    // float4 colors = float4(1.0f, 0.0f, 1.0f, 0.0f);
    return input.Color; // = colors;
}

float4 MyPixelShader2(VS_OUTPUT input) : SV_Target
{
    // float4 colors = float4(0.0f, 1.0f, 1.0f, 0.0f);
    return input.Color; // = colors;
}

float4 MyPixelShader3(VS_OUTPUT input) : SV_Target
{
    // float4 colors = float4(1.0f, 1.0f, 0.0f, 0.0f);
    return input.Color * float4(0.0f, 1.0f, 1.0f, 1.0f); // = colors;
}