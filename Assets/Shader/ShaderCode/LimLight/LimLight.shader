Shader "Custom/LimLight"
{
	Properties
	{
		_MainTex0("Texture0", 2D) = "white" {}
		_BaseColor("Color", Color) = (1,1,1,1)
		[HDR]_EmissionColor("Emission Color", Color) = (1, 0.5, 0, 1)
		_Pow("RimLight Power", Range(1,10)) = 5
		_CT("Time", float) = 0

	}
		SubShader
	{
		
            Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
            ZWrite Off
            blend SrcAlpha OneMinusSrcAlpha
			
           


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
		SAMPLER(sampler_MainTex0);
		CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float _Pow;
			float _CT;
		float4 _BaseColor; // ������Ƽ�� ���ǵ� ����
		CBUFFER_END

		struct VertexInput
		{
			float4 positionOS : POSITION; // ���� ��ġ
			float2 uv : TEXCOORD0;      // �ؽ�ó ��ǥ
			float4 color : COLOR; //���ؽ� �÷� �޾ƿ���
			float3 normalOS : NORMAL;
			
		};

		struct FragmentInput
		{
			float4 positionHCS : SV_POSITION; // Ŭ�� ������ ���� ��ġ
			float2 uv : TEXCOORD0;         // �ؽ�ó ��ǥ
			float4 color : COLOR; //���ؽ� �÷� ����ϱ� 
			float3 normalWS : NORMAL;
			float3 positionWS : TEXCOORD1;
			float3 viewDirWS : TEXCOORD2;
		};

		// ���� ���̴�
		FragmentInput Vert(VertexInput v)
		{
			FragmentInput o;
			o.positionHCS = TransformObjectToHClip(v.positionOS.xyz); // ��ü ���� -> Ŭ�� ����
			o.positionWS = TransformObjectToWorld(v.positionOS.xyz);

			o.uv = v.uv;
			o.color = v.color;
			o.normalWS = TransformObjectToWorldNormal(v.normalOS);
			o.viewDirWS = normalize(GetCameraPositionWS() - o.positionWS);

			return o;
		}
		

		// �����׸�Ʈ ���̴�
		float4 Frag(FragmentInput i) : SV_Target
		{
			float time = _Time.y;
			float4 textureColor = SAMPLE_TEXTURE2D(_MainTex0, sampler_MainTex0, i.uv); 
			float3 normalWS = normalize(i.normalWS);
			float3 viewDirWS = i.viewDirWS;
			float NdotL1 = saturate(dot(normalWS, viewDirWS));
			NdotL1 = pow(1- NdotL1, _Pow);

			float3 EmissionColor = _EmissionColor.rgb;
			float Alpha = NdotL1 * abs(sin(_Time.y*_CT));
			float3 Ambient = SampleSH(normalWS);
			 
			 float3 finalColor =  NdotL1*EmissionColor;
			 return float4(finalColor, Alpha);
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
