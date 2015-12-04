﻿Shader "NoiseTest/HLSL/NoiseTest"
{
    CGINCLUDE

    #pragma multi_compile CNOISE PNOISE SNOISE
    #pragma multi_compile _ THREED
    #pragma multi_compile _ FRACTAL

    #include "UnityCG.cginc"

    #ifdef SNOISE
        #ifdef THREED
            #include "SimplexNoise3D.cginc"
        #else
            #include "SimplexNoise2D.cginc"
        #endif
    #else
        #ifdef THREED
            #include "ClassicNoise3D.cginc"
        #else
            #include "ClassicNoise2D.cginc"
        #endif
    #endif

    v2f_img vert(appdata_base v)
    {
        v2f_img o;
        o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
        o.uv = v.texcoord.xy;
        return o;
    }

    float4 frag(v2f_img i) : SV_Target 
    {
        float2 uv = i.uv * 4.0;

        float o = 0.5;
        float s = 1.0;
        #ifdef SNOISE
        float w = 0.25;
        #else
        float w = 0.5;
        #endif

        #ifdef FRACTAL
        for (int i = 0; i < 6; i++)
        #endif
        {
            float3 coord = float3((uv + float2(0.2, 1) * _Time.y) * s, _Time.y);
            float3 period = float3(s, s, 1) * 2;

            #ifdef CNOISE
                #ifdef THREED
                    o += cnoise(coord) * w;
                #else
                    o += cnoise(coord.xy) * w;
                #endif
            #elif defined(PNOISE)
                #ifdef THREED
                    o += pnoise(coord, period) * w;
                #else
                    o += pnoise(coord.xy, period.xy) * w;
                #endif
            #else
                #ifdef THREED
                    o += snoise(coord) * w;
                #else
                    o += snoise(coord.xy) * w;
                #endif
            #endif

            s *= 2.0;
            w *= 0.5;
        }

        return float4(o, o, o, 1);
    }

    ENDCG
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}