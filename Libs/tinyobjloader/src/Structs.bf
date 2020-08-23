using System;
using System.Collections;

namespace tinyobj
{
	public typealias real_t = float;
	public struct index_t
	{
		public int32 vertex_index;
		public int32 normal_index;
		public int32 texcoord_index;
	}

	public class attrib_t
	{
		public List<Vector3> vertices = null ~ delete _;// 'v'(xyz)

		// For backward compatibility, we store vertex weight in separate array.
		public List<Vector3> vertex_weights = null ~ delete _;// 'v'(w)
		public List<Vector3> normals = null ~ delete _;// 'vn'
		public List<Vector2> texcoords = null ~ delete _;// 'vt'(uv)

		// For backward compatibility, we store texture coordinate 'w' in separate
		// array.
		public List<Vector2> texcoord_ws = null ~ delete _;// 'vt'(w)
		public List<Color> colors = null ~ delete _;// extension: vertex colors
	}

	public class tag_t
	{
		public String name = null ~ delete _;

		public List<int32> intValues = new .() ~ delete _;
		public List<real_t> floatValues = new .() ~ delete _;
		public List<String> stringValues = new .() ~ delete _;
	}

	public class mesh_t
	{
		public List<index_t> indices = new .() ~ delete _;
		public List<uint8> num_face_vertices = new .() ~ delete _;// The number of vertices per
										// face. 3 = triangle, 4 = quad,
										// ... Up to 255 vertices per face.

		public List<int32> material_ids = new .() ~ delete _;// per-face material ID
		public List<uint32> smoothing_group_ids = new .() ~ delete _;// per-face smoothing group
														// ID(0 = off. positive value
														// = group id)
		public List<tag_t> tags = null ~ delete _;// SubD tag
	}

	public class lines_t
	{
		// Linear flattened indices.
		public List<index_t> indices = new .() ~ delete _;// indices for vertices(poly lines)
		public List<int32> num_line_vertices = new .() ~ delete _;// The number of vertices per line.
	}

	public class points_t
	{
		public List<index_t> indices = new .() ~ delete _;// indices for points
	}

	public class shape_t
	{
		public String name = null ~ delete _;
		public mesh_t mesh = new .() ~ delete _;
		public lines_t lines= new .() ~ delete _;
		public points_t points= new .() ~ delete _;
	}

	public enum texture_type_t
	{
		None,// default
		Sphere,
		CubeTop,
		CubeBottom,
		CubeFront,
		CubeBack,
		CubeLeft,
		Right
	}

	public struct texture_option_t
	{
		public texture_type_t type;// -type (default TEXTURE_TYPE_NONE)
		public real_t sharpness;// -boost (default 1.0?)
		public real_t brightness;// base_value in -mm option (default 0)
		public real_t contrast;// gain_value in -mm option (default 1)
		public Vector3 origin_offset;// -o u [v [w]] (default 0 0 0)
		public Vector3 scale;// -s u [v [w]] (default 1 1 1)
		public Vector3 turbulence;// -t u [v [w]] (default 0 0 0)
		public int texture_resolution;// -texres resolution (No default value in the spec. We'll use -1)
		public bool clamp;// -clamp (default false)
		public char8 imfchan;// -imfchan (the default for bump is 'l' and for decal is 'm')
		public bool blendu;// -blendu (default on)
		public bool blendv;// -blendv (default on)
		public real_t bump_multiplier;// -bm (for bump maps only, default 1.0)

		// extension
		String colorspace;// Explicitly specify color space of stored texel
								 // value. Usually `sRGB` or `linear` (default empty).
	}

	public struct material_t
	{
		public String name;

		public Color ambient;
		public Color diffuse;
		public Color specular;
		public Color transmittance;
		public Color emission;
		public real_t shininess;
		public real_t ior;// index of refraction
		public real_t dissolve;// 1 == opaque; 0 == fully transparent
		// illumination model (see http://www.fileformat.info/format/material/)
		public int illum;

		//int dummy;  // Suppress padding warning.

		public String ambient_texname;// map_Ka
		public String diffuse_texname;// map_Kd
		public String specular_texname;// map_Ks
		public String specular_highlight_texname;// map_Ns
		public String bump_texname;// map_bump, map_Bump, bump
		public String displacement_texname;// disp
		public String alpha_texname;// map_d
		public String reflection_texname;// refl

		public texture_option_t ambient_texopt;
		public texture_option_t diffuse_texopt;
		public texture_option_t specular_texopt;
		public texture_option_t specular_highlight_texopt;
		public texture_option_t bump_texopt;
		public texture_option_t displacement_texopt;
		public texture_option_t alpha_texopt;
		public texture_option_t reflection_texopt;

		// PBR extension
		// http://exocortex.com/blog/extending_wavefront_mtl_to_support_pbr
		public real_t roughness;// [0, 1] default 0
		public real_t metallic;// [0, 1] default 0
		public real_t sheen;// [0, 1] default 0
		public real_t clearcoat_thickness;// [0, 1] default 0
		public real_t clearcoat_roughness;// [0, 1] default 0
		public real_t anisotropy;// aniso. [0, 1] default 0
		public real_t anisotropy_rotation;// anisor. [0, 1] default 0
		public real_t pad0;
		public String roughness_texname;// map_Pr
		public String metallic_texname;// map_Pm
		public String sheen_texname;// map_Ps
		public String emissive_texname;// map_Ke
		public String normal_texname;// norm. For normal mapping.

		public texture_option_t roughness_texopt;
		public texture_option_t metallic_texopt;
		public texture_option_t sheen_texopt;
		public texture_option_t emissive_texopt;
		public texture_option_t normal_texopt;

		public int pad2;

		public Dictionary<String, String> unknown_parameter;
	}


	// -----------------------------------------------------------


	struct vertex_index_t
	{
		public int32 v_idx , vt_idx , vn_idx;
	}

	struct face_t
	{
		public uint32 smoothing_group_id;// smoothing group id. 0 = smoothing groupd is off.
		public int32 pad_;
		public List<vertex_index_t> vertex_indices;// face vertex indices.
	}

	struct __line_t
	{
		public List<vertex_index_t> vertex_indices;
	}

	struct __points_t
	{
		public List<vertex_index_t> vertex_indices;
	}

	 //
	 // Manages group of primitives(face, line, points, ...)
	class PrimGroup
	{
		public List<face_t> faceGroup = new .() ~ delete _;
		public List<__line_t> lineGroup = new .() ~ delete _;
		public List<__points_t> pointsGroup = new .() ~ delete _;

		public void clear()
		{
			for(var fg in faceGroup) delete fg.vertex_indices;
			for(var lg in lineGroup) delete lg.vertex_indices;
			for(var pg in pointsGroup) delete pg.vertex_indices;

			faceGroup.Clear();
			lineGroup.Clear();
			pointsGroup.Clear();
		}

		public bool Empty=> faceGroup.IsEmpty && lineGroup.IsEmpty && pointsGroup.IsEmpty;

		// TODO(syoyo): bspline, surface, ...
	}
}
