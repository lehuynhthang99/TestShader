Shader "Custom/SimpleRimLight"
{
    Properties
    {
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1) // White rim color
        _RimPower ("Rim Power", Range(1.0, 10.0)) = 2.0 // Control how tight the rim effect is
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            uniform float4 _RimColor;
            uniform float _RimPower;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0)));
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Compute rim factor based on the angle between the view direction and the surface normal
                float rimFactor = 1.0 - saturate(dot(i.viewDir, i.worldNormal));
                rimFactor = pow(rimFactor, _RimPower);

                // Apply the rim lighting effect
                return rimFactor * _RimColor;
            }
            ENDCG
        }
    }
}
