Shader "Unlit/GeometryGrass"
{
    Properties
    {
        _TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1
        [Space]
        _BladeWidth("blade width", float) = 0.05
        _BladeWidthRandom("width random", float) = 0.02
        _BladeHeight("blade height", float) = 0.5
        _BladeHeightRandom("height random", float) = 0.3
        _BColor("bottom Color", Color) = (0, 1, 0, 1)
        _TColor("top Color", Color) = (0, 1, 0, 1)
        _BendRotation("Bend rotation random", Range(0, 1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off
        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Tessellation.cginc"
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom
            #pragma hull hull
            #pragma domain domain
            #pragma target gl4.1
            //#pragma require tessellation
            // make fog work
            #pragma multi_compile_fog
            
            fixed4 _BColor;
            fixed4 _TColor;
            float _BendRotation;
            float _BladeHeight;
            float _BladeHeightRandom;	
            float _BladeWidth;
            float _BladeWidthRandom;

            geometryOutput VertexOutput(float3 pos, float2 uv)
            {
                geometryOutput o;
                o.pos = UnityObjectToClipPos(pos);
                o.uv = uv;
                return o;
            }

            float random (float2 uv)
            {
                return frac(sin(dot(uv,float2(12.9898,78.233)))*43758.5453123);
            }

            float3x3 AngleAxis3x3(float angle, float3 axis)
            {
                float c, s;
                sincos(angle, s, c);
                
                float t = 1 - c;
                float x = axis.x;
                float y = axis.y;
                float z = axis.z;

                return float3x3(
                t * x * x + c, t * x * y - s * z, t * x * z + s * y,
                t * x * y + s * z, t * y * y + c, t * y * z - s * x,
                t * x * z - s * y, t * y * z + s * x, t * z * z + c
                );
            }
            
            v2g vert (appdata v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.normal = v.normal;
                o.tangent = v.tangent;
                return o;
            }

            fixed4 frag (geometryOutput i) : SV_Target
            {
                return lerp(_BColor, _TColor, i.uv.y);
            }

            [maxvertexcount(3)]
            void geom(triangle v2g IN[3] : SV_POSITION, inout TriangleStream<geometryOutput> triStream)
            {
                geometryOutput o;
                float3 origin = IN[0].vertex;
                float3 vNormal = IN[0].normal;
                float4 vTangent = IN[0].tangent;
                float3 vBinormal = cross(vNormal, vTangent) * vTangent.w;
                float3x3 tagent2Loacl = float3x3(
                vTangent.x, vBinormal.x, vNormal.x,
                vTangent.y, vBinormal.y, vNormal.y,
                vTangent.z, vBinormal.z, vNormal.z
                );
                float3x3 raotationMatrix = AngleAxis3x3(random(origin.xz) * UNITY_TWO_PI, float3(0, 0, 1));
                float3x3 bendRotationMatrix = AngleAxis3x3(random(origin.xz) * UNITY_PI * 0.5 * _BendRotation, float3(-1, 0, 0));
                
                float height = random(origin.xz) * _BladeHeightRandom + _BladeHeight;
                float width = random(origin.zx) * _BladeWidthRandom + _BladeWidth;

                
                float3x3 tranMatrix = mul(mul(tagent2Loacl, raotationMatrix), bendRotationMatrix);
                triStream.Append(VertexOutput(origin + mul(tranMatrix, float3(width, 0, 0)), float2(0, 0)));
                triStream.Append(VertexOutput(origin + mul(tranMatrix, float3(-width, 0, 0)), float2(1, 0)));
                triStream.Append(VertexOutput(origin + mul(tranMatrix, float3(0, 0, height)), float2(0.5, 1)));
            }
            ENDCG
        }
    }
    //Fallback "Legacy Shaders/Diffuse"
}
