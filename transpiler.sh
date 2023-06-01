#!/bin/bash

rascmd="java -cp RelaMon.jar:rascal-shell-stable.jar org.rascalmpl.shell.RascalShell"

exec 3>&2
exec 2> /dev/null
exec $rascmd $@
exec 2>&3
