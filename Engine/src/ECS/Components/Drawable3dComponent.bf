namespace SteelEngine.ECS.Components
{
	public class Drawable3dComponent : BaseComponent
	{
		public Mesh Mesh
		{
			get => _mesh;
			set { _mesh.UnrefSafe(); _mesh = value..AddRef(); }
		}

		public Material Material
		{
			get => _material;
			set { _material.UnrefSafe(); _material = value..AddRef(); }
		}

		Mesh _mesh ~ _.UnrefSafe();
		Material _material ~ _.UnrefSafe();

		public void SetMeshAndMaterial(Mesh mesh, Material mat)
		{
			_mesh.UnrefSafe();
			_material.UnrefSafe();

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
