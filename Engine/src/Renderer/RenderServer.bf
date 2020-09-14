using System;
using SteelEngine.ECS.Components;

namespace SteelEngine.Renderer
{
	public class RenderServer : Singleton<RenderServer>
	{
		public static void DrawText(uint32 x, uint32 y, uint32 height, StringView message, Color4f color, Font font = null)
		{

		}

		public static void DrawMesh(Matrix44 transform, Material mat, Mesh m)
		{
			Instance.DrawMeshInstance(transform, mat, m);
		}

		protected virtual void DrawMeshInstance(Matrix44 transform, Material mat, Mesh m)
		{

		}
	}
}
