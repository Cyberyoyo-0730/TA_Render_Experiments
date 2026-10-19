// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader"CS02/01MiniShader"//Shader真正的名字，可以是路径式的格式
{
	Properties
	{
		_MainTex("MainTex",2D)="black"{}
		_Float("浮点数",Float)=0.0
		_Range("Range",Range(0.0,1.0))=0.0
		_Vector("Vector",Vector)=(1,1,1,1)
		_Color("Color",Color)=(0.5,0.5,0.5,0.5)
	}
	/*
	这是为了可以在一个Shader文件中写多种版本的Shader,但只有一个会被使用。
	提供多个版本的SubShader,Unity可以根据对应的版本选择合适的Shader
	或者配合LOD机制一起使用。
	一般写一个即可
	*/
	SubShader
	{
		Pass
		{
			CGPROGRAM//Shader代码从这里开始
			#pragma vertex vert//指定一个名为“vert”的函数为顶点Shader
			#pragma fragment frag//指定一个名为“frag”的函数为片元Shader
			#include"UnityCG.cginc"//引用Unity内置的文件，很方便，有很多现成的函数提供使用
			struct appdata{//CPU向顶点Shader提供的模型数据
				//冒号后面的是特定语义词，告诉CPU需要哪些类似的数据
				float4 vertex : POSITION;//模型空间顶点坐标
				float2 uv : TEXCOORD0;//第一套uv
				//float2 uv2 : TEXCOORD0;//第二套uv
				//float2 uv3 : TEXCOORD0;//第三套uv
				//float2 uv4 : TEXCOORD0;//第四套uv（模型最多智能有4套uv)
				float3 normal : NORMAL;//顶点法线
				//float4 color: COLOR;//顶点颜色
				//float4 targent:TANGENT；//顶点切线（模型导入unity后自动计算得到）
			};

			struct v2f{//自定义数据结构体，顶点着色器输出的数据，也是片元着色器的输入数据
				float4 pos : SV_POSITION;//输出裁剪空间下的顶点坐标数据，给光栅化使用
				float2 uv : TEXCOORD0;//通用储存器 插值器（最多可以写16个）
				float3 normal : TEXCOORD1;
			};
			/*
			Shader内的变量声明，如果跟上面Properties模块内的参数同名，就可以产生链接
			*/
			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			//顶点shader
			v2f vert(appdata v){
				v2f o;
				float4 pos_world=mul(unity_ObjectToWorld,v.vertex);//模型空间转世界空间
				float4 pos_view=mul(UNITY_MATRIX_V,pos_world);//世界空间转相机空间
				float4 pos_clip=mul(UNITY_MATRIX_P,pos_view);//转变到裁剪空间
				o.pos=pos_clip;
				//o.pos=UnityObjectToClipPos(v.vertex);//效果等于上面三行
				//o.pos=mul(UNITY_MATRIX_MVP,v,vertex);//效果等于上面三行
				o.uv=v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
				//o.uv=TTRANSFORM_TEX(v.uv,_MainTex);
				o.normal=v.normal;
				return o;
			}
			//片元Shader
			half4 frag(v2f i):SV_Target{//精度：  fixed:8（颜色）   half:16（UV,大部分向量）   float:32（坐标点）
				fixed4 col=tex2D(_MainTex,i.uv);//SV_Target表示为：片元Shader输出的目标地（渲染目标）
				return col;
			}
			ENDCG//Shader代码从这里结束
		}
	}
}