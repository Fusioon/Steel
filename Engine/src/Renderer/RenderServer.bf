using System;
using SteelEngine.ECS.Components;

namespace SteelEngine.Renderer
{
	public abstract class RenderServer : Singleton<RenderServer>
	{
		public abstract void DrawMesh(Matrix44 transform, Material mat, Mesh m);

		public abstract void DrawCamera(Camera3D cam);

		public abstract void DrawCamera(Camera2D cam);
		public abstract void DrawSprite(Transform2D transform, SteelEngine.Renderer.Sprite sprite);

		//public abstract void DrawText(uint32 x, uint32 y, uint32 height, StringView message, Color4f color, Font font = null);
	}
}
