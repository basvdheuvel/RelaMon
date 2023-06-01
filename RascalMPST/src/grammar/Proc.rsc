module grammar::Proc

data RecProc
	= recProc(Proc proc, map[str, Proc] recs)
	| undef()
	;
	
data Proc
	= action(str act)
	| recCallP(str var)
	| seq(Proc pre, Proc suf)
	| nd(list[Proc] procs)
	| ndData(str typ, str var, Proc proc)
	;