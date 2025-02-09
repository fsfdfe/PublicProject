Shader "Custom/light"
{
    Properties
    {

        _MainTex("Texture", 2D) = "white" {}    // �ؽ�ó ������Ƽ
        _MainTex2("Texture2", 2D) = "white"{}
        _BaseColor("Color", Color) = (1, 1, 1, 1) // ���� ������Ƽ
            _U("Ÿ�ϸ� U", float) = 1
            _V("Ÿ�ϸ� V", float) = 1
            _CT("�ӵ�����", float) = 1

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

                // �ؽ�ó ���÷��� ����ü ����
                TEXTURE2D(_MainTex);
                TEXTURE2D(_MainTex2);



                SAMPLER(sampler_MainTex);
                SAMPLER(sampler_MainTex2);
                float4 _BaseColor; // ������Ƽ�� ���ǵ� ����
                float1 _U;
                float1 _V;
                float _CT;


                struct VertexInput
                {
                    float4 position : POSITION; // ���� ��ġ
                    float2 uv : TEXCOORD0;      // �ؽ�ó ��ǥ
                    float4 color : COLOR;
                    float3 normalA : NORMAL;
                };

                struct FragmentInput
                {
                    float4 position : SV_POSITION; // Ŭ�� ������ ���� ��ġ
                    float2 uv : TEXCOORD0;         // �ؽ�ó ��ǥ
                    float4 color : COLOR;
                    float3 normalB : NORMAL;
                    float3 positionWS : TEXCOORD1;
                };

                // ���� ���̴�
                FragmentInput Vert(VertexInput v)
                {
                    FragmentInput o;
                    o.position = TransformObjectToHClip(v.position.xyz); // ��ü ���� -> Ŭ�� ����
                    o.positionWS = TransformObjectToWorld(v.position.xyz);
                    
                    o.uv = v.uv;
                    o.color = v.color;
                    o.normalB = v.normalA;
                    return o;
                }

                // �����׸�Ʈ ���̴�
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
                    //float4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, modifiedUV); // �ؽ�ó ���ø�

                    Light light = GetMainLight(shadowCoord);

                    /*float3 lightDir = normalize(light.direction);
                    float3 normalB = normalize(i.normalB);

                    float NdotL = dot(lightDir, normalB);

                    float3 Ambient = SampleSH(normalB);
                    */

                    return light.shadowAttenuation; // �ؽ�ó ����� �⺻ ������ ����
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
