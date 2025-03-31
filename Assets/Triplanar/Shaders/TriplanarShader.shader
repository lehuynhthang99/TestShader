Shader "Unlit/TriplanarShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _BaseTex ("Texture", 2D) = "white" {}
        _Tile ("Texture tiling", Float) = 1
        _BlendPower ("Triplanar blending", Float) = 10
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
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normal : TEXTCOORD1;
            };

            sampler2D _BaseTex;
            float4 _BaseTex_ST;
            float4 _BaseColor;
            float _Tile;
            float _BlendPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldDir(v.normal);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 xAxisUV = i.worldPos.zy * _Tile;
                float2 yAxisUV = i.worldPos.xz * _Tile;
                float2 zAxisUV = i.worldPos.xy * _Tile;

                float4 xSample = tex2D(_BaseTex, xAxisUV);
                float4 ySample = tex2D(_BaseTex, yAxisUV);
                float4 zSample = tex2D(_BaseTex, zAxisUV);

                float3 weights = pow(abs(i.normal), _BlendPower);
                weights /= (weights.x + weights.y + weights.z);

                // sample the texture
                float4 col = xSample * weights.x + ySample * weights.y + zSample * weights.z;
                return col;
            }
            ENDHLSL
        }
    }
}
