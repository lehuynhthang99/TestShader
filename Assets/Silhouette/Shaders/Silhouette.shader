Shader "Unlit/Silhouette"
{
    Properties
    {
        _ForegroundColor ("FG Color", Color) = (1, 1, 1, 1)
        _BackgroundColor ("BG Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
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
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float4 positionSS : TEXCOORD0;
            };

            sampler2D _CameraDepthTexture;

            float4 _ForegroundColor;
            float4 _BackgroundColor;

            v2f vert (appdata v)
            {
                 v2f o;
                 o.positionCS = UnityObjectToClipPos(v.positionOS);
                 o.positionSS = ComputeScreenPos(o.positionCS);
                 return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float currentDepth = i.positionCS.z / i.positionCS.w;

                // sample the texture
                float2 screenUVs = i.positionSS.xy / i.positionSS.w;
                float rawDepth = tex2D(_CameraDepthTexture, screenUVs).r;

                float scene01Depth = Linear01Depth(rawDepth);

                float delta = (scene01Depth - currentDepth) / (1.0f - currentDepth);

                // float4 col = lerp(_ForegroundColor, _BackgroundColor,1 - pow(1 - delta, 2));
                float4 col = lerp(_ForegroundColor, _BackgroundColor,delta);
                col.a = 1.0f;
                return col;
            }
            ENDHLSL
        }
    }
}
