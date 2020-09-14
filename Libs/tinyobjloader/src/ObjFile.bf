using System;
using System.Collections;
using System.IO;

namespace tinyobj
{
	public class ObjReader
	{
		public bool Valid { get; protected set; }
		
		public String Warnings ~ delete _;
		public String Errors ~ delete _; 


		public attrib_t attrs = new .() ~ delete _;
		public List<shape_t> shapes = new .() ~ DeleteContainerAndItems!(_);
		public List<material_t> materials = new .() ~ delete _;

		public this() { }
		public ~this() { }

		public Result<void> ParseFromFile(StringView filePath)
		{
			var sr = scope StreamReader();
			switch (sr.Open(filePath))
			{
			case .Ok:
				{
					Valid = LoadObj(ref attrs, ref shapes, ref materials, out Warnings, out Errors, sr, null, true, true);
					if(Valid) return .Ok;
				}
			case .Err(let err):
				{
					Valid = false;
					Errors = "ObjReader::ParseFromFile - Couldn't open file.";
					break;
				}
			default: break;
			}
			
			return .Err;
		}

		public Result<void> ParseFromStream(Stream fs)
		{
			Valid = LoadObj(ref attrs, ref shapes, ref materials, out Warnings, out Errors, scope .(fs), null, true, true);
			if(Valid) return .Ok;

			return .Err;
		}

		public Result<void> ParseFromString(StringView str)
		{
			System.IO.StringStream ss = scope .(str, .Reference);
			var sr = scope System.IO.StreamReader(ss);
			
			Valid = LoadObj(ref attrs, ref shapes, ref materials, out Warnings, out Errors, sr, null, true, true);
			return Valid ? .Ok : .Err;
		}
	}



	public class MtlFile
	{
		public Dictionary<String, int32> materialMap = new .() ~ delete _;
		public List<material_t> materials = new .() ~ delete _;

		private this() { }
	}
}
