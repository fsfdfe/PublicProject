Shader "Custom/LerpTest"
{
    Properties
    {

        _MainTex("Texture", 2D) = "white" {}    // �ؽ�ó ������Ƽ
    _MainTex2("Texture2", 2D) = "white"{}
        _BaseColor("Color", Color) = (1, 1, 1, 1) // ���� ������Ƽ
            _U("Ÿ�ϸ� U", float) = 1
            _V("Ÿ�ϸ� V", float) = 1
            _CT("�ӵ�����", float) = 1
            _GS("Lerp", Range(0,1)) =0

    }

        SubShader
        {
            Tags { "RenderType" = "Opaque"  }
         
            Pass
            {

                HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment Frag

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" // URP Core Library

                // �ؽ�ó ���÷��� ����ü ����
                TEXTURE2D(_MainTex);
        TEXTURE2D(_MainTex2);



                SAMPLER(sampler_MainTex);
                SAMPLER(sampler_MainTex2);
                float4 _BaseColor; // ������Ƽ�� ���ǵ� ����
                float1 _U;
                float1 _V;
                float _CT;
                float _GS;

                struct VertexInput
                {
                    float4 position : POSITION; // ���� ��ġ
                    float2 uv : TEXCOORD0;      // �ؽ�ó ��ǥ
                };

                struct FragmentInput
                {
                    float4 position : SV_POSITION; // Ŭ�� ������ ���� ��ġ
                    float2 uv : TEXCOORD0;         // �ؽ�ó ��ǥ
                };

                // ���� ���̴�
                FragmentInput Vert(VertexInput v)
                {
                    FragmentInput o;
                    o.position = TransformObjectToHClip(v.position.xyz); // ��ü ���� -> Ŭ�� ����
                    o.uv = v.uv;
                    return o;
                }
                

                // �����׸�Ʈ ���̴�
                float4 Frag(FragmentInput i) : SV_Target
                {
                    float time = _Time.y;
                
                //float2 modifiedUV = float2(i.uv.x * _U , i.uv.y * _V);
                //float2 Tileing = float2(i.uv.x * 2, i.uv.y * 2);
                //float4 uvColor = float4(modifiedUV.x, modifiedUV.y, 0, 1);
                    float4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv); // �ؽ�ó ���ø�
                    float4 textureColor2 = SAMPLE_TEXTURE2D(_MainTex2, sampler_MainTex2, i.uv);
                    float4 blendedTex = lerp(textureColor, textureColor2, textureColor2.a * _GS);


                    return  blendedTex * _BaseColor; // �ؽ�ó ����� �⺻ ������ ����
                }
                ENDHLSL
            }
        }
}
