module compile::Prot

import grammar::Lmu;
import grammar::Abstract;
import compile::Utils;
import List;
    
public Lmu globalTypeToProt(str part, GT gt) = globalTypeToProt(part, 1, globalTypeActs(part, gt), gt);

public Lmu globalTypeToProt(str part, int n, Af acts, message(EXC exc, TYP typ, GT cont)) {
    Lmu contProt = globalTypeToProt(part, n+1, acts, cont);
    str typstr = abstrTypToStr(typ);

    if (part == exc.from) {
        return conj([always(complStar(acts), exists(typstr, "x_<n>", eventually(seq(complStar(acts), af(actionAf("<part>_<n>_out(x_<n>)"))), tt()))), forall(typstr, "x_<n>", always(seq(complStar(acts), af(actionAf("<part>_<n>_out(x_<n>)"))), contProt))]);
    }
    else if (part == exc.to) {
        return conj([always(complStar(acts), forall(typstr, "x_<n>", eventually(seq(complStar(acts), af(actionAf("<part>_<n>_in(x_<n>)"))), tt()))), forall(typstr, "x_<n>", always(seq(complStar(acts), af(actionAf("<part>_<n>_in(x_<n>)"))), contProt))]);
    }
    else {
        return contProt;
    }
}

public Lmu globalTypeToProt(str part, int n, Af acts, choice(EXC exc, list[CHOICE] choices)) {
    map[str, Lmu] contProts = (choices[i].label: globalTypeToProt(part, n+1+choiceLengthUpTo(i, choices), acts, choices[i].cont) | int i <- [0 .. size(choices)]);
    
    if (part == exc.from) {
        return conj([always(complStar(acts), disj([eventually(seq(complStar(acts), af(actionAf("<part>_<n>_out_<choice.label>"))), tt()) | CHOICE choice <- choices])), conj([always(seq(complStar(acts), af(actionAf("<part>_<n>_out_<choice.label>"))), contProts[choice.label]) | CHOICE choice <- choices])]);
    }
    else if (part == exc.to) {
        return conj([always(complStar(acts), conj([eventually(seq(complStar(acts), af(actionAf("<part>_<n>_in_<choice.label>"))), tt()) | CHOICE choice <- choices])), conj([always(seq(complStar(acts), af(actionAf("<part>_<n>_in_<choice.label>"))), contProts[choice.label]) | CHOICE choice <- choices])]);
    }
    else {
        return conj([contProts[choice.label] | CHOICE choice <- choices]);
    }
}

public Lmu globalTypeToProt(str part, int n, Af acts, end()) {
    return always(complStar(acts), eventually(seq(complStar(acts), af(actionAf("<part>_<n>_end"))), tt()));
}

public Lmu globalTypeToProt(str part, int n, Af acts, recDef(str var, GT cont)) {
    return always(complStar(acts), eventually(complStar(acts), nu(var, globalTypeToProt(part, n, acts, cont))));
}

public Lmu globalTypeToProt(str part, int n, Af acts, recCall(str var)) {
    return always(complStar(acts), eventually(complStar(acts), fix(var)));
}