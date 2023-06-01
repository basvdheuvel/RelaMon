module grammar::Lmu

data Lmu
    = tt()
    | ff()
    | conj(list[Lmu] forms)
    | disj(list[Lmu] forms)
    | forall(str typ, str var, Lmu form)
    | exists(str typ, str var, Lmu form)
    | eventually(Rf rf, Lmu form)
    | always(Rf rf, Lmu form)
    | nu(str var, Lmu form)
    | fix(str var)
    ;

    
data Rf
    = af(Af af)
    | seq(Rf pre, Rf suf)
    | star(Rf rf)
    ;
    
data Af
    = ffAf()
    | actionAf(str act)
    | compl(Af form)
    | union(list[Af] forms)
    | existsAf(str typ, str var, Af form)
    ;