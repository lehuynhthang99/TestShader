Shader "Unlit/ReflectedCubemapMapping"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _Cubemap("Cubemap", CUBE) = "white" {}
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float3 reflectWS : TEXTCOORD0;
            };

            float4 _BaseColor;
            samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
                
                float3 normalWS = UnityObjectToWorldNormal(v.normalOS);
                float3 positionWS = mul(unity_ObjectToWorld, v.positionOS);
                float3 viewDirWS = UnityWorldSpaceViewDir(positionWS);
                viewDirWS = -normalize(viewDirWS);
                o.reflectWS = reflect(viewDirWS, normalWS);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = texCUBE(_Cubemap, i.reflectWS);
                col *= _BaseColor;
                return col;
            }
            ENDHLSL
        }
    }
}
