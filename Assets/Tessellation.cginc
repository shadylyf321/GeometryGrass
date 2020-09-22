struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
};

struct v2g
{
    float4 vertex : SV_POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
};

struct geometryOutput
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
};

struct TessellationFactors
{
    float edge[3] : SV_TessFactor;
    float inside : SV_InsideTessFactor;
};

v2g tessVert(appdata v)
{
    v2g o;
    o.vertex = v.vertex;
    o.normal = v.normal;
    o.tangent = v.tangent;
    return o;
}

float _TessellationUniform;

TessellationFactors patchConstantFunc(InputPatch<appdata, 3> patch)
{
    TessellationFactors f;
    f.edge[0] = _TessellationUniform;
    f.edge[1] = _TessellationUniform;
    f.edge[2] = _TessellationUniform;
    f.inside = _TessellationUniform;
    return f;
}



[UNITY_domain("tri")]
[UNITY_outputcontrolpoints(3)]
[UNITY_outputtopology("triangle_cw")]
[UNITY_partitioning("integer")]
[UNITY_patchconstantfunc("patchConstantFunc")]
appdata hull(InputPatch<appdata, 3> patch, uint id : SV_OutputControlPointID)
{
    return patch[id];
}

[UNITY_domain("tri")]
v2g domain(TessellationFactors factors, OutputPatch<appdata, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
{
    appdata v;
    // #define DOMAIN_PROGRAME_INTERPOLATE(filedName)\
    // v.filedName = patch[0].filedName * barycentricCoordinates.x + \
    //               patch[1].filedName * barycentricCoordinates.y + \
    //               patch[2].filedName * barycentricCoordinates.z;
    // DOMAIN_PROGRAME_INTERPOLATE(vertex);
    // DOMAIN_PROGRAME_INTERPOLATE(normal);
    // DOMAIN_PROGRAME_INTERPOLATE(tangent);
    v.vertex = patch[0].vertex;
    return tessVert(v);
}