Shader "Custom/LightTest"
{
	Properties
	{
		_MainTex0("Texture0", 2D) = "white" {}
		_BaseColor("Color", Color) = (1,1,1,1)

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
		// 텍스처 샘플러와 구조체 정의
		TEXTURE2D(_MainTex0);





		SAMPLER(sampler_MainTex0);
		CBUFFER_START(UnityPerMaterial)
			
		float4 _BaseColor; // 프로퍼티로 정의된 색상
		CBUFFER_END

		struct VertexInput
		{
			float4 positionOS : POSITION; // 정점 위치
			float2 uv : TEXCOORD0;      // 텍스처 좌표
			float4 color : COLOR; //버텍스 컬러 받아오기
			float3 normalOS : NORMAL;
		};

		struct FragmentInput
		{
			float4 positionHCS : SV_POSITION; // 클립 공간의 정점 위치
			float2 uv : TEXCOORD0;         // 텍스처 좌표
			float4 color : COLOR; //버텍스 컬러 출력하기 
			float3 normalWS : NORMAL;
			float3 positionWS : TEXCOORD1;
		};

		// 정점 셰이더
		FragmentInput Vert(VertexInput v)
		{
			FragmentInput o;
			o.positionHCS = TransformObjectToHClip(v.positionOS.xyz); // 객체 공간 -> 클립 공간
			o.positionWS = TransformObjectToWorld(v.positionOS.xyz);

			o.uv = v.uv;
			o.color = v.color;
			o.normalWS = TransformObjectToWorld(v.normalOS);
			
			return o;
		}


		// 프래그먼트 셰이더
		float4 Frag(FragmentInput i) : SV_Target
		{
			float4 shadowCoord = TransformWorldToShadowCoord(i.positionWS);
			Light light = GetMainLight(shadowCoord);
			float3 lightDir = normalize(light.direction);
			float3 normalWS = normalize(i.normalWS);
			
			half4 textureColor = SAMPLE_TEXTURE2D(_MainTex0, sampler_MainTex0, i.uv); // 텍스처 샘플링
			
			
			//float4 Vcolor = i.color;
			float NdotL = saturate(dot(lightDir, normalWS)*0.5+0.5);
			float3 lightColor = light.color.rgb;
			  

			//float4 finalColor = lerp(textureColor, textureColor1, i.color.r);

			float3 Ambient = SampleSH(normalWS);
			float4 finalColor = 1;
			
			
			
			finalColor.rgb = (NdotL * light.shadowAttenuation  * lightColor*textureColor.rgb) + (Ambient * textureColor.rgb);
			finalColor.a = textureColor.a;
			return finalColor;
		}
		ENDHLSL
	}
	Pass//그림자 패스
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
