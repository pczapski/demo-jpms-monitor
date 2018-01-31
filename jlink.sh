#!/bin/bash
set -e

#Java executable for standard Linux environment
export JDEPS_EXE=jdeps
export JLINK_EXE=jlink
export JMODS=/opt/jdk-9/jmods
#Java executable for MinGW environment
#export JDEPS_EXE=/c/jdk9/bin/jdeps.exe
#export JLINK_EXE=/c/jdk9/bin/jlink.exe
#export JMODS=/c/jdk9/jmods

# The CREATE MONITOR IMAGE step isn't likely to work in MinGW unless using a
# native JDK for Linux/MinGW that uses the colon (not the semicolon) as the
# file separator. With a Windows JDK, the colon in a class/module path is an
# illegal character. In a Unix shell, the semicolon is considered a command
# terminator when unquoted. Quoting it bypasses this "command terminator"
# thing, but only one path entry is taken into consideration.

echo "--- DELETING IMAGES ---"
rm -rf jdk-minimal
rm -rf jdk-monitor

echo ""
echo "--- DEPENDENCIES ON PLATFORM MODULES ---"
$JDEPS_EXE -summary -recursive \
	--module-path mods \
	--module monitor \
	--add-modules monitor.observer.alpha,monitor.observer.beta \
| grep java.

echo ""
echo "--- CREATE JAVA.BASE IMAGE ---"
$JLINK_EXE \
	--output jdk-minimal \
	--module-path $JMODS \
	--add-modules java.base

echo ""
echo "--- LIST JAVA.BASE IMAGE MODULES ---"
jdk-minimal/bin/java --list-modules

echo ""
echo "--- CREATE MONITOR IMAGE ---"
$JLINK_EXE \
	--output jdk-monitor \
	--module-path $JMODS:mods \
	--add-modules monitor,monitor.observer.alpha,monitor.observer.beta \
	--launcher monitor=monitor

echo ""
echo "--- LIST MONITOR IMAGE MODULES ---"
jdk-monitor/bin/java --list-modules

# echo ""
# echo "--- LAUNCH MONITOR IMAGE MODULES ---"
# jdk-monitor/bin/monitor

echo ""
echo "--- LAUNCH MONITOR IMAGE MODULES WITH EXTERNAL OBSERVER ---"
# without monitor.observer.zero, you can not observe service 0-patient
jdk-monitor/bin/java \
	--module-path mods/monitor.observer.zero.jar \
	--module monitor