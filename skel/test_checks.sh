#!/bin/sh

make -s autograde

for f in test_handins/*.tar; do
    base=`basename -s .tar ${f}`
    tmp=`mktemp -d`
    cp ../autograde.tar ${tmp}
    cp test_handins/${base}.tar ${tmp}/handin.tar
    cp ../autograde-Makefile ${tmp}
    echo "\e[41m!!!!!!! Last 10 output lines for test ${base}:\e[0m"
    (cd ${tmp}; make -s -f autograde-Makefile | tail -n 10)
    echo "\e[42m!!!!!!! Expected result:\e[0m"
    cat test_handins/${base}.exp
    rm -fr ${tmp}
done
