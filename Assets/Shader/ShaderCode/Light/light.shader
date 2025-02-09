Shader "Custom/light"
{
    Properties
    {

        _MainTex("Texture", 2D) = "white" {}    // 텍스처 프로퍼티
        _MainTex2("Texture2", 2D) = "white"{}
        _BaseColor("Color", Color) = (1, 1, 1, 1) // 색상 프로퍼티
            _U("타일링 U", float) = 1
            _V("타일링 V", float) = 1
            _CT("속도조절", float) = 1

    }

        SubShader
        {
            Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
            
            Pass
            {
                Name "ForwardLit"
                Tags {"LightMode"  = "UniversalForward"}

                HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment Frag
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
		#pragma multi_compile_fragment _ _SHADOWS_SOFT 
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" // URP Core Library
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

                // 텍스처 샘플러와 구조체 정의
                TEXTURE2D(_MainTex);
                TEXTURE2D(_MainTex2);



                SAMPLER(sampler_MainTex);
                SAMPLER(sampler_MainTex2);
                float4 _BaseColor; // 프로퍼티로 정의된 색상
                float1 _U;
                float1 _V;
                float _CT;


                struct VertexInput
                {
                    float4 position : POSITION; // 정점 위치
                    float2 uv : TEXCOORD0;      // 텍스처 좌표
                    float4 color : COLOR;
                    float3 normalA : NORMAL;
                };

                struct FragmentInput
                {
                    float4 position : SV_POSITION; // 클립 공간의 정점 위치
                    float2 uv : TEXCOORD0;         // 텍스처 좌표
                    float4 color : COLOR;
                    float3 normalB : NORMAL;
                    float3 positionWS : TEXCOORD1;
                };

                // 정점 셰이더
                FragmentInput Vert(VertexInput v)
                {
                    FragmentInput o;
                    o.position = TransformObjectToHClip(v.position.xyz); // 객체 공간 -> 클립 공간
                    o.positionWS = TransformObjectToWorld(v.position.xyz);
                    
                    o.uv = v.uv;
                    o.color = v.color;
                    o.normalB = v.normalA;
                    return o;
                }

                // 프래그먼트 셰이더
                float4 Frag(FragmentInput i) : SV_Target
                {
                    float4 shadowCoord = TransformWorldToShadowCoord(i.positionWS);
                    /*
                    float time = _Time.y;
                    float4 textureColor2 = SAMPLE_TEXTURE2D(_MainTex2, sampler_MainTex2, i.uv - float2(0, time * _CT));
                    float2 modifiedUV = float2(i.uv.x + _U , i.uv.y + _V + textureColor2.r * 0.25);
                    float2 Tileing = float2(i.uv.x * 2, i.uv.y * 2);
                    */
                    

                    //float4 uvColor = float4(modifiedUV.x, modifiedUV.y, 0, 1);
                    //float4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, modifiedUV); // 텍스처 샘플링

                    Light light = GetMainLight(shadowCoord);

                    /*float3 lightDir = normalize(light.direction);
                    float3 normalB = normalize(i.normalB);

                    float NdotL = dot(lightDir, normalB);

                    float3 Ambient = SampleSH(normalB);
                    */

                    return light.shadowAttenuation; // 텍스처 색상과 기본 색상을 곱합
                }
                ENDHLSL

            }

            Pass
            {
                Name "shadowCaster"
                Tags{"LightMode" = "ShadowCaster"}

                ZWrite On
                ZTest LEqual
                ColorMask 0
                Cull Front
                HLSLPROGRAM

                #pragma vertex ShadowPassVertex
                #pragma fragment ShadowPassFragment
                #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"

                ENDHLSL
}

        }
}
