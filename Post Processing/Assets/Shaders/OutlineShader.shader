Shader "Unlit/OutlineShader"
{
    Properties
    {
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            

            CBUFFER_START(UnityPerMaterial)
                int _EffectOn;
                float3 _Color;
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
            
            float4 Outline_float(float2 UV)
            {
                float2 Texel = (1.0) / float2(_CameraColorTexture_TexelSize.z, _CameraColorTexture_TexelSize.w);
                float2 offsets[4] =
                {
                    float2(-Texel.x, 0),
                    float2(+Texel.x, 0),
                    float2(0, -Texel.y),
                    float2(0, +Texel.y),
                };

                // COMPARE DEPTHS --------------------------

                // Sample the depths of this pixel and the surrounding pixels
                float depthHere = Linear01Depth(UV, _ZBufferParams); 
                float depthLeft = Linear01Depth(UV + offsets[0], _ZBufferParams);
                float depthRight = Linear01Depth(UV + offsets[1], _ZBufferParams);
                float depthUp = Linear01Depth(UV + offsets[2], _ZBufferParams);
                float depthDown = Linear01Depth(UV + offsets[3], _ZBufferParams);

                // Calculate how the depth changes by summing the absolute values of the differences
                float depthChange =
                    abs(depthHere - depthLeft) +
                    abs(depthHere - depthRight) +
                    abs(depthHere - depthUp) +
                    abs(depthHere - depthDown);

                float depthTotal = pow(saturate(depthChange), 2);

                // COMPARE NORMALS --------------------------

                // Sample the normals of this pixel and the surrounding pixels
                float3 normalHere = _CameraNormalsTexture.Sample(sampler_CameraNormalsTexture, UV).rgb;
                float3 normalLeft = _CameraNormalsTexture.Sample(sampler_CameraNormalsTexture, UV + offsets[0]).rgb;
                float3 normalRight = _CameraNormalsTexture.Sample(sampler_CameraNormalsTexture, UV + offsets[1]).rgb;
                float3 normalUp = _CameraNormalsTexture.Sample(sampler_CameraNormalsTexture, UV + offsets[2]).rgb;
                float3 normalDown = _CameraNormalsTexture.Sample(sampler_CameraNormalsTexture, UV + offsets[3]).rgb;

                // Calculate how the normal changes by summing the absolute values of the differences
                float3 normalChange =
                    abs(normalHere - normalLeft) +
                    abs(normalHere - normalRight) +
                    abs(normalHere - normalUp) +
                    abs(normalHere - normalDown);

                // Total the components
                float normalTotal = pow(saturate(normalChange.x + normalChange.y + normalChange.z), 2);

                // FINAL COLOR VALUE -----------------------------

                // Which result, depth or normal, is more impactful?
                float outline = max(depthTotal, normalTotal);

                // Sample the color here
                float3 color = _CameraColorTexture.Sample(sampler_CameraColorTexture, UV).rgb;

                // Interpolate between this color and the outline
                float3 finalColor = lerp(color, float3(0, 0, 0), outline);
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
                if(_EffectOn){
                    return Outline_float(input.uv);
                }
                else{
                    return _CameraColorTexture.Sample(sampler_CameraColorTexture, input.uv).rgba;
                }                    
            }
            ENDHLSL
        }
    }
}
