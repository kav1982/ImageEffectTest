Shader "Hidden/FXAA"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;

    struct VertexData
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct Interpolators
    {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
    };

    Interpolators VertexPorgram (VertexData v)
    {
        Interpolators i;
        i.pos = UnityObjectToClipPos(v.vertex);
        i.uv = v.uv;
        return i;       
    }
    
    ENDCG
    
    SubShader
    {
        Cull Off
        Ztest Always
        Zwrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
                       


            float4 FragmentProgram (Interpolators i) : SV_Target
            {
                float4 sample = tex2D(_MainTex, i.uv);
                return sample;
            }
            ENDCG
        }
    }
}
