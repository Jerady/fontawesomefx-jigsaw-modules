#!/bin/bash

cat << task

    Run

task

$JAVA9_HOME/bin/java \
    -modulepath lib \
    -m de.jensd.fx.glyphs.fontawesome
