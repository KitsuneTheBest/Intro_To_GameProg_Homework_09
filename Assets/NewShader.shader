Shader "Custom/New Shader"
{
    Properties
    {
        [MainTexture]
        _BaseMap("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        
        [Header(Specular)]
        _Specular ("Specular", Range(0.1, 100)) = 1.0
        _SpecularColor ("Specular color", color) = (1.0, 1.0, 1.0, 1.0)
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal_ws : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            float4 _Color;
            float _VertexAnimationSpeed;

            float _Specular;
            float4 _SpecularColor;
            
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.normal_ws = TransformObjectToWorldNormal(v.normal);
                return o;
            }


            float4 frag (v2f i) : SV_Target
            {
                // View
                float3 viewDirection = normalize(_WorldSpaceCameraPos - normalize(i.normal_ws));
                // Light
                Light light = GetMainLight();

                float4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _Color;
                
                // Lambertian
                float n_dot_l = dot(normalize(i.normal_ws), light.direction);
                
                float3 lambertian = n_dot_l * albedo * light.color;
                
                // Specular
                
                float3 halfVector = normalize(light.direction + viewDirection);
                float specAngle = max(dot(halfVector, normalize(i.normal_ws)), 0.0);
                float3 specular = pow(specAngle, _Specular * _Specular);
                
                return float4(lambertian + specular, 1.0);
            }
            ENDHLSL
        }
    }
}
