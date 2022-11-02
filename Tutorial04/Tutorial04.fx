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
}

SamplerState txSampler : register(s0);
Texture2D txCoins : register(t0);
Texture2D txTiles : register(t1);
Texture2D txRocks : register(t2);

//--------------------------------------------------------------------------------------


struct VS_INPUT
{
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD;
};

struct PS_INPUT
{
    float4 Pos : SV_POSITION;
    float2 Tex : TEXCOORD0; 
};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VS(VS_INPUT input)
{
    PS_INPUT output = (PS_INPUT)0;
    output.Pos = mul(input.Pos, World);
    output.Pos = mul(output.Pos, View);
    output.Pos = mul(output.Pos, Projection);
    output.Tex = input.Tex;
    
    return output;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT input, bool isFrontFace : SV_IsFrontFace) : SV_Target
{
    // float4 woodColor = txWoodColor.SampleLevel(txWoodSampler, input.Tex, 1) * float4(0.7f, 0.7f, 0.7f, 1.0f);
    
    float4 color1 = txCoins.Sample(txSampler, 2 * input.Tex);
    float4 color2 = txTiles.Sample(txSampler, 2 * input.Tex);
    
    //float4 color;
    //if (isFrontFace)
    //{
    //    color = txCoins.Sample(txSampler, 2 * input.Tex);
    //}
    //else
    //{
    //    color = txCoins.Sample(txSampler, 2 * input.Tex);
    // }
    
    float4 blend = color1 * color2 * 2.0;
    blend = saturate(blend);
    return blend;
}