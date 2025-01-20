Shader "UI/PixelBlur"
{
    Properties
    {
         _MainTex ("Sprite Texture", 2D) = "white" {}
         _Color ("Tint", Color) = (1,1,1,1)
         _Step ("Step", Range(0.0001, 1)) = 0.05
    }
    SubShader
    {
        Tags
        { 
            "Queue" = "Transparent" 
            "RenderType" = "Transparent" 
        }

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "UnityCG.cginc"

            struct appdata
            {
                half4 vertex : POSITION;
                half2 uv : TEXCOORD0;
                // half4 color    : COLOR;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                half4 vertex : SV_POSITION;
                half4 color    : COLOR;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            float _Step;

           
            half4 invLerp(half4 from, half4 to, half4 value) 
            {
                return (value - from) / (to - from);
            }

            half my_smoothstep(half x)
            {
                return x * x * (3.0 - 2.0 * x);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // o.color = _Color;
                
                return o;
            }



            half4 frag(v2f i) : SV_Target
            {
                //animation repeat every 5.0 sec
                // float timeMod = mod(_Time.y, 5.0f);
                i.uv = i.uv - fmod(i.uv, _Step );

                return tex2D(_MainTex, i.uv) * _Color;
            }
            ENDHLSL
        }
    }
}