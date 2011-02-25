#!/bin/sh

############################################################
#  Program: Extract unmapped sequences from a sam file and
#           put into a fastq file
#  Author : Ryan M. Layer
############################################################


## BEGIN SCRIPT
usage()
{
    cat << EOF

usage: $0 OPTIONS

OPTIONS can be:
    -h      Show this message
    -p      Prefix, comma seperated
    -f      file name
	-a      Output FASTA (default is FASTQ)
EOF
}

# Show usage when there are no arguments.
if test -z "$1"
then
    usage
    exit
fi

PREFIX_CSV=
FILE=
FASTA=

# Check options passed in.
while getopts "a h p:f:" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        p)
            PREFIX_CSV=$OPTARG
            ;;
        f)
            FILE=$OPTARG
            ;;
        a)
            FASTA=1
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

if [ -n "$PREFIX_CSV" ]
then

	for PREFIX in `echo $PREFIX_CSV | sed -e "s/,/ /g"`
	do
		for FILE in `ls $PREFIX*.sam`
		do
			BASE=`basename $FILE .sam`
			echo $BASE.NM.fa
			if [ -z "$FASTA" ]
			then
				time samtools view -S -f 4 $FILE |\
					cut -f1,10,11 | \
					sed -e "s/\(.*\)\t\(.*\)\t\(.*\)$/@\1\n\2\n+\1\n\3/" >\
					$BASE.NM.fa
			else
				time samtools view -S -f 4 $FILE |\
					cut -f1,10,11 | \
					sed -e "s/\(.*\)\t\(.*\)\t\(.*\)$/>\1\n\2/" >\
					$BASE.NM.fa
			fi
		done
	done
else
	BASE=`basename $FILE .sam`
	if [ -z "$FASTA" ]
	then
		time samtools view -S -f 4 $FILE |\
			cut -f1,10,11 | \
			sed -e "s/\(.*\)\t\(.*\)\t\(.*\)$/@\1\n\2\n+\1\n\3/" >\
			$BASE.NM.fa
	else 
		time samtools view -S -f 4 $FILE |\
			cut -f1,10,11 | \
			sed -e "s/\(.*\)\t\(.*\)\t\(.*\)$/>\1\n\2/" >\
			$BASE.NM.fa
	fi
fi
# Do something with the arguments...

## END SCRIPT
