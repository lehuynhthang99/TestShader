Shader "Custom/PhongShading"
{
    Properties
    {
        _AmbientColor ("Ambient Color", Color) = (1, 1, 1, 1) // White rim color
        _DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1) // White rim color
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1) // White rim color
        _Shininess ("Shininess", Float) = 32.0
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

                resultColor = diffuseColorResult + ambientColorResult + specularColorResult;
                // resultColor = specularColorResult;

                resultColor.a = 1;
                return resultColor;
            }
            ENDCG
        }
    }
}