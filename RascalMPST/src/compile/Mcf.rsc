module compile::Mcf

import grammar::Lmu;
import compile::Utils;

str lmuToMcf(tt()) = "true";
str lmuToMcf(ff()) = "false";
str lmuToMcf(conj(list[Lmu] forms)) = joinStrs(" && ", ["(<lmuToMcf(form)>)" | form <- forms]);
str lmuToMcf(disj(list[Lmu] forms)) = joinStrs(" || ", ["(<lmuToMcf(form)>)" | form <- forms]);
str lmuToMcf(forall(str typ, str var, Lmu form)) = "forall <var> : <typ> . (<lmuToMcf(form)>)";
str lmuToMcf(exists(str typ, str var, Lmu form)) = "exists <var> : <typ> . (<lmuToMcf(form)>)";
str lmuToMcf(eventually(Rf rf, Lmu form)) = "\<<rfToMcf(rf)>\> (<lmuToMcf(form)>)";
str lmuToMcf(always(Rf rf, Lmu form)) = "[<rfToMcf(rf)>] (<lmuToMcf(form)>)";
str lmuToMcf(nu(str var, Lmu form)) = "nu <var> . (<lmuToMcf(form)>)";
str lmuToMcf(fix(str var)) = var;

str rfToMcf(af(Af af)) = afToMcf(af);
str rfToMcf(seq(Rf pre, Rf suf)) = "(<rfToMcf(pre)>) . (<rfToMcf(suf)>)";
str rfToMcf(star(Rf rf)) = "(<rfToMcf(rf)>)*";

str afToMcf(ffAf()) = "false";
str afToMcf(actionAf(str act)) = act;
str afToMcf(compl(Af form)) = "!(<afToMcf(form)>)";
str afToMcf(union(list[Af] forms)) = joinStrs(" || ", ["(<afToMcf(form)>)" | form <- forms]);
str afToMcf(existsAf(str typ, str var, Af form)) = "exists <var> : <typ> . (<afToMcf(form)>)";