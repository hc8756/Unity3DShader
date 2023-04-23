Shader "Unlit/AnaglyphShader"
{
    Properties
    {
        _Offset("Color Offset", Float) = 1
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
                float3 finalColor = _CameraColorTexture.Sample(sampler_CameraColorTexture, UV).rgb;
                return float4(finalColor, 1);
            }
            
            VertexOutput Vertex(VertexInput input) {
                VertexOutput output;
                VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS);
                output.positionCS = posInputs.positionCS;
                output.uv = input.uv;
                return output;
            }

            float4 Fragment(VertexOutput input) : SV_TARGET{
                return Anaglyph_color(input.uv,_Offset);
            }
            ENDHLSL
        }
    }
}
