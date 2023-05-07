Shader "Unlit/AnaglyphShader"
{
    Properties
    {
        _Offset("Color Offset", Float) = 2
        _EffectOn("Effect On?", Int) = 1
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        Cull Off ZWrite Off ZTest Always
        Pass
        {
          
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float _Offset;
                int _EffectOn;
                texture2D _CameraColorTexture;
                SamplerState sampler_CameraColorTexture;
                float4 _CameraColorTexture_TexelSize;
            CBUFFER_END

            struct VertexInput {
                float3 positionOS		: POSITION;
                float2 uv				: TEXCOORD;
            };

            struct VertexOutput {
                float4 positionCS		: SV_POSITION;
                float2 uv				: TEXCOORD;
            };

            float4 Anaglyph_color(float2 UV, float colorOffset)
            {
                    float2 Texel = (1.0) / float2(_CameraColorTexture_TexelSize.z, _CameraColorTexture_TexelSize.w);
                    float2 uvRight = float2(UV.x + Texel.x * colorOffset, UV.y);
                    float3 addedColorCenter = _CameraColorTexture.Sample(sampler_CameraColorTexture, UV).rgb;
                    float3 addedColorRight = _CameraColorTexture.Sample(sampler_CameraColorTexture, uvRight).rgb;
                    addedColorCenter.r *= 0;
                    addedColorCenter.g /= 2;
                    addedColorRight.g *= 0;
                    addedColorRight.b *= 0;
                    float3 result = addedColorCenter + addedColorRight;
                    return float4(result, 1);     
            }
            
            VertexOutput Vertex(VertexInput input) {
                VertexOutput output;
                VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS);
                output.positionCS = posInputs.positionCS;
                output.uv = input.uv;
                return output;
            }

            float4 Fragment(VertexOutput input) : SV_TARGET{
                if(_EffectOn){ return Anaglyph_color(input.uv,_Offset); }
                else{
                    return _CameraColorTexture.Sample(sampler_CameraColorTexture, input.uv).rgba;
                }
            }
            ENDHLSL
        }
    }
}
