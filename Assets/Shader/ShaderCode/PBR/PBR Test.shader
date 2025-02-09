Shader "Custom/PBRTest"
{
	Properties
	{
		_MainTex0("Texture0", 2D) = "white" {}
		_BaseColor("Color", Color) = (1,1,1,1)
		_NormalMap("Normal Map", 2D) = "bump"{}
		_NormalPow("Normal Power", Range(-1,1)) = 0.5// �븻�� ���� ����
		_SPong("Specular" , Range(-20,20)) = 10 

	}
		SubShader
	{
		Tags { "RenderType" = "Opaque""RenderPipeline" = "UniversalPipeline"}

		Pass
		{
			Name "ForwardLit"
			Tags {"LightMode" = "UniversalForward"}

			HLSLPROGRAM
		#pragma vertex Vert
			#pragma fragment Frag
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
		#pragma multi_compile_fragment _ _SHADOWS_SOFT 
			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" // URP Core Library
			 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			 
		// �ؽ�ó ���÷��� ����ü ����
		TEXTURE2D(_MainTex0);
		TEXTURE2D(_NormalMap);





		SAMPLER(sampler_MainTex0);
		SAMPLER(sampler_NormalMap);
		CBUFFER_START(UnityPerMaterial)
			float _NormalPow;
			float _SPong;
		float4 _BaseColor; // ������Ƽ�� ���ǵ� ����
		CBUFFER_END

		struct VertexInput
		{
			float4 positionOS : POSITION; // ���� ��ġ
			float2 uv : TEXCOORD0;      // �ؽ�ó ��ǥ
			float3 normalOS : NORMAL;
			float4 tangent : TANGENT;
		};

		struct FragmentInput
		{
			float4 positionHCS : SV_POSITION; // Ŭ�� ������ ���� ��ġ
			float2 uv : TEXCOORD0;         // �ؽ�ó ��ǥ
			float3 normalWS : NORMAL;
			float3 positionWS : TEXCOORD1;
			float3 T : TEXCOORD2; //ź��Ʈ(x)
			float3 B : TEXCOORD3;//BiNormal(y)
			float3 N : TEXCOORD4;//WorldNormal(z)
			half3 viewDir : TEXCOORD5;

		};
		void LocalNormalTBN(half localnormal, float4 tangent, inout half3 T,inout half3 B, inout half3 N ){

			half TangentSign = tangent.w * unity_WorldTransformParams.w;
			N = normalize(TransformObjectToWorld(localnormal));
			T = normalize(TransformObjectToWorldDir(tangent.xyz));
			B = normalize(cross(N,T) * TangentSign);
			}

			half3 TangentNormalToWorldNormal(half3 TangentNormal, half3 T, half3 B, half3 N){
				float3x3 TBN = float3x3(T,B,N);
				//TBN = transpose(TBN);
				return mul(TangentNormal,TBN );

				}

		// ���� ���̴�
		FragmentInput Vert(VertexInput v)
		{
			FragmentInput o;
			o.positionHCS = TransformObjectToHClip(v.positionOS.xyz); // ��ü ���� -> Ŭ�� ����
			//o.positionWS = TransformObjectToWorld(v.positionOS.xyz);

			o.uv = v.uv;
			LocalNormalTBN(v.normalOS, v.tangent, o.T, o.B, o.N);
			//o.normalWS = v.normalOS;
			
			o.viewDir = normalize(TransformObjectToWorld(v.positionOS).xyz - _WorldSpaceCameraPos.xyz);
			return o;
		}

		
		// �����׸�Ʈ ���̴�
		float4 Frag(FragmentInput i) : SV_Target
		{
			float4 shadowCoord = TransformWorldToShadowCoord(i.positionWS);
			 float3 lightDir = normalize(GetMainLight().direction);
			 Light light = GetMainLight(shadowCoord);
			 float4 textureColor = SAMPLE_TEXTURE2D(_MainTex0, sampler_MainTex0, i.uv);
                float3 WorldNormal = normalize(TangentNormalToWorldNormal(float3(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv).xy * 2.0 - 1.0,0), i.T, i.B, i.N));
                WorldNormal.xy *= _NormalPow;

                float3 Reflection = reflect(lightDir, normalize(float3(WorldNormal.xy,0.5)));
                float Spec_Phong = saturate(dot(Reflection, normalize(i.viewDir)));
                Spec_Phong = pow(Spec_Phong, _SPong);

                float fNDotL = saturate(dot(lightDir, WorldNormal));
                float3 Ambient = SampleSH(WorldNormal);
                float3 lightColor = GetMainLight().color.rgb;

                float3 color = (fNDotL * lightColor*textureColor*light.shadowAttenuation ) + (Spec_Phong * lightColor * textureColor) + (Ambient*textureColor);
				
                return float4(color * _BaseColor.rgb, textureColor.a);
		}
		ENDHLSL
	}
	Pass//�׸��� �н�
		{
			Name "ShadowCaster"
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
