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
    float _ContrastThreshold;

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

    float4 Sample(float2 uv)
    {
        return tex2D(_MainTex, uv);
    }

    float SampleLuminance(float2 uv)
    {
        #if defined (LUMINANCE_GREEN)
            return Sample(uv).g;
        #else
            return Sample(uv).a;
        #endif
    }

    float SampleLuminance (float2 uv, float uOffset, float vOffset)
    {
        uv += _MainTex_TexelSize * float2(uOffset, vOffset);
        return SampleLuminance(uv);
    }

    struct LuminanceData {
        float m, n, e, s, w;
        float highest, lowest, contrast;
    };

    LuminanceData SampleLuminanceNeighborhood (float2 uv)
    {
        LuminanceData l;
        l.m = SampleLuminance(uv);
        l.n = SampleLuminance(uv, 0, 1);
        l.e = SampleLuminance(uv, 1, 0);
        l.s = SampleLuminance(uv, -1,0);
        l.w = SampleLuminance(uv, -1,0);
        l.highest = max(max(max(max(l.n, l.e),l.s),l.w),l.m);
        l.lowest = min(min(min(min(l.n, l.e),l.s),l.w),l.m);
        l.contrast = l.highest = l.lowest;
        return l;
    }

    float4 ApplyFXAA (float2 uv)
    {
        //return SampleLuminance(uv);
        LuminanceData l = SampleLuminanceNeighborhood(uv);
        if (l.contrast < _ContrastThreshold)
        {
            return float4(1,0,0,0);
        }
        return l.contrast;
    }
    
    ENDCG
    
    SubShader
    {
        Cull Off
        Ztest Always
        Zwrite Off

        Pass
        { //0 luminancePass
            CGPROGRAM
            #pragma vertex VertexPorgram
            #pragma fragment FragmentProgram
            
                       
            float4 FragmentProgram (Interpolators i) : SV_Target
            {
                half4 sample = tex2D(_MainTex, i.uv);
                sample.a = LinearRgbToLuminance(saturate(sample.rgb));
                return sample;
            }
            ENDCG
        }
        
         Pass
        { //1 luminancePass
            CGPROGRAM
            #pragma vertex VertexPorgram
            #pragma fragment FragmentProgram            
            #pragma multi_compile _LUMINANCE_GREEN
                       
            float4 FragmentProgram (Interpolators i) : SV_Target
            {                
                //return tex2D(_MainTex, i.uv);
                //return Sample(i.uv).a;
                return ApplyFXAA(i.uv);
            }
            ENDCG
        }
    }
}
