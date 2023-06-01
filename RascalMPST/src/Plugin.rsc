module Plugin

import util::IDE;
import ParseTree;

import grammar::Grammar;

private str GT_NAME = "GlobalType";
private str GT_EXT = "gt";

Tree parser(str x, loc l) {
	return parse(#start[GlobalType], x, l).top;
}

public void registerGlobalTypes() {
	registerLanguage(GT_NAME, GT_EXT, parser);
}