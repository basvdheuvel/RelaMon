module compile::Proc

import grammar::Proc;
import grammar::Abstract;
import compile::Utils;
import List;
	
public RecProc globalTypeToProc(str part, GT gt) = globalTypeToProc(part, 1, {}, gt);
	
public RecProc globalTypeToProc(str part, int n, set[str] U, message(EXC exc, TYP typ, GT cont)) {
    set[str] Up = U;
    if (part == exc.from || part == exc.to) {
        Up = {};
    }
    RecProc contProc = globalTypeToProc(part, n+1, Up, cont);
    
    // check that the continuation is not undefined.
    switch (contProc) {
        case undef(): return undef();
    }
    
    str typstr = abstrTypToStr(typ);
    if (part == exc.from) {
        return recProc(ndData(typstr, "x_<n>", seq(action("<part>_<n>_out(x_<n>)"), contProc.proc)), contProc.recs);
    }
    else if (part == exc.to) {
        return recProc(ndData(typstr, "x_<n>", seq(action("<part>_<n>_in(x_<n>)"), contProc.proc)), contProc.recs);
    }
    else {
        return contProc;
    }
}

public RecProc globalTypeToProc(str part, int n, set[str] U, choice(EXC exc, list[CHOICE] choices)) {
    set[str] Up = U;
    if (part == exc.from || part == exc.to) {
        Up = {};
    }
    
    map[str, RecProc] conts = (choices[i].label: globalTypeToProc(part, n+1+choiceLengthUpTo(i, choices), Up, choices[i].cont) | int i <- [0 .. size(choices)]);
    
    if (part == exc.from || part == exc.to) {
        // check that none of the continuations is undefined.
        for (cont <- conts) {
            switch (conts[cont]) {
                case undef(): return undef();
            }
        }
    }
    
    if (part == exc.from) {
        map[str, Proc] recs = ();
        for (cont <- conts) {
            recs = recs + conts[cont].recs;
        }
        return recProc(nd([seq(action("<part>_<n>_out_<choice.label>"), conts[choice.label].proc) | choice <- choices]), recs);
    }
    else if (part == exc.to) {
        map[str, Proc] recs = ();
        for (cont <- conts) {
            recs = recs + conts[cont].recs;
        }
        return recProc(nd([seq(action("<part>_<n>_in_<choice.label>"), conts[choice.label].proc) | choice <- choices]), recs);
    }
    else {
        list[str] goodLabels = [];
        for (choice <- choices) {
            switch (conts[choice.label]) {
                case undef(): continue;
                case recProc(Proc proc, _):
                    switch (proc) {
                        case recCall(str var):
                            if (var in U) {
                                continue;
                            }
                    }
            }
            goodLabels = goodLabels + choice.label;
        }
        
        if (isEmpty(goodLabels)) {
            return undef();
        }
        
        map[str, Proc] recs = ();
        for (label <- goodLabels) {
            recs = recs + conts[label].recs;
        }
        
        return recProc(nd([conts[label].proc | label <- goodLabels]), recs);
    }
}

public RecProc globalTypeToProc(str part, int n, set[str] U, end()) {
    return recProc(action("<part>_<n>_end"), ());
}

public RecProc globalTypeToProc(str part, int n, set[str] U, recDef(str var, GT cont)) {
    RecProc contProc = globalTypeToProc(part, n, U + var, cont);
    switch (contProc) {
        case undef(): return undef();
    }
    return recProc(contProc.proc, contProc.recs + (var: contProc.proc));
}

public RecProc globalTypeToProc(str part, int n, set[str] U, recCall(str var)) {
    if (var in U) {
        return undef();
    }
    return recProc(recCallP(var), ());
}