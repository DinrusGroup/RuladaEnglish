//============================================================================
// testRulesT.d - 
// Written in the D Programming Language (http://www.digitalmars.com/d)
/*****************************************************************************
 * Description: 
 *   Simple unit test of Rules
 *
 * Author:  William V. Baxter III (OLM Digital, Inc.)
 * Created: 03 Sep 2007
 * License: ZLIB/LIBPNG
 */
//============================================================================

module testRulesT;

import auxd.OpenMesh.Core.Mesh.TriMesh_ArrayKernelT;
import auxd.OpenMesh.Core.Mesh.Traits;
import auxd.OpenMesh.Core.Mesh.Attributes;
import AdapTraits = auxd.OpenMesh.Tools.Subdivider.Adaptive.Composite.Traits;
import CmpTraits = auxd.OpenMesh.Tools.Subdivider.Adaptive.Composite.CompositeTraits;
import auxd.OpenMesh.Tools.Subdivider.Adaptive.Composite.CompositeT;
import auxd.OpenMesh.Tools.Subdivider.Adaptive.Composite.RulesT;

alias TriMesh_ArrayKernelT!(AdapTraits.Traits) MyMesh;
alias TriMesh_ArrayKernelT!(CmpTraits.CompositeTraits) MyCMesh;

alias Tvv3!(MyMesh) MTvv3;
alias Tvv4!(MyMesh) MTvv4;
alias VF!(MyMesh) MTVF;
alias FF!(MyMesh) MTFF;
alias FFc!(MyMesh) MTFFc;
alias FV!(MyMesh) MTFV;
alias FVc!(MyMesh) MTFVc;
alias VV!(MyMesh) MTVV;
alias VVc!(MyMesh) MTVVc;
alias VE!(MyMesh) MTVE;
alias VdE!(MyMesh) MTVdE;
alias VdEc!(MyMesh) MTVdEc;
alias EV!(MyMesh) MTEV;
alias EVc!(MyMesh) MTEVc;
alias EF!(MyMesh) MTEF;
alias FE!(MyMesh) MTFE;
alias EdE!(MyMesh) MTEdE;
alias EdEc!(MyMesh) MTEdEc;

alias Tvv3!(MyCMesh) MTCvv3;
alias Tvv4!(MyCMesh) MTCvv4;
alias VF!(MyCMesh) MTCVF;
alias FF!(MyCMesh) MTCFF;
alias FFc!(MyCMesh) MTCFFc;
alias FV!(MyCMesh) MTCFV;
alias FVc!(MyCMesh) MTCFVc;
alias VV!(MyCMesh) MTCVV;
alias VVc!(MyCMesh) MTCVVc;
alias VE!(MyCMesh) MTCVE;
alias VdE!(MyCMesh) MTCVdE;
alias VdEc!(MyCMesh) MTCVdEc;
alias EV!(MyCMesh) MTCEV;
alias EVc!(MyCMesh) MTCEVc;
alias EF!(MyCMesh) MTCEF;
alias FE!(MyCMesh) MTCFE;
alias EdE!(MyCMesh) MTCEdE;
alias EdEc!(MyCMesh) MTCEdEc;


alias CompositeT!(MyMesh) MComposite;
alias CompositeT!(MyCMesh) MCComposite;

void main()
{
    MyMesh mesh = new MyMesh();
    MyCMesh cmesh = new MyCMesh();

    MComposite mc = new MComposite(mesh);
    MCComposite mcc = new MCComposite(cmesh);
    auto r1 = mc.addT!(MTvv4)();
    auto r2 = mc.addT!(MTEV)();
    mc.initialize();
    auto rc1 = mcc.addT!(MTCvv4)();
    mcc.initialize();
}

//--- Emacs setup ---
// Local Variables:
// c-basic-offset: 4
// indent-tabs-mode: nil
// End:

