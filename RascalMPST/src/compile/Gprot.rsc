module compile::Gprot

import grammar::Lmu;
import grammar::Abstract;
import compile::Utils;
import List;

public Lmu globalTypeToGprot(GT gt) = globalTypeToGprot(globalTypeParts(gt), 1, globalTypeGacts(gt), gt);

public Lmu globalTypeToGprot(list[str] parts, int n, Af gacts, message(EXC exc, TYP typ, GT cont)) {
    Lmu contForm = globalTypeToGprot(parts, n+1, gacts, cont);
    str typstr = abstrTypToStr(typ);
    return conj([always(complStar(gacts), exists(typstr, "x_<n>", eventually(seq(complStar(gacts), af(actionAf("<exc.from>_<exc.to>_<n>(x_<n>)"))), tt()))), forall(typstr, "x_<n>", always(seq(complStar(gacts), af(actionAf("<exc.from>_<exc.to>_<n>(x_<n>)"))), contForm))]);
}

public Lmu globalTypeToGprot(list[str] parts, int n, Af gacts, choice(EXC exc, list[CHOICE] choices)) {
    map[str, Lmu] contForms = (choices[i].label: globalTypeToGprot(parts, n+1+choiceLengthUpTo(i, choices), gacts, choices[i].cont) | int i <- [0 .. size(choices)]);
    
    return conj([always(complStar(gacts), disj([eventually(seq(complStar(gacts), af(actionAf("<exc.from>_<exc.to>_<n>_<choice.label>"))), tt()) | CHOICE choice <- choices])), conj([always(seq(complStar(gacts), af(actionAf("<exc.from>_<exc.to>_<n>_<choice.label>"))), contForms[choice.label]) | CHOICE choice <- choices])]);
}

public Lmu globalTypeToGprot(list[str] parts, int n, Af gacts, end()) {
    str actPre = "";
    for (part <- parts) {
        actPre = actPre + "<part>_";
    }
    return always(complStar(gacts), eventually(seq(complStar(gacts), af(actionAf("<actPre><n>_end"))), tt()));
}

public Lmu globalTypeToGprot(list[str] parts, int n, Af gacts, recDef(str var, GT cont)) {
    Lmu contForm = globalTypeToGprot(parts, n, gacts, cont);
    return always(complStar(gacts), eventually(complStar(gacts), nu(var, contForm)));
}

public Lmu globalTypeToGprot(list[str] parts, int n, Af gacts, recCall(str var)) {
    return always(complStar(gacts), eventually(complStar(gacts), fix(var)));
}