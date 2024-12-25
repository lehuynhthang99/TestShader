// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/CelShading"
{
    Properties
    {
        _DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1) 
        _Threshold ("Threshold", Vector) = (1, 1, 1, 1) 
        _Intensity ("Intensity", Vector) = (1, 1, 1, 1) 
        _OutlineThickness ("OutlineThickness", Float) = 1.0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            uniform float4 _DiffuseColor;
            uniform float4 _Threshold;
            uniform float4 _Intensity;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 clipPos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.clipPos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0)));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 resultColor = 0;
                
                //calculate Diffuse
                float3 lightDirection = _WorldSpaceLightPos0.xyz;
                float NDotL = max(dot(lightDirection, i.worldNormal), 0);
                float intensity = 0;
                if (NDotL < _Threshold.x)
                {
                    intensity = _Intensity.x;
                }
                else if (NDotL < _Threshold.y)
                {
                    intensity = _Intensity.y;
                }
                else if (NDotL < _Threshold.z)
                {
                    intensity = _Intensity.z;
                }
                else
                {
                    intensity = 1.0;
                }
                float4 diffuseColorResult = intensity * _DiffuseColor;

                resultColor = diffuseColorResult;

                resultColor.a = 1;
                return resultColor;
            }
            ENDCG
        }

        Pass
        {
            Name "Outline"
            ZWrite On
            Cull Front
            ColorMask RGB

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragOutline
            #include "UnityCG.cginc"

            uniform float _OutlineThickness;
            uniform float4 _DiffuseColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f 
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex * float4(1.0 + _OutlineThickness, 1.0 + _OutlineThickness, 1.0 + _OutlineThickness, 1.0));
                return o;
            }

            float4 fragOutline (v2f i) : SV_Target 
            {
                float4 resultColor = _DiffuseColor * 0.1f;
                resultColor.a = 1.0;
                return resultColor;
                // return float4(0, 0, 0, 1); // Black outline
            }
            ENDCG
        }
    }
}
