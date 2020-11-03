using System;
using System.IO;
using System.Collections;

namespace tinyobj
{
	public struct Vector2
	{
		public real_t x, y;
	}



	public struct Vector3
	{
		public real_t x, y, z;
	}


	public struct Color
	{
		public real_t r, g, b;
	}

	public delegate bool MaterialReaderDelegate(String matId, List<material_t> materials, Dictionary<String, int32> matDict, out String warn, out String err);

	static
	{
		[Inline]
		static bool IsWhitespace(char8 c)
		{
			return c == ' ' || c == '\t';
		}
		[Inline]
		static bool IsNewline(char8 c)
		{
			return c == '\r' || c == '\n' || c == '\0';
		}
		[Inline]
		static bool IsNumeric(char8 c)
		{
			return (c >= '0' && c <= '9');
		}



		static void SkipPosNegSign(String input, ref int i)
		{
			while (i < input.Length)
			{
				if (!(input[i] == '+' && input[i] == '-'))
				{
					i++;
					break;
				}
				i++;
			}
		}

		static bool ParseReal(String input, ref int i, out real_t res)
		{
			SkipWhitepace(input, ref i);

			let start = i;
			SkipPosNegSign(input, ref i);
			while (i < input.Length)
			{
				if (!(IsNumeric(input[i]) || input[i] == '.'))
				{
					break;
				}
				i++;
			}

			if (i != start)
			{
				switch (real_t.Parse(StringView(input, start, i - start)))
				{
				case .Ok(let val): res = val; return true;
				default: break;
				}
			}

			res = default;
			return false;
		}

		static bool ParseInt(String input, ref int i, out int32 res)
		{
			SkipWhitepace(input, ref i);
			let start = i;
			SkipPosNegSign(input, ref i);
			while (i < input.Length)
			{
				if (!IsNumeric(input[i])) break;

				i++;
			}
			switch (int.Parse(StringView(input, start, i - start)))
			{
			case .Ok(let val): res = (.)val; return true;
			default: break;
			}
			res = default;
			return false;
		}

		static bool FixIndex(int idx, int n, out int32 res)
		{
			if (idx > 0)
			{
				res = (.)(idx - 1);
				return true;
			}

			if (idx < 0)
			{
				res = (.)(n + idx);
				return true;
			}

			res = ?;
			return false;
		}

		static bool ParseVertexWithColor(out Vector3 vert, out Color col, String input, ref int i)
		{
			vert = default;
			col = default;

			ParseReal(input, ref i, out vert.x);
			ParseReal(input, ref i, out vert.y);
			ParseReal(input, ref i, out vert.z);

			let foundColor = ParseReal(input, ref i, out col.r) && ParseReal(input, ref i, out col.g) && ParseReal(input, ref i, out col.b);
			if (!foundColor)
			{
				col.r = col.g = col.b = 1;
			}

			return foundColor;
		}

		static int32 pnpoly(Span<Vector2> vert, Vector2 test)
		{
			int i, j, c = 0;
			for (i = 0,j = vert.Length - 1; i < vert.Length; j = i++)
			{
				if (((vert[i].y > test.y) != (vert[j].y > test.y)) &&
					(test.x <
					(vert[j].x - vert[i].x) * (test.y - vert[i].y) / (vert[j].y - vert[i].y) +
					vert[i].x))
					c = (c == 0) ? 1 : 0;
			}
			return (.)c;
		}

		static bool ExportGroupsToShape(ref shape_t shape, PrimGroup primGroup, List<tag_t> tags, int32 materialId, String name, bool triangulate, List<Vector3> v)
		{
			if (primGroup.Empty) return false;

			shape.name = name;

			// polygon
			if (!primGroup.faceGroup.IsEmpty)
			{
			  // Flatten vertices and indices
				for (int i = 0; i < primGroup.faceGroup.Count; i++)
				{
					ref face_t face = ref primGroup.faceGroup[i];

					int npolys = face.vertex_indices.Count;

					if (npolys < 3)
					{
					  // Face must have 3+ vertices.
						continue;
					}

					vertex_index_t i0 = face.vertex_indices[0];
					vertex_index_t i1 = default;
					vertex_index_t i2 = face.vertex_indices[1];

					if (triangulate)
					{
					  // find the two axes to work in
						int[2] axes = .(1, 2);
						for (int k = 0; k < npolys; ++k)
						{
							i0 = face.vertex_indices[(k + 0) % npolys];
							i1 = face.vertex_indices[(k + 1) % npolys];
							i2 = face.vertex_indices[(k + 2) % npolys];
							int vi0 = i0.v_idx;
							int vi1 = i1.v_idx;
							int vi2 = i2.v_idx;

							if (((3 * vi0 + 2) >= v.Count) || ((3 * vi1 + 2) >= v.Count) ||
								((3 * vi2 + 2) >= v.Count))
							{
							  // Invalid triangle.
							  // FIXME(syoyo): Is it ok to simply skip this invalid triangle?
								continue;
							}

							Vector3 v0 = v[vi0];
							Vector3 v1 = v[vi1];
							Vector3 v2 = v[vi2];

							//real_t v0x = v[vi0 * 3 + 0];
							//real_t v0y = v[vi0 * 3 + 1];
							//real_t v0z = v[vi0 * 3 + 2];
							//real_t v1x = v[vi1 * 3 + 0];
							//real_t v1y = v[vi1 * 3 + 1];
							//real_t v1z = v[vi1 * 3 + 2];
							//real_t v2x = v[vi2 * 3 + 0];
							//real_t v2y = v[vi2 * 3 + 1];
							//real_t v2z = v[vi2 * 3 + 2];
							real_t e0x = v1.x - v0.x;
							real_t e0y = v1.y - v0.y;
							real_t e0z = v1.z - v0.z;
							real_t e1x = v2.x - v1.x;
							real_t e1y = v2.y - v1.y;
							real_t e1z = v2.z - v1.z;
							real_t cx = Math.Abs(e0y * e1z - e0z * e1y);
							real_t cy = Math.Abs(e0z * e1x - e0x * e1z);
							real_t cz = Math.Abs(e0x * e1y - e0y * e1x);
							const real_t epsilon = real_t.Epsilon;
							if (cx > epsilon || cy > epsilon || cz > epsilon)
							{
							  // found a corner
								if (cx > cy && cx > cz)
								{
								} else
								{
									axes[0] = 0;
									if (cz > cx && cz > cy) axes[1] = 1;
								}
								break;
							}
						}

						real_t area = 0;
						for (int k = 0; k < npolys; ++k)
						{
							i0 = face.vertex_indices[(k + 0) % npolys];
							i1 = face.vertex_indices[(k + 1) % npolys];
							int vi0 = i0.v_idx;
							int vi1 = i1.v_idx;
							if (((vi0 * 3 + axes[0]) >= v.Count) ||
								((vi0 * 3 + axes[1]) >= v.Count) ||
								((vi1 * 3 + axes[0]) >= v.Count) ||
								((vi1 * 3 + axes[1]) >= v.Count))
							{
							  // Invalid index.
								continue;
							}
							real_t v0x = v[vi0].x;
							real_t v0y = v[vi0].y;
							real_t v1x = v[vi1].x;
							real_t v1y = v[vi1].y;
							area += (v0x * v1y - v0y * v1x) * (real_t)(0.5);
						}

						face_t remainingFace = face;// copy
						int guess_vert = 0;
						vertex_index_t[3] ind = ?;

						Vector2[3] vert = ?;
						//real_t[3] vx = ?;
						//real_t[3] vy = ?;

						// How many iterations can we do without decreasing the remaining
						// vertices.
						int remainingIterations = face.vertex_indices.Count;
						int previousRemainingVertices = remainingFace.vertex_indices.Count;

						while (remainingFace.vertex_indices.Count > 3 &&
							remainingIterations > 0)
						{
							npolys = remainingFace.vertex_indices.Count;
							if (guess_vert >= npolys)
							{
								guess_vert -= npolys;
							}

							if (previousRemainingVertices != npolys)
							{
							  // The number of remaining vertices decreased. Reset counters.
								previousRemainingVertices = npolys;
								remainingIterations = npolys;
							} else
							{
							  // We didn't consume a vertex on previous iteration, reduce the
							  // available iterations.
								remainingIterations--;
							}

							for (int k = 0; k < 3; k++)
							{
								ind[k] = remainingFace.vertex_indices[(guess_vert + k) % npolys];
								int vi = ind[k].v_idx;
								if (((vi * 3 + axes[0]) >= v.Count) ||
									((vi * 3 + axes[1]) >= v.Count))
								{
								  // ???
									vert[k].x = (real_t)(0.0);
									vert[k].y = (real_t)(0.0);
								} else
								{
									vert[k].x = v[vi].x;//[vi * 3 + axes[0]];
									vert[k].y = v[vi].y;//v[vi * 3 + axes[1]];
								}
							}
							real_t e0x = vert[1].x - vert[0].x;
							real_t e0y = vert[1].y - vert[0].y;
							real_t e1x = vert[2].x - vert[1].x;
							real_t e1y = vert[2].y - vert[1].y;
							real_t cross = e0x * e1y - e0y * e1x;
							// if an internal angle
							if (cross * area < (real_t)(0.0))
							{
								guess_vert += 1;
								continue;
							}

							// check all other verts in case they are inside this triangle
							bool overlap = false;
							for (int otherVert = 3; otherVert < npolys; ++otherVert)
							{
								int idx = (guess_vert + otherVert) % npolys;

								if (idx >= remainingFace.vertex_indices.Count)
								{
								  // ???
									continue;
								}

								int ovi = remainingFace.vertex_indices[idx].v_idx;

								if (((ovi * 3 + axes[0]) >= v.Count) ||
									((ovi * 3 + axes[1]) >= v.Count))
								{
								  // ???
									continue;
								}
								Vector2 test = ?;
								test.x = v[ovi].x;
								test.y = v[ovi].y;

								if (pnpoly(Span<Vector2>(&vert, vert.Count), test) == 0)
								{
									overlap = true;
									break;
								}
							}

							if (overlap)
							{
								guess_vert += 1;
								continue;
							}

							// this triangle is an ear
							{
								index_t idx0, idx1, idx2;
								idx0.vertex_index = ind[0].v_idx;
								idx0.normal_index = ind[0].vn_idx;
								idx0.texcoord_index = ind[0].vt_idx;
								idx1.vertex_index = ind[1].v_idx;
								idx1.normal_index = ind[1].vn_idx;
								idx1.texcoord_index = ind[1].vt_idx;
								idx2.vertex_index = ind[2].v_idx;
								idx2.normal_index = ind[2].vn_idx;
								idx2.texcoord_index = ind[2].vt_idx;

								shape.mesh.indices.Add(idx0);
								shape.mesh.indices.Add(idx1);
								shape.mesh.indices.Add(idx2);

								shape.mesh.num_face_vertices.Add(3);
								shape.mesh.material_ids.Add(materialId);
								shape.mesh.smoothing_group_ids.Add(face.smoothing_group_id);
							}

							// remove v1 from the list
							int removed_vert_index = (guess_vert + 1) % npolys;
							while (removed_vert_index + 1 < npolys)
							{
								remainingFace.vertex_indices[removed_vert_index] =
									remainingFace.vertex_indices[removed_vert_index + 1];
								removed_vert_index += 1;
							}
							//remainingFace.vertex_indices.pop_back();
							remainingFace.vertex_indices.PopBack();
						}

						if (remainingFace.vertex_indices.Count == 3)
						{
							i0 = remainingFace.vertex_indices[0];
							i1 = remainingFace.vertex_indices[1];
							i2 = remainingFace.vertex_indices[2];
							{
								index_t idx0, idx1, idx2;
								idx0.vertex_index = i0.v_idx;
								idx0.normal_index = i0.vn_idx;
								idx0.texcoord_index = i0.vt_idx;
								idx1.vertex_index = i1.v_idx;
								idx1.normal_index = i1.vn_idx;
								idx1.texcoord_index = i1.vt_idx;
								idx2.vertex_index = i2.v_idx;
								idx2.normal_index = i2.vn_idx;
								idx2.texcoord_index = i2.vt_idx;

								shape.mesh.indices.Add(idx0);
								shape.mesh.indices.Add(idx1);
								shape.mesh.indices.Add(idx2);

								shape.mesh.num_face_vertices.Add(3);
								shape.mesh.material_ids.Add(materialId);
								shape.mesh.smoothing_group_ids.Add(face.smoothing_group_id);
							}
						}
					} else
					{
						for (int k = 0; k < npolys; k++)
						{
							index_t idx = ?;
							idx.vertex_index = face.vertex_indices[k].v_idx;
							idx.normal_index = face.vertex_indices[k].vn_idx;
							idx.texcoord_index = face.vertex_indices[k].vt_idx;
							shape.mesh.indices.Add(idx);
						}

						shape.mesh.num_face_vertices.Add((.)npolys);
						shape.mesh.material_ids.Add(materialId);// per face
						shape.mesh.smoothing_group_ids.Add(face.smoothing_group_id);// per face
					}
				}

				shape.mesh.tags = new .(tags.GetEnumerator());
			}

			// line
			if (!primGroup.lineGroup.IsEmpty)
			{
			  // Flatten indices
				for (int i = 0; i < primGroup.lineGroup.Count; i++)
				{
					for (int j = 0; j < primGroup.lineGroup[i].vertex_indices.Count;
						j++)
					{
						ref vertex_index_t vi = ref primGroup.lineGroup[i].vertex_indices[j];

						index_t idx;
						idx.vertex_index = vi.v_idx;
						idx.normal_index = vi.vn_idx;
						idx.texcoord_index = vi.vt_idx;

						shape.lines.indices.Add(idx);
					}

					shape.lines.num_line_vertices.Add((.)primGroup.lineGroup[i].vertex_indices.Count);
				}
			}

			// points
			if (!primGroup.pointsGroup.IsEmpty)
			{
			  // Flatten & convert indices
				for (int i = 0; i < primGroup.pointsGroup.Count; i++)
				{
					for (int j = 0; j < primGroup.pointsGroup[i].vertex_indices.Count;
						j++)
					{
						ref vertex_index_t vi = ref primGroup.pointsGroup[i].vertex_indices[j];

						index_t idx;
						idx.vertex_index = vi.v_idx;
						idx.normal_index = vi.vn_idx;
						idx.texcoord_index = vi.vt_idx;

						shape.points.indices.Add(idx);
					}
				}
			}

			return true;
		}


		static StringView ParseString(String linebuf, ref int i)
		{
			SkipWhitepace(linebuf, ref i);
			let start = i;
			while (i < linebuf.Length)
			{
				if (IsWhitespace(linebuf[i])) break;

				i++;
			}
			if (start < i)
			{
				return .(linebuf, start, i - start);
			}
			return .();
		}

		static bool ParseTriple(String input, ref int i, int vsize, int vnsize, int vtsize, out vertex_index_t ret)
		{
			ret = ?;

			int32 idx;
			vertex_index_t vi = ?;

			if (!ParseInt(input, ref i, out idx) || !FixIndex(idx, vsize, out vi.v_idx))
			{
				return false;
			}

			if (i == input.Length || input[i] != '/')
			{
				ret = vi;
				return true;
			}
			i++;

			// i//k
			if (input[i] == '/')
			{
				i++;
				if (!ParseInt(input, ref i, out idx) || !FixIndex(idx, vnsize, out vi.vn_idx))
				{
					return false;
				}

				ret = vi;
				return true;
			}

			// i/j/k or i/j
			if (!ParseInt(input, ref i, out idx) || !FixIndex(idx, vtsize, out vi.vt_idx))
			{
				return false;
			}

			if (i == input.Length || input[i] != '/')
			{
				ret = vi;
				return true;
			}

			// i/j/k
			i++;// skip '/'
			if (!ParseInt(input, ref i, out idx) || !FixIndex(idx, vnsize, out vi.vn_idx))
			{
				return false;
			}


			ret = vi;
			return true;
		}

		static bool SplitString(String linebuf, ref int i, List<String> files)
		{
			SkipWhitepace(linebuf, ref i);

			var start = i;
			while (i < linebuf.Length)
			{
				if (linebuf[i] == ' ')
				{
					if (start < i)
					{
						files.Add(new String(linebuf, start, i - start));
						start = i + 1;
					}
				}
			}
			if (start < i)
			{
				files.Add(new String(linebuf, start, i - start));
			}

			return files.Count > 0;
		}

		private static char8* SkipWhitepace(String input, ref int i)
		{
			while (i < input.Length)
			{
				if (!IsWhitespace(input[i]))
				{
					break;
				}

				i++;
			}

			return input.Ptr + i;
		}

		public static bool LoadObj(ref attrib_t attrib, ref List<shape_t> shapes, ref List<material_t> materials, out String warnings, out String errors, StreamReader reader,
			MaterialReaderDelegate readMatFn, bool triangulate, bool defaultVcolsFallback)
		{
			String warn = scope .();
			String err = scope .();

			errors = null;
			warnings = null;

			List<Vector3> v = scope .();
			List<Vector3> vn = scope .();
			List<Vector2> vt = scope .();
			List<Color> vc = scope .();
			List<tag_t> tags = scope .();
			PrimGroup primGroup = scope .();
			String name = null;

			// material
			Dictionary<String, int32> materialMap = scope .();
			int32 material = -1;

			// smoothing group id
			uint32 currentSmoothingId = 0;// Initial value. 0 means no smoothing.

			int greatest_v_idx = -1;
			int greatest_vn_idx = -1;
			int greatest_vt_idx = -1;

			shape_t shape = new .();

			uint lineNum = 0;
			String linebuf = scope .();

			bool foundAllColors = true;

			while (!reader.EndOfStream)
			{
				int i = 0;
				linebuf.Clear();
				reader.ReadLine(linebuf);
				lineNum++;

				if (linebuf.Length > 0)
				{
					if (linebuf[linebuf.Length - 1] == '\n') linebuf.Length--;
					// @TODO - check validity?
					if (linebuf[linebuf.Length - 1] == '\r') linebuf.Length--;
				}

				if (linebuf.IsEmpty) continue;

				let token = SkipWhitepace(linebuf, ref i);
				if (i >= linebuf.Length) continue;// Empty line
				if (linebuf[0] == '#') continue;// Skip comment line

				// Vertex
				if (token[0] == 'v' && IsWhitespace(token[1]))
				{
					i += 2;
					Vector3 vert;
					Color col;

					foundAllColors &= ParseVertexWithColor(out vert, out col, linebuf, ref i);

					v.Add(vert);

					if (foundAllColors || defaultVcolsFallback)
					{
						vc.Add(col);
					}

					continue;
				}

				// normal
				if (token[0] == 'v' && token[1] == 'n' && IsWhitespace(token[2]))
				{
					i += 3;
					Vector3 norm;
					ParseReal(linebuf, ref i, out norm.x);
					ParseReal(linebuf, ref i, out norm.y);
					ParseReal(linebuf, ref i, out norm.z);
					vn.Add(norm);

					continue;
				}

				// textcoord
				if (token[0] == 'v' && token[1] == 't' && IsWhitespace(token[2]))
				{
					i += 3;
					Vector2 coord;
					ParseReal(linebuf, ref i, out coord.x);
					ParseReal(linebuf, ref i, out coord.y);
					vt.Add(coord);

					continue;
				}

				// line
				if (token[0] == 'l' && IsWhitespace(token[1]))
				{
					i += 2;
					//__line_t line;
					err.AppendF("Lines are not currently not supported! Line: {0}\n", lineNum);
				}

				// points
				if (token[0] == 'p' && IsWhitespace(token[1]))
				{
					i += 2;
					//__points_t pts;
					err.AppendF("Points are not currently not supported! Line: {0}\n", lineNum);
				}

				// faces
				// @TODO - priority
				if (token[0] == 'f' && IsWhitespace(token[1]))
				{
					i += 2;
					SkipWhitepace(linebuf, ref i);
					face_t face = .();
	
					face.smoothing_group_id = currentSmoothingId;
					face.vertex_indices = new .();
					
					while (i < linebuf.Length && !IsNewline(linebuf[i]))
					{
						vertex_index_t vi;
						if (!ParseTriple(linebuf, ref i, v.Count, vn.Count, vt.Count, out vi))
						{
							err.AppendF("Failed to parse `f' line(e.g. zero value for face index. line {0}).", lineNum);
							return false;
						}

						greatest_v_idx = greatest_v_idx > vi.v_idx ? greatest_v_idx : vi.v_idx;
						greatest_vn_idx = greatest_vn_idx > vi.vn_idx ? greatest_vn_idx : vi.vn_idx;
						greatest_vt_idx = greatest_vt_idx > vi.vt_idx ? greatest_vt_idx : vi.vt_idx;

						face.vertex_indices.Add(vi);
						//Console.Write("{0}/{1}/{2}\t", vi.v_idx, vi.vt_idx, vi.vn_idx);
						SkipWhitepace(linebuf, ref i);
					}
					//Console.WriteLine();
					// replace with emplace_back + std::move on C++11
					primGroup.faceGroup.Add(face);
				}

				// use mtl
				if (linebuf.IndexOf("usemtl ", i) >= i)
				{
					i += 6;
					String namebuf = scope .(ParseString(linebuf, ref i));

					int32 newMaterialId = -1;
					if (!materialMap.TryGetValue(namebuf, out newMaterialId))
					{
						warn.AppendF("material '{0}' not found in .mtl\n", namebuf);
					}

					if (newMaterialId != material)
					{
					  // Create per-face material. Thus we don't add `shape` to `shapes` at
					  // this time.
					  // just clear `faceGroup` after `exportGroupsToShape()` call.
						ExportGroupsToShape(ref shape, primGroup, tags, material, name, triangulate, v);

						for ( var fg in primGroup.faceGroup) delete fg.vertex_indices;

						primGroup.faceGroup.Clear();
						material = newMaterialId;
					}

					continue;
				}

				// load mtl
				if (linebuf.IndexOf("mtlib ", i) >= i)
				{
					if (readMatFn == null) continue;

					i += 7;
					List<String> files = scope .();
					if (!SplitString(linebuf, ref i, files))
					{
						warn.AppendF("Looks like empty filename for mtllib. Use default material (line {0}.)\n", lineNum);
					}
					else
					{
						bool found = false;

						for (var f in files)
						{
							String warnMtl;
							String errorMtl;

							found |= readMatFn(f, materials, materialMap, out warnMtl, out errorMtl);
							if (warnMtl != null) warn.Append(warnMtl);
							if (errorMtl != null) errors.Append(errorMtl);

							if (found) break;
						}

						if (!found)
						{
							warn.Append("Failed to load material file(s). Use default material.\n");
						}
					}
					continue;
				}

				if (token[0] == 'g' && IsWhitespace(token[1]))
				{
					let ret = ExportGroupsToShape(ref shape, primGroup, tags, material, name, triangulate, v);
					(void)ret;
					if(ret == false) delete shape; 

					if (shape.mesh.indices.Count > 0)
					{
						shapes.Add(shape);
					}

					shape = new .();

					// material = -1;
					primGroup.clear();

					List<String> names = scope .();

					while (!IsWhitespace(linebuf[i]))
					{
						let str = ParseString(linebuf, ref i);


						names.Add(scope:: .(str));
					}

					// names[0] must be 'g'

					if (names.Count < 2)
					{
						// 'g' with empty names
						warn.AppendF("Empty group name. line: {0}\n", lineNum);
						name = String.Empty;
					}
					else
					{
						name.Clear();

						// tinyobjloader does not support multiple groups for a primitive.
						// Currently we concatinate multiple group names with a space to get
						// single group name.

						for (int j = 2; j < names.Count; j++)
						{
							name.Append(" ", names[i]);
						}
					}

					continue;
				}

				if (token[0] == 'o' && IsWhitespace(token[1]))
				{
					let ret = ExportGroupsToShape(ref shape, primGroup, tags, material, name, triangulate, v);
					(void)ret;

					

					if (shape.mesh.indices.Count > 0 || shape.lines.indices.Count > 0 ||
						shape.points.indices.Count > 0)
					{
						shapes.Add(shape);
					}
					if(ret == false) delete shape;
					// material = -1;
					primGroup.clear();
					shape = new .();

					// @TODO { multiple object name? }
					i += 2;

					name = new .(linebuf, i);

					continue;
				}

				if (token[0] == 't' && IsWhitespace(token[1]))
				{
					// @TODO
					err.AppendF("Tags are not supported! Line: {0}\n", lineNum);

					 //const int max_tag_nums = 8192;  // FIXME(syoyo): Parameterize.
					//tag_t tag;

					//token += 2;

					//tag.name = parseString(&token);

					//tag_sizes ts = parseTagTriple(&token);

					//if (ts.num_ints < 0) {
					//	ts.num_ints = 0;
					//}
					//if (ts.num_ints > max_tag_nums) {
					//	ts.num_ints = max_tag_nums;
					//}

					//if (ts.num_reals < 0) {
					//	ts.num_reals = 0;
					//}
					//if (ts.num_reals > max_tag_nums) {
					//	ts.num_reals = max_tag_nums;
					//}

					//if (ts.num_strings < 0) {
					//	ts.num_strings = 0;
					//}
					//if (ts.num_strings > max_tag_nums) {
					//	ts.num_strings = max_tag_nums;
					//}

					//tag.intValues.resize(static_cast<size_t>(ts.num_ints));

					//for (size_t i = 0; i < static_cast<size_t>(ts.num_ints); ++i) {
					//	tag.intValues[i] = parseInt(&token);
					//}

					//tag.floatValues.resize(static_cast<size_t>(ts.num_reals));
					//for (size_t i = 0; i < static_cast<size_t>(ts.num_reals); ++i) {
					//	tag.floatValues[i] = parseReal(&token);
					//}

					//tag.stringValues.resize(static_cast<size_t>(ts.num_strings));
					//for (size_t i = 0; i < static_cast<size_t>(ts.num_strings); ++i) {
					//	tag.stringValues[i] = parseString(&token);
					//}

					//tags.push_back(tag);

					continue;
				}

				if (token[0] == 's' && IsWhitespace(token[1]))
				{
					// @TODO
					//err.AppendF("Smoothing groups are not supported! Line: {0}\n", lineNum);

					// smoothing group id
					i += 2;

					SkipWhitepace(linebuf, ref i);
					if (i >= linebuf.Length) continue;


					if (linebuf[i] == '\0') continue;
					if (IsNewline(linebuf[0])) continue;

					if (linebuf.IndexOf("off", i) >= i)
					{
					}
					else
					{
						int32 smGroupId;
						if (ParseInt(linebuf, ref i, out smGroupId))
						{
							if(smGroupId < 0)
							{
								warn.AppendF("Smoothing group id not valid! Line: {0}.", lineNum);
								currentSmoothingId = 0;
							}
							else
							{
								currentSmoothingId = (.)smGroupId;
							}
						}
						else
						{
							warn.AppendF("Failed to parse smoothing group value! Line: {0}.", lineNum);
						}
					}

					continue;
				}
			}

			// not all vertices have colors, no default colors desired? -> clear colors
			if (!foundAllColors && !defaultVcolsFallback)
			{
				vc.Clear();
			}

			if (greatest_v_idx >= v.Count)
			{
				warn.AppendF("Vertex indices out of bounds (line {0}.)\n", lineNum);
			}
			if (greatest_vn_idx >= vn.Count)
			{
				warn.AppendF("Vertex normal indices out of bounds (line {0}.)\n", lineNum);
			}
			if (greatest_vt_idx >= vt.Count)
			{
				warn.AppendF("Vertex texcoord indices out of bounds (line {0}.)\n", lineNum);
			}

			bool ret = ExportGroupsToShape(ref shape, primGroup, tags, material, name, triangulate, v);
			// exportGroupsToShape return false when `usemtl` is called in the last
			// line.
			// we also add `shape` to `shapes` when `shape.mesh` has already some
			// faces(indices)
			if (ret || shape.mesh.indices.Count > 0)
			{// FIXME(syoyo): Support other prims(e.g. lines)
				shapes.Add(shape);
			}
			primGroup.clear();// for safety

			if (!warn.IsEmpty) warnings = new String(warn);
			if (!err.IsEmpty) errors = new String(err);

			attrib.vertices = new .(v.GetEnumerator());
			attrib.vertex_weights = new .(v.GetEnumerator());
			attrib.normals = new .(vn.GetEnumerator());
			attrib.texcoords = new .(vt.GetEnumerator());
			attrib.texcoord_ws = new .(vt.GetEnumerator());
			attrib.colors = new .(vc.GetEnumerator());

			return true;
		}
	}
}
