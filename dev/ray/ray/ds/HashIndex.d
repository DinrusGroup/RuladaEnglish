/**
	Copyright: Copyright (c) 2007, Artyom Shalkhakov. All rights reserved.
	License: BSD

	Version: Aug 2007: initial release
	Authors: Artyom Shalkhakov
*/
module auxd.ray.ds.HashIndex;

import Math = auxd.ray.base.Math;

/**
	Fast hash table for indices and arrays.
	Does not allocate memory until the first key/index pair is added.
	This is loosely based on code from id Software's Doom3 SDK
*/
final class HashIndex {
	this() {
		this( DEFAULT_HASH_SIZE, DEFAULT_HASH_SIZE );
	}

	this( int hashSize, int indexSize )
	in {
		assert( Math.isPowerOfTwo( hashSize ) );
	}
	body {
		this.hash = INVALID_INDEX;
		this.hashSize = hashSize;
		this.indexChain = INVALID_INDEX;
		this.indexSize = indexSize;
		this.hashMask = hashSize - 1;
	}

	HashIndex dup() {
		HashIndex	other = new HashIndex( hashSize, indexSize );

		other.hashMask = hashMask;
		other.lookupMask = lookupMask;
		other.hash = hash.dup;
		other.indexChain = indexChain.dup;

		return other;
	}

	/// add an index to the hash, assumes the index has not yet been added to the hash
	void add( int key, int index )
	in {
		assert( index >= 0 );
	}
	body {
		int h;

		if ( hash is INVALID_INDEX ) {
			allocate( hashSize, index >= indexSize ? index + 1 : indexSize );
		}
		else if ( index >= indexSize ) {
			resizeIndex( index + 1 );
		}
		h = key & hashMask;
		indexChain[index] = hash[h];
		hash[h] = index; 
	}

	/// remove an index from the hash
	void remove( int key, int index ) {
		int	k = key & hashMask;
	
		if ( hash is INVALID_INDEX ) {
			return;
		}
		if ( hash[k] == index ) {
			hash[k] = indexChain[index];
		}
		else {
			for ( int i = hash[k]; i != -1; i = indexChain[i] ) {
				if ( indexChain[i] == index ) {
					indexChain[i] = indexChain[index];
					break;
				}
			}
		}
		indexChain[index] = -1; 
	}

	/// returns the first index from the hash, returns -1 if empty hash entry
	int first( int key ) {
		return hash[key & hashMask & lookupMask];
	}

	/// get the next index from the hash, returns -1 if at the end of the hash chain
	int next( int index )
	in {
		assert( index >= 0 && index < indexChain.length );
	}
	body {
		return indexChain[index & lookupMask];
	}

	/// inserts an entry into the index and adds it to the hash, increasing all indexes >= index
	void insertIndex( int key, int index ) {
		int	i, max;

		if ( hash !is INVALID_INDEX ) {
			max = index;
			for ( i = 0; i < hashSize; i++ ) {
				if ( hash[i] >= index ) {
					hash[i]++;
					if ( hash[i] > max ) {
						max = hash[i];
					}
				}
			}
			for ( i = 0; i < indexSize; i++ ) {
				if ( indexChain[i] >= index ) {
					indexChain[i]++;
					if ( indexChain[i] > max ) {
						max = indexChain[i];
					}
				}
			}
			if ( max >= indexSize ) {
				resizeIndex( max + 1 );
			}
			for ( i = max; i > index; i-- ) {
				indexChain[i] = indexChain[i - 1];
			}
			indexChain[index] = -1;
		}
		add( key, index ); 
	}

	/// removes an entry from the index and from the hash, decreasing all indices >= index
	void removeIndex( int key, int index ) {
		int	i, max;

		remove( key, index );
		if ( hash !is INVALID_INDEX ) {
			max = index;
			for ( i = 0; i < hashSize; i++ ) {
				if ( hash[i] >= index ) {
					if ( hash[i] > max ) {
						max = hash[i];
					}
					hash[i]--;
				}
			}
			for ( i = 0; i < indexSize; i++ ) {
				if ( indexChain[i] >= index ) {
					if ( indexChain[i] > max ) {
						max = indexChain[i];
					}
					indexChain[i]--;
				}
			}
			for ( i = index; i < max; i++ ) {
				indexChain[i] = indexChain[i + 1];
			}
			indexChain[max] = -1;
		} 
	}

	/// clear the hash
	void clear() {
		// only clear the hash table because clearing the indexChain is not really needed
		if ( hash !is INVALID_INDEX ) {
			hash[] = 0xFF;
		}
	}

	/// clear and resize
	void clear( size_t newHashSize, size_t newIndexSize )
	in {
		assert( Math.isPowerOfTwo( newHashSize ) );
	}
	body {
		free();
		hashSize = newHashSize;
		indexSize = newIndexSize;
	}

	/// free allocated memory
	void free() {
		if ( hash !is INVALID_INDEX ) {
			delete hash;
			hash = INVALID_INDEX;
		}
		if ( indexChain !is INVALID_INDEX ) {
			delete indexChain;
			indexChain = INVALID_INDEX;
		}
		lookupMask = 0;
	}

	/// get size of hash table
	int getHashSize() {
		return hashSize;
	}

	/// get size of the index
	int getIndexSize() {
		return indexSize;
	}

	/// force resizing the index, current hash table stays intact
	void resizeIndex( int newIndexSize ) {
		size_t	len;

		if ( newIndexSize < indexChain.length ) {
			return;
		}
		if ( indexChain is INVALID_INDEX ) {
			indexSize = newIndexSize;
			return;
		}
		len = indexChain.length;
		indexChain.length = newIndexSize;
		indexChain[len..$] = -1;
		indexSize = newIndexSize;
	}

	private {
		int			hashSize;
		int[]		hash;
		int			indexSize;
		int[]		indexChain;
		int			hashMask;
		int			lookupMask;

		const {
			int[1]	INVALID_INDEX		= [ -1 ];
			int		DEFAULT_HASH_SIZE	= 1024;
		}

		void allocate( int newHashSize, int newIndexSize )
		in {
			assert( Math.isPowerOfTwo( newHashSize ) );
		}
		body {
			free();
			hashSize = newHashSize;
			hash = new int[hashSize];
			hash[] = -1;
			indexSize = newIndexSize;
			indexChain = new int[indexSize];
			indexChain[] = -1;
			hashMask = hashSize - 1;
			lookupMask = -1;
		}
	}
}

unittest {
	HashIndex	indexHash = new HashIndex;
	int[]		indices;

	assert( indexHash.first( 0 ) == -1 );
	indexHash.add( 0, 10 );
	assert( indexHash.first( 0 ) == 10 );
	indexHash.add( 0, 11 );
	assert( indexHash.first( 0 ) == 11 );
	assert( indexHash.next( 11 ) == 10 );
	indexHash.remove( 0, 11 );
	assert( indexHash.first( 0 ) == 10 );
	assert( indexHash.next( 10 ) == -1 );
}
