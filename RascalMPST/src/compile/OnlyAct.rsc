module compile::OnlyAct

import grammar::Lmu;
import compile::Utils;

Lmu onlyAct(map[str, Af] actss, list[str] parts, str part) {
    // TODO: we need tt.
    return always(seq(complStar(compl(ffAf())), af(union([actss[partp] | partp <- parts, partp != part]))), ff());
}