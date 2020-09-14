namespace SteelEngine.ECS.Components
{
	public class Drawable3dComponent : BaseComponent
	{
		public Mesh Mesh
		{
			get => _mesh;
			set { _mesh.DisposeSafe(); _mesh = value..AddRef(); }
		}

		public Material Material
		{
			get => _material;
			set { _material.DisposeSafe(); _material = value..AddRef(); }
		}

		Mesh _mesh ~ _.DisposeSafe();
		Material _material ~ _.DisposeSafe();

		public void SetMeshAndMaterial(Mesh mesh, Material mat)
		{
			_mesh.DisposeSafe();
			_material.DisposeSafe();

			_mesh = mesh..AddRef();
			_material = mat..AddRef();
		}

		public this()
		{
			
		}

		public void Draw(Matrix44 transform)
		{
			SteelEngine.Renderer.RenderServer.DrawMesh(transform, _material, _mesh);
		}
	}
}
