Shader "Unlit/OutlineShader"
{
    Properties
    {
        _Thickness("Outline Thickness", Float) = 1
        _Color("Outline Color", Vector) = (0,0,0)
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
                float _Thickness;
                float3 _Color;
                texture2D _CameraColorTexture;
                SamplerState sampler_CameraColorTexture;
                float4 _CameraColorTexture_TexelSize;
                //texture2D _CameraDepthTexture;
                //SamplerState sampler_CameraDepthTexture;
            CBUFFER_END

            struct VertexInput {
                float3 positionOS		: POSITION;
                float2 uv				: TEXCOORD;
            };

            struct VertexOutput {
                float4 positionCS		: SV_POSITION;
                float2 uv				: TEXCOORD;
            };
            
            float4 Outline_float(float2 UV, float outlineThickness, float3 outlineColor)
            {
                
                float sobelMatrixX[9] = {
                    -1, 0, 1,
                    -2, 0, 2,
                    -1, 0, 1
                };

                float sobelMatrixY[9] = {
                    1, 2, 1,
                    0, 0, 0,
                    -1, -2, -1
                };

                float halfScaleFloor = floor(outlineThickness * 0.5);
                float halfScaleCeil = ceil(outlineThickness * 0.5);

                float2 Texel = (1.0) / float2(_CameraColorTexture_TexelSize.z, _CameraColorTexture_TexelSize.w);
                float2 uvSamples[9];
                float depthSamples[9];

                float3 horizTotal = float3(0,0,0);
                float3 vertTotal = float3(0, 0, 0);

                uvSamples[0] = UV + float2(-Texel.x, -Texel.y) * halfScaleFloor;
                uvSamples[1] = UV + float2(0, -Texel.y * halfScaleFloor);
                uvSamples[2] = UV + float2(Texel.x * halfScaleCeil, -Texel.y * halfScaleFloor);

                uvSamples[3] = UV + float2(-Texel.x * halfScaleFloor, 0);
                uvSamples[4] = UV + float2(0, 0);
                uvSamples[5] = UV + float2(Texel.x * halfScaleCeil, 0);

                uvSamples[6] = UV + float2(-Texel.x * halfScaleFloor, Texel.y * halfScaleCeil);
                uvSamples[7] = UV + float2(0, Texel.y * halfScaleCeil);
                uvSamples[8] = UV + float2(Texel.x, Texel.y) * halfScaleCeil;
                
                for (int i = 0; i < 9; i++)
                {
                    depthSamples[i] = Linear01Depth(SampleSceneDepth(uvSamples[i]), _ZBufferParams);
                    horizTotal += depthSamples[i] * sobelMatrixX[i];
                    vertTotal += depthSamples[i] * sobelMatrixY[i];
                }

                float3 sobel = sqrt(horizTotal * horizTotal + vertTotal * vertTotal);
                float sobelTotal = saturate(sobel.x + sobel.y + sobel.z);
                sobelTotal = sobelTotal > 0.01 ? 1 : 0;
                float3 original = _CameraColorTexture.Sample(sampler_CameraColorTexture, UV).rgb;
                float3 finalColor = lerp(original, outlineColor, sobelTotal);
                
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
                return Outline_float(input.uv,_Thickness,_Color);
                
                            
            }
            ENDHLSL
        }
    }
}
