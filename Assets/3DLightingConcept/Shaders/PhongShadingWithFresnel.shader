Shader "Custom/PhongShadingWithFresnel"
{
    Properties
    {
        _AmbientColor ("Ambient Color", Color) = (1, 1, 1, 1) // White rim color
        _DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1) // White rim color
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1) // White rim color
        _Shininess ("Shininess", Float) = 32.0

        [Space(16)]
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

            uniform float4 _AmbientColor;
            uniform float4 _DiffuseColor;
            uniform float4 _SpecularColor;
            uniform float _Shininess;

            uniform float _RimPower;
            uniform float4 _RimColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 viewDirection : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0)));
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDirection = normalize(_WorldSpaceCameraPos - worldPos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 resultColor = 0;
                
                //calculate Ambient
                float4 ambientColorResult = _AmbientColor;

                //calculate Diffuse
                float3 lightDirection = _WorldSpaceLightPos0.xyz;
                float NDotL = max(dot(lightDirection, i.worldNormal), 0);
                float4 diffuseColorResult = NDotL * _DiffuseColor;

                //calculate Specular
                float3 lightReflectionDirection = reflect(-lightDirection, i.worldNormal);
                float specularFactor = max(dot(i.viewDirection, lightReflectionDirection), 0);
                float4 specularColorResult = _SpecularColor * pow(specularFactor, _Shininess);

                //rim light
                float rimValue = 1.0 - max(dot(i.viewDirection, i.worldNormal), 0.0);
                float rimColorResult = _RimColor * pow(rimValue, _RimPower);

                resultColor = diffuseColorResult + ambientColorResult + specularColorResult;
                resultColor += (resultColor * rimColorResult);

                resultColor.a = 1;
                return resultColor;
            }
            ENDCG
        }
    }
}
