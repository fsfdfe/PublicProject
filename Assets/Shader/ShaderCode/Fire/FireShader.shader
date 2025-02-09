Shader "Custom/FireShader"
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
            Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
            ZWrite Off
            blend SrcAlpha OneMinusSrcAlpha
            cull Off
            Pass
            {

                HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment Frag

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" // URP Core Library

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
                };

                struct FragmentInput
                {
                    float4 position : SV_POSITION; // 클립 공간의 정점 위치
                    float2 uv : TEXCOORD0;         // 텍스처 좌표
                };

                // 정점 셰이더
                FragmentInput Vert(VertexInput v)
                {
                    FragmentInput o;
                    o.position = TransformObjectToHClip(v.position.xyz); // 객체 공간 -> 클립 공간
                    o.uv = v.uv;
                    return o;
                }

                // 프래그먼트 셰이더
                float4 Frag(FragmentInput i) : SV_Target
                {
                    float time = _Time.y;
                float4 textureColor2 = SAMPLE_TEXTURE2D(_MainTex2, sampler_MainTex2, i.uv - float2( 0, time * _CT));
                float2 modifiedUV = float2(i.uv.x + _U , i.uv.y + _V + textureColor2.r *0.25 );
                //float2 Tileing = float2(i.uv.x * 2, i.uv.y * 2);
                //float4 uvColor = float4(modifiedUV.x, modifiedUV.y, 0, 1);
                    float4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, modifiedUV); // 텍스처 샘플링

                   
                    return textureColor * _BaseColor * textureColor2 ; // 텍스처 색상과 기본 색상을 곱합
                }
                ENDHLSL
            }
        }
}
