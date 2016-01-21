//============================================================================
// testStripifier.d - 
//   Written in the D Programming Language (http://www.digitalmars.com/d)
/*****************************************************************************
 * Description: 
 *   Trivial unit test of the stripifier.
 *
 * Author:  William V. Baxter III, OLM Digital, Inc.
 * Created: 04 Sep 2007
 * License: ZLIB/LIBPNG
 */
//============================================================================

module testStripifier;

import auxd.OpenMesh.Core.Mesh.api;
import auxd.OpenMesh.Tools.Utils.StripifierT;

alias TriMesh_ArrayKernelT!() MyMesh;
alias StripifierT!(MyMesh) Stripper;

void main()
{
    auto mesh = new MyMesh();
    auto stripper = new Stripper(mesh);
}

//--- Emacs setup ---
// Local Variables:
// c-basic-offset: 4
// indent-tabs-mode: nil
// End:

