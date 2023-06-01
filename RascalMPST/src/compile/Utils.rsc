module compile::Utils

import grammar::Abstract;
import grammar::Load;
import grammar::Proc;
import grammar::Lmu;
import compile::Proc;
import compile::Prot;
import compile::Gprot;
import compile::Mcrl;
import compile::McrlProject;
import List;
import IO;

public RecProc fileToProc(loc file, str part) = globalTypeToProc(part, loadFile(file));
public Lmu fileToProt(loc file, str part) = globalTypeToProt(part, loadFile(file));
public Lmu fileToGprot(loc file) = globalTypeToGprot(loadFile(file));
public str fileToMcrlProc(loc file, str part) = recProcToMcrl(fileToProc(file, part), part);
public void compileBenchmark(str name) = fileToMcrlProject(|home:///Projects/GlobalACP/toolkit/src/gts/| + "<name>.gt", |home:///Projects/GlobalACP/benchmarks|, name);

public int globalTypeLength(message(_, _, GT cont)) = 1 + globalTypeLength(cont);
public int globalTypeLength(choice(_, list[CHOICE] choices)) = 1 + sum([globalTypeLength(choice.cont) | CHOICE choice <- choices]);
public int globalTypeLength(end()) = 1;
public int globalTypeLength(recDef(_, GT cont)) = globalTypeLength(cont);
public int globalTypeLength(recCall(_)) = 0;

public int choiceLengthUpTo(int i, list[CHOICE] choices) = sum([0] + [globalTypeLength(choices[j].cont) | j <- [0 .. i]]);

public Af globalTypeActs(str part, GT gt) = globalTypeActs(part, 1, gt);
public Af globalTypeActs(str part, int n, message(EXC exc, TYP typ, GT cont)) {
    Af contActs = globalTypeActs(part, n+1, cont);
    
    if (part == exc.from || part == exc.to) {
        str actDir = "";
        if (part == exc.from) {
            actDir = "out";
        }
        else {
            actDir = "in";
        }
        return union([existsAf(abstrTypToStr(typ), "x", actionAf("<part>_<n>_<actDir>(x)")), contActs]);
    }
    else {
        return contActs;
    }
}
public Af globalTypeActs(str part, int n, choice(EXC exc, list[CHOICE] choices)) {
    map[str, Af] contActs = (choices[i].label: globalTypeActs(part, n+1+choiceLengthUpTo(i, choices), choices[i].cont) | int i <- [0 .. size(choices)]);
    
    if (part == exc.from || part == exc.to) {
        str actDir = "";
        if (part == exc.from) {
            actDir = "out";
        }
        else {
            actDir = "in";
        }
        return union([union([actionAf("<part>_<n>_<actDir>_<choice.label>"), contActs[choice.label]]) | CHOICE choice <- choices]);
    }
    else {
        return union([contActs[choice.label] | CHOICE choice <- choices]);
    }
}
public Af globalTypeActs(str part, int n, end()) {
    return actionAf("<part>_<n>_end");
}
public Af globalTypeActs(str part, int n, recDef(_, GT cont)) = globalTypeActs(part, n, cont);
public Af globalTypeActs(_, _, recCall(_)) = ffAf();

public Af globalTypeGacts(GT gt) = globalTypeGacts(globalTypeParts(gt), 1, gt);
public Af globalTypeGacts(list[str] parts, int n, message(EXC exc, TYP typ, GT cont)) = union([existsAf(abstrTypToStr(typ), "x", actionAf("<exc.from>_<exc.to>_<n>(x)")), globalTypeGacts(parts, n+1, cont)]);
public Af globalTypeGacts(list[str] parts, int n, choice(EXC exc, list[CHOICE] choices)) = union([union([actionAf("<exc.from>_<exc.to>_<n>_<choices[i].label>"), globalTypeGacts(parts, n+1+choiceLengthUpTo(i, choices), choices[i].cont)]) | int i <- [0 .. size(choices)]]);
public Af globalTypeGacts(list[str] parts, int n, end()) {
    str actPre = "";
    for (str part <- parts) {
        actPre = actPre + "<part>_";
    }
    return actionAf("<actPre><n>_end");
}
public Af globalTypeGacts(list[str] parts, int n, recDef(_, GT cont)) = globalTypeGacts(parts, n, cont);
public Af globalTypeGacts(_, _, recCall(_)) = ffAf();

public list[str] globalTypeParts(message(EXC exc, _, GT cont)) = [exc.from, exc.to] + (globalTypeParts(cont) - [exc.from, exc.to]);
public list[str] globalTypeParts(choice(EXC exc, list[CHOICE] choices)) {
    list[str] res = [exc.from, exc.to];
    // No duplicate appearances and maintain consistent order (depth-first).
    for (choice <- choices) {
        res = res + (globalTypeParts(choice.cont) - res);
    }
    return res;
}
public list[str] globalTypeParts(end()) = [];
public list[str] globalTypeParts(recDef(_, GT cont)) = globalTypeParts(cont);
public list[str] globalTypeParts(recCall(_)) = [];
    
Rf complStar(Af form) = star(af(compl(form)));

str joinStrs(str sep, list[str] strs) {
    if (size(strs) == 0) {
        return "";
    }
    str res = "<strs[0]>";
    for (int i <- [1 .. size(strs)]) {
        res = "<res><sep><strs[i]>";
    }
    return res;
}

str abstrTypToStr(primitive(str id)) = id;
str abstrTypToStr(listTyp(TYP listtyp)) = "List(<abstrTypToStr(listtyp)>)";
str abstrTypToStr(setTyp(TYP settyp)) = "Set(<abstrTypToStr(settyp)>)";
str abstrTypToStr(bagTyp(TYP bagtyp)) = "Bag(<abstrTypToStr(bagtyp)>)";
str abstrTypToStr(structTyp(list[CONSTR] constrs)) = "struct <joinStrs(" | ", [constrToStr(constr) | constr <- constrs])>";
str constrToStr(constr(str id, list[TYP] typs)) = "<id> (<joinStrs(", ", [abstrTypToStr(typ) | typ <- typs])>)";
