/*using System;
using System.Threading;
using System.Collections;


namespace SteelEngine
{
	static
	{
		private static uint64 _base_id = 1;
		private static uint64 GenerateId()
		{
			return Interlocked.Increment(ref _base_id);
		}
	}


	public class RIDAlloc<T> where T : struct
	{
		const bool THREAD_SAFE = true;

		List<T[]> _chunks = new .() ~ DeleteContainerAndItems!(_);
		List<uint32[]> _freeListChunks = new .() ~ DeleteContainerAndItems!(_);
		List<uint32[]> _validatorChunks = new .() ~ DeleteContainerAndItems!(_);

		uint32 _elementsInChunk;
		uint32 _maxAlloc;
		uint32 _allocCount;
		
		String _description = new .() ~ delete _;

		public uint32 Count => _allocCount;
		public StringView Description
		{
			get => _description;
			set => _description.Set(value);
		}

		public T* GetOrDefault(RID rid) {
			
			if (THREAD_SAFE)
			{
				/*_spinLock.lock();
				defer:: _spinLock.unlock();
				*/
			}

			uint64 id = rid.Id;
			uint32 idx = uint32(id & 0xFFFFFFFF);
			if (idx >= _maxAlloc) {
				return default;
			}

			uint32 idx_chunk = idx / _elementsInChunk;
			uint32 idx_element = idx % _elementsInChunk;

			uint32 validator = uint32(id >> 32);
			if (_validatorChunks[idx_chunk][idx_element] != validator) {
				return default;
			}

			T *ptr = (&_chunks[idx_chunk][idx_element]);

			return ptr;
		}

		public RID MakeRID(T value)
		{
			if (THREAD_SAFE)
			{
				/*_spinLock.lock();
				defer:: _spinLock.unlock();
				*/
			}

			AllocateChunkIfNeeded();

			uint32 freeIndex = _freeListChunks[_allocCount / _elementsInChunk][_allocCount % _elementsInChunk];

			uint32 freeChunk = freeIndex / _elementsInChunk;
			uint32 freeElement = freeIndex % _elementsInChunk;

			T *ptr = &_chunks[freeChunk][freeElement];
			*ptr = value;

			uint32 validator = (uint32)(SteelEngine.[Friend]GenerateId() & 0xFFFFFFFF);
			uint64 id = validator;
			id <<= 32;
			id |= freeIndex;

			_validatorChunks[freeChunk][freeElement] = validator;
			_allocCount++;

			RID rid = .();
			rid.[Friend]_id = id;
			return rid;
		}

		void AllocateChunkIfNeeded()
		{
			if (_allocCount == _maxAlloc)
			{
				//allocate a new chunk
				uint32 chunkCount = _allocCount == 0 ? 0 : (_maxAlloc / _elementsInChunk);

				//grow chunks
				_chunks.Add(new T[_elementsInChunk]);

				//grow validators
				_validatorChunks.Add(new uint32[_elementsInChunk]);
				/*uint32[][] validatorChunks = (uint32 **)memrealloc(validator_chunks, sizeof(uint32_t *) * (chunk_count + 1));
				_validatorChunks[chunkCount] = (uint32_t *)memalloc(sizeof(uint32_t) * elements_in_chunk);*/

				//grow free lists
				_freeListChunks.Add(new uint32[_elementsInChunk]);
				/*_freeListChunks = (uint32 **)memrealloc(free_list_chunks, sizeof(uint32_t *) * (chunk_count + 1));
				_freeListChunks[chunkCount] = (uint32_t *)memalloc(sizeof(uint32_t) * elements_in_chunk);*/

				//initialize
				for (uint32 i = 0; i < _elementsInChunk; i++) {
					//dont initialize chunk
					_validatorChunks[chunkCount][i] = 0xFFFFFFFF;
					_freeListChunks[chunkCount][i] = _allocCount + i;
				}

				_maxAlloc += _elementsInChunk;
			}
		}

		public bool Owns(RID rid)
		{
			if (THREAD_SAFE)
			{
				/*_spinLock.lock();
				defer:: _spinLock.unlock();
				*/
			}

			uint64 id = rid.Id;
			uint32 idx = uint32(id & 0xFFFFFFFF);
			if (idx >= _maxAlloc) {
				return false;
			}

			uint32 idx_chunk = idx / _elementsInChunk;
			uint32 idx_element = idx % _elementsInChunk;

			uint32 validator = uint32(id >> 32);

			return _validatorChunks[idx_chunk][idx_element] == validator;
		}

		mixin DisposeElement<TElement>(TElement v)
		{

		}

		mixin DisposeElement<TElement>(TElement v) where TElement : IDisposable
		{
			v.Dispose();
		}

		public void Free(RID rid)
		{
			if (THREAD_SAFE)
			{
				/*_spinLock.lock();
				defer:: _spinLock.unlock();
				*/
			}
			
			uint64 id = rid.Id;
			uint32 idx = uint32(id & 0xFFFFFFFF);
			if (idx >= _maxAlloc) {
				String name = scope .();
				typeof(Self).GetName(name);
				Log.Fatal($"Calculated index was outside of bounds. {name}::Free(RID {rid})");
				return;
			}

			uint32 idxChunk = idx / _elementsInChunk;
			uint32 idxElement = idx % _elementsInChunk;

			uint32 validator = uint32(id >> 32);
			if (_validatorChunks[idxChunk][idxElement] != validator) {
				String name = scope .();
				typeof(Self).GetName(name);
				Log.Fatal($"Validation failed. {name}::Free(RID {rid})");
				return;
			}


			//_chunks[idxChunk][idxElement].Dispose();
			DisposeElement!(_chunks[idxChunk][idxElement]);

			_validatorChunks[idxChunk][idxElement] = 0xFFFFFFFF; 

			_allocCount--;
			_freeListChunks[_allocCount / _elementsInChunk][_allocCount % _elementsInChunk] = idx;
		}

		public this(uint elementsInChunk)
		{
			_elementsInChunk = (.)elementsInChunk;
		}
	}

	public class RIDOwner<T> where T : struct
	{
		protected RIDAlloc<T> _alloc ~ delete _;

		[Inline]
		public uint32 Count => _alloc.Count;
		public StringView Description
		{
			get => _alloc.Description;
			set => _alloc.Description = value;
		}

		public T* this[RID rid]
		{
			[Inline] get => GetOrDefault(rid);
		}

		public T* this[Resource res]
		{
			[Inline] get => GetOrDefault(res);
		}

		[Inline]
		public RID MakeRID(T val) => _alloc.MakeRID(val);
		[Inline]
		public T* GetOrDefault(RID rid) => _alloc.GetOrDefault(rid);
		[Inline]
		public T* GetOrDefault(Resource res) => _alloc.GetOrDefault(res.ResourceId);
		[Inline]
		public void Free(RID rid) => _alloc.Free(rid);
		[Inline]
		public void Free(Resource res) => _alloc.Free(res.ResourceId);
		[Inline]
		public bool Owns(RID rid) => _alloc.Owns(rid);
		[Inline]
		public bool Owns(Resource res) => _alloc.Owns(res.ResourceId);

		public this(uint targetChunkByteSize = 4096)
		{
			_alloc = new RIDAlloc<T>(targetChunkByteSize / (uint)sizeof(T));
		}
	}
}
*/