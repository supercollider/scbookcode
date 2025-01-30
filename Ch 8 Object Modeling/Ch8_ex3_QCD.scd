


// figure 8.19 - a fixed serialization method.

serialize {|index, pos, extent = 8|
	var ranges, slice;

	// get ranges
	ranges = pos.collect{|pos, i|
		((pos-(extent*0.5))..(pos+(extent*0.5)-1)) % this.shape[i]
	};
	// get sub-slice
	slice = this.slice(index, *ranges);
	// trivial serialization of multidim. slice
	^slice.flat
}






// figure 8.20 - flexible  serialization by lookup.

serialize {|index, pos, extent = 8, how = \hilbert|
	// [...]
	slice = this.slice(index, *ranges);
	// call function in serTypes dictionary
	^serTypes[how].(slice.asArray, extent)
}







// figure 8.21 some initial serialization methods

*initClass {|numDims = 4|
	...
	// slice here is a 4d hypercube of extent <extent>
	serTypes = (
		hilbert: {|slice, extent|
			extent.isPowerOfTwo.not.if({
				"QCD:serialize: extent has to be a power of two".error
			});
			HilbertIndices.serialize(slice)
		},
		torus: {|slice, extent|
			slice.flat;
		},
		scramble: {|slice|
			slice.flat.scramble;
		}
	);
}

// figure 8.22 adding a new serialization type at runtime

QCD.serTypes.put(\star, {|slice|
	var starSize = slice.size div:2;
	var numDims = 4;
	var starShape;

	starShape = neighbours1.collect({ |nb|
		(0..starSize).collect(_ * nb)
	}).flatten(1).collect {|indexN|
		indexN + (starSize.div(2)+1).dup(numDims)
	};

	starShape.collect{|iA| slice.slice(*iA)}
});



