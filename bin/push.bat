FWDIR="$(cd "`dirname "$0"`"/..; pwd)"
cd $FWDIR

sh.exe --login -i bin/push
set /p DUMMY=Hit ENTER to continue...
