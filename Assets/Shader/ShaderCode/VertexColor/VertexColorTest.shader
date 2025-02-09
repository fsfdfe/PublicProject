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

            // �ؽ�ó ���÷��� ����ü ����
            TEXTURE2D(_MainTex0);
    TEXTURE2D(_MainTex1);
    TEXTURE2D(_MainTex2);
    TEXTURE2D(_MainTex3);



            SAMPLER(sampler_MainTex0);
            SAMPLER(sampler_MainTex1);
            SAMPLER(sampler_MainTex2);
            SAMPLER(sampler_MainTex3);
            float4 _BaseColor; // ������Ƽ�� ���ǵ� ����
           

            struct VertexInput
            {
                float4 position : POSITION; // ���� ��ġ
                float2 uv : TEXCOORD0;      // �ؽ�ó ��ǥ
                float4 color : COLOR; //���ؽ� �÷� �޾ƿ���
            };

            struct FragmentInput
            {
                float4 position : SV_POSITION; // Ŭ�� ������ ���� ��ġ
                float2 uv : TEXCOORD0;         // �ؽ�ó ��ǥ
                float4 color : COLOR; //���ؽ� �÷� ����ϱ� 
            };

            // ���� ���̴�
            FragmentInput Vert(VertexInput v)
            {
                FragmentInput o;
                o.position = TransformObjectToHClip(v.position.xyz); // ��ü ���� -> Ŭ�� ����
                o.uv = v.uv;
                o.color = v.color;
                return o;
            }


            // �����׸�Ʈ ���̴�
            float4 Frag(FragmentInput i) : SV_Target
            {
                
                float4 textureColor = SAMPLE_TEXTURE2D(_MainTex0, sampler_MainTex0, i.uv); // �ؽ�ó ���ø�
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