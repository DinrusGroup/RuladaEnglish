//============================================================================
// testSmoother.d - 
// Written in the D Programming Language (http://www.digitalmars.com/d)
/*****************************************************************************
 * Description: 
 *   Simple unit test of smoother
 *
 * Author:  William V. Baxter III (OLM Digital, Inc.)
 * Created: 03 Sep 2007
 * Copyright: (C) 2007-2008  William Baxter, OLM Digital, Inc.
 * License: ZLIB/LIBPNG
 */
//============================================================================

module testSmoother;


import auxd.OpenMesh.Core.Mesh.TriMesh_ArrayKernelT;
import auxd.OpenMesh.Core.Mesh.Traits;
import auxd.OpenMesh.Core.Mesh.Attributes;

alias TriMesh_ArrayKernelT!() MyMesh;

import auxd.OpenMesh.Tools.Smoother.LaplaceSmootherT;
import auxd.OpenMesh.Tools.Smoother.JacobiLaplaceSmootherT;

alias LaplaceSmootherT!(MyMesh) LSmooth;
alias JacobiLaplaceSmootherT!(MyMesh) JLSmooth;

void main()
{
    auto mesh = new MyMesh;

    //auto lsmooth = new LSmooth(mesh);

    auto jlsmooth = new JLSmooth(mesh);
}

//--- Emacs setup ---
// Local Variables:
// c-basic-offset: 4
// indent-tabs-mode: nil
// End:

