module RelaMon
import IO;
import String;
import compile::Translate;

int main(list[str] args) {
    // TODO: check if args are set correctly
    str addrInput = args[0];
    str ownPortInput = args[1];
    str routerPortInput = args[2];
    str implementingParty = args[3];

    str gtCode = readFile(|file:///dev/stdin|);
    str json = translateStr(gtCode, strToMap(addrInput), toInt(ownPortInput), toInt(routerPortInput), implementingParty);
    println(json);
    return 0;
}

map[str,str] strToMap(str input) {
    map[str,str] res = ();
    list[str] inputs = split(",", input);
    for (str pair <- inputs) {
        list[str] spl = split("\>", pair);
        res += (spl[0]: spl[1]);
    }    
    return res;
}