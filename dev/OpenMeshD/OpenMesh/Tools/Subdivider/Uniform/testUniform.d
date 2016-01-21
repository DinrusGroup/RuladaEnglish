//============================================================================
// testUniform.d - 
// Written in the D Programming Language (http://www.digitalmars.com/d)
/*****************************************************************************
 * Description: 
 *   Simple unit test of uniform
 *
 * Author:  William V. Baxter III (OLM Digital, Inc.)
 * Created: 03 Sep 2007
 * Copyright: (C) 2007-2008  William Baxter, OLM Digital, Inc.
 * License: ZLIB/LIBPNG
 */
//============================================================================


module testUniform;

import auxd.OpenMesh.Core.Mesh.TriMesh_ArrayKernelT;
import auxd.OpenMesh.Core.Mesh.Traits;
import auxd.OpenMesh.Core.Mesh.Attributes;
import CompTraits = auxd.OpenMesh.Tools.Subdivider.Uniform.Composite.CompositeTraits;
import auxd.OpenMesh.Tools.Subdivider.Uniform.Composite.CompositeT;

import auxd.OpenMesh.Tools.Subdivider.Uniform.LoopT;
import auxd.OpenMesh.Tools.Subdivider.Uniform.CompositeLoopT;
import auxd.OpenMesh.Tools.Subdivider.Uniform.CompositeSqrt3T;

alias TriMesh_ArrayKernelT!(CompTraits.CompositeTraits) MyMesh;

alias LoopT!(MyMesh) MyLoop;
alias CompositeLoopT!(MyMesh) MyCLoop;
alias CompositeSqrt3T!(MyMesh) MyCSqrt3;

import std.io;

void main()
{
    MyMesh mesh = new MyMesh();
    MyMesh sub_mesh = new MyMesh();

    auto loop = new MyLoop(mesh);
    loop( 1 );


    auto cloop = new MyCLoop(mesh);
    cloop( 1 );

    auto csqrt3 = new MyCSqrt3(mesh);
    csqrt3( 1 );


}


//--- Emacs setup ---
// Local Variables:
// c-basic-offset: 4
// indent-tabs-mode: nil
// End:

