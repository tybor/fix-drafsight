#!/bin/sh

## Fix a DraftSight Debian package to make it installable on a 64bit machine.

## Last known realease is http://dl-ak.solidworks.com/nonsecure/draftsight/V1R4.0/draftSight.deb

ORIGINAL=draftSight.deb 
PACKAGE=fixed-$ORIGINAL

if ! test -f $ORIGINAL 
then 
	echo $ORIGINAL file does not exist.
	PACKAGE=$(zenity --file-selection --filename=draftSight.deb --file-filter=deb)
fi

echo Copying $ORIGINAL into $PACKAGE
cp $ORIGINAL $PACKAGE || exit 5;

echo Extracting  control.tar.gz
ar x $PACKAGE control.tar.gz || exit 5;

echo Unpacking control.tar.gz into control directory
mkdir --parent control || exit 5;
tar -zxf control.tar.gz --directory control || exit 5;
mv control.tar.gz control.tar.gz.orig

echo "Removing wrong dependency (libdirectfb)"
if sed --in-place -e "s/ libdirectfb-extra (>=1.2.7-2),//" control/control 
then 
    echo Repacking contents of 'control' directory into control.tar.gz
    (cd control; tar --create --file ../control.tar *) || exit 5;
    gzip --best --no-name control.tar
    echo Storing patched control.tar.gz back into $PACKAGE;
    ar r $PACKAGE control.tar.gz || exit 5;
    echo Draftsight original package $ORIGINAL patched into $PACKAGE
fi 
