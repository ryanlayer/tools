#!/bin/sh

############################################################
#  Program:
#  Author :
############################################################


## BEGIN SCRIPT
usage()
{
    cat << EOF

usage: $0 OPTIONS

OPTIONS can be:
    -h      Show this message
    -f      Filename
	-c		Chromosome (1, 2, ... X)
	-s		Start
	-e		End
	-w		Width (from s - w to e + w)
	-o		Output
	-n		Name
	-p		Normalization factor

EOF
}

# Show usage when there are no arguments.
if test -z "$1"
then
    usage
    exit
fi

FILENAME=
CHR=
START=
END=
W=
OUTPUT=
NAME=
NORM=

# Check options passed in.
while getopts "h f:c:s:e:w:o:n:p:" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        f)
            FILENAME=$OPTARG
            ;;
        c)
            CHR=$OPTARG
            ;;
        s)
            START=$OPTARG
            ;;
        e)
            END=$OPTARG
            ;;
        w)
            W=$OPTARG
            ;;
        o)
            OUTPUT=$OPTARG
            ;;
        n)
            NAME=$OPTARG
            ;;
        p)
            NORM=$OPTARG
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

if test -z "$FILENAME"
then
	echo "No file"
    usage
    exit
fi

if test -z "$CHR"
then
	echo "No chromosome"
    usage
    exit
fi


# Do something with the arguments...
echo track type=bedGraph name=\"$NAME\" 

grep "^$CHR" $FILENAME | \
	awk -v start=$START -v end=$END -v width=$W \
	'{
		OFS="\t";
		if ($3 > (start-width) && $2 < (end+width)) 
			print;
	}' 
