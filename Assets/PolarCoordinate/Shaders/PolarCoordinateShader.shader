Shader "Unlit/PolarCoordinateShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _BaseTex ("Texture", 2D) = "white" {}
        _Center ("Center", Vector) = (0.5, 0.5, 0.0)
        _RadialScale ("Radial Scale", Float) = 1
        _LengthScale ("Length Scale", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #define PI 3.14159235

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _BaseTex;
            float4 _BaseTex_ST;
            float4 _BaseColor;
            float2 _Center;
            float _RadialScale;
            float _LengthScale;


            float2 cartesianToPolar(float2 cartUV)
            {

                 float2 offsetUV = cartUV - _Center;
                 float radius = length(offsetUV) * 2;
                 float angle = atan2(offsetUV.x, offsetUV.y) / (2.0f * PI) + 0.5f;

                 // float angle = (atan2(offsetUV.x, offsetUV.y) + PI) / (2.0f * PI);
                 // angle /=(2.0f * PI);
                 // float angle = atan2(offsetUV.x, offsetUV.y);
                 return float2(radius, angle);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 radialUV = cartesianToPolar(i.uv);
                radialUV.x *= _RadialScale;
                radialUV.y *= _LengthScale;

                float4 col = tex2D(_BaseTex, radialUV);
                return col;
            }
            ENDHLSL
        }
    }
}
