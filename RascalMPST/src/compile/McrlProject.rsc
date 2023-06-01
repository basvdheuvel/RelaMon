module compile::McrlProject

import grammar::Abstract;
import grammar::Lmu;
import grammar::Load;
import compile::Utils;
import compile::Mcrl;
import compile::Mcf;
import compile::Prot;
import compile::Gprot;
import compile::OnlyAct;
import IO;

void fileToMcrlProject(loc file, loc dest, str projName) {
    GT gt = loadFile(file);
    list[str] parts = globalTypeParts(gt);
    map[str, Af] actss = (part: globalTypeActs(part, gt) | str part <- parts);
    
    str mcrlSpec = globalTypeToMcrl(gt);
    map[str, str] protSpecs = (part: lmuToMcf(globalTypeToProt(part, gt)) | str part <- parts);
    map[str, str] onlyActSpecs = (part: lmuToMcf(onlyAct(actss, parts, part)) | str part <- parts);
    str gprotSpec = lmuToMcf(globalTypeToGprot(gt));
    
    loc projDest = dest + projName;
    loc propDest = projDest + "properties";
    if (!exists(projDest)) {
        mkDirectory(projDest);
    }
    if (!exists(propDest)) {
        mkDirectory(propDest);
    }
    
    writeFile(projDest + "<projName>_spec.mcrl2", mcrlSpec);
    for (str part <- parts) {
        writeFile(propDest + "prot_<part>.mcf", protSpecs[part]);
        writeFile(propDest + "onlyAct_<part>.mcf", onlyActSpecs[part]);
    }
    writeFile(propDest + "gprot.mcf", gprotSpec);
    
    writeFile(projDest + "<projName>.mcrl2proj", "\<root\>\<spec\><projName>_spec.mcrl2\</spec\>\<properties\>\<property\>gprot\</property\><joinStrs("", ["\<property\>prot_<part>\</property\>\<property\>onlyAct_<part>\</property\>" | str part <- parts])>\</properties\>\</root\>");
}