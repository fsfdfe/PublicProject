Shader "Custom/VertexColorTest"
{
    Properties
    {
        _MainTex0 ("Texture0", 2D) = "white" {}
    _MainTex1("Texture1", 2D) = "white" {}
    _MainTex2("Texture2", 2D) = "white" {}
    _MainTex3("Texture3", 2D) = "white" {}
    _BaseColor("Color", Color) = (1,1,1,1)

    }
        SubShader
    {
        Tags { "RenderType" = "Opaque"}

        Pass
        {

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" // URP Core Library

            // 텍스처 샘플러와 구조체 정의
            TEXTURE2D(_MainTex0);
    TEXTURE2D(_MainTex1);
    TEXTURE2D(_MainTex2);
    TEXTURE2D(_MainTex3);



            SAMPLER(sampler_MainTex0);
            SAMPLER(sampler_MainTex1);
            SAMPLER(sampler_MainTex2);
            SAMPLER(sampler_MainTex3);
            float4 _BaseColor; // 프로퍼티로 정의된 색상
           

            struct VertexInput
            {
                float4 position : POSITION; // 정점 위치
                float2 uv : TEXCOORD0;      // 텍스처 좌표
                float4 color : COLOR; //버텍스 컬러 받아오기
            };

            struct FragmentInput
            {
                float4 position : SV_POSITION; // 클립 공간의 정점 위치
                float2 uv : TEXCOORD0;         // 텍스처 좌표
                float4 color : COLOR; //버텍스 컬러 출력하기 
            };

            // 정점 셰이더
            FragmentInput Vert(VertexInput v)
            {
                FragmentInput o;
                o.position = TransformObjectToHClip(v.position.xyz); // 객체 공간 -> 클립 공간
                o.uv = v.uv;
                o.color = v.color;
                return o;
            }


            // 프래그먼트 셰이더
            float4 Frag(FragmentInput i) : SV_Target
            {
                
                float4 textureColor = SAMPLE_TEXTURE2D(_MainTex0, sampler_MainTex0, i.uv); // 텍스처 샘플링
                float4 textureColor1 = SAMPLE_TEXTURE2D(_MainTex1, sampler_MainTex1, i.uv);
                float4 textureColor2 = SAMPLE_TEXTURE2D(_MainTex2, sampler_MainTex2, i.uv);
                float4 textureColor3 = SAMPLE_TEXTURE2D(_MainTex3, sampler_MainTex3, i.uv);
                float4 Vcolor = i.color;
                float4 finalColor = lerp(textureColor, textureColor1, i.color.r);
                finalColor = lerp(finalColor, textureColor2, i.color.g);
                finalColor = lerp(finalColor, textureColor3, i.color.b);

                return  finalColor; 
            }
            ENDHLSL
        }
    }
}