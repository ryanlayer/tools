#!/bin/bash

usage()
{
    cat << EOF

usage: $0 OPTIONS

version: 0.1

OPTIONS can be:
  -h  Show this message
  -i  Input fasta file
  -o  Output file prefix
  -r  Read length
  -l  Library length
  -c  Coverage
  -R  fraction of INDEL errors (default 0.15)
  -e  Base error rate (default 0.01)
EOF
}


# Show usage when there are no arguments.
if test -z "$1"
then
    usage
    exit 1
fi

INPUT=
OUTPUT=
READ_LEN=
INDELS=0.15
LIB_LEN=
COVERAGE=
BASE_ERROR=0.01
MUTATION=0

# Check options passed in.
while getopts "h i:o:r:l:c:e:R:" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        i)
            INPUT=$OPTARG
            ;;
        R)
            INDELS=$OPTARG
            ;;
        o)
            OUTPUT=$OPTARG
            ;;
        r)
            READ_LEN=$OPTARG
            ;;
        l)
            LIB_LEN=$OPTARG
            ;;
        c)
            COVERAGE=$OPTARG
            ;;
        e)
            BASE_ERROR=$OPTARG
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

if [ -z "$INPUT" ]
then
	echo "No input file given"
	usage
	exit 1
fi
if [ -z "$OUTPUT" ]
then
	echo "No output prefix given"
	usage
	exit 1
fi
if [ -z "$READ_LEN" ]
then
	echo "No read length given"
	usage
	exit 1
fi
if [ -z "$LIB_LEN" ]
then
	echo "No library length given"
	usage
	exit 1
fi
if [ -z "$COVERAGE" ]
then
	echo "No coverage given"
	usage
	exit 1
fi


#find the size of the input
SIZE=`grep -v "^>" $INPUT | paste -s -d '' | wc -m`

NUM_PAIRS=`calc "($SIZE*$COVERAGE)/($READ_LEN*2)" | cut -d "." -f1`

#Usage:   wgsim [options] <in.ref.fa> <out.read1.fq> <out.read2.fq>
#
#Options: -e FLOAT      base error rate [0.020]
#         -d INT        outer distance between the two ends [500]
#         -s INT        standard deviation [50]
#         -N INT        number of read pairs [1000000]
#         -1 INT        length of the first read [70]
#         -2 INT        length of the second read [70]
#         -r FLOAT      rate of mutations [0.0010]
#         -R FLOAT      fraction of indels [0.15]
#         -X FLOAT      probability an indel is extended [0.30]
#         -S INT        seed for random generator [-1]
#         -A FLOAT      disgard if the fraction of ambiguous bases higher
#         -h            haplotype mode

rm -f $OUTPUT.c$COVERAGE.1.fq
rm -f $OUTPUT.c$COVERAGE.2.fq
for i in $(seq 1 $NUM_PAIRS)
do
	wgsim -d $LIB_LEN \
		-N 1 \
		-1 $READ_LEN \
		-2 $READ_LEN \
		-r $BASE_ERROR \
		-R $INDELS \
		$INPUT \
		$OUTPUT.c$COVERAGE.1.fq.tmp \
		$OUTPUT.c$COVERAGE.2.fq.tmp 2>/dev/null >/dev/null
	cat $OUTPUT.c$COVERAGE.1.fq.tmp >> $OUTPUT.c$COVERAGE.1.fq
	cat $OUTPUT.c$COVERAGE.2.fq.tmp >> $OUTPUT.c$COVERAGE.2.fq
done
rm $OUTPUT.c$COVERAGE.1.fq.tmp
rm $OUTPUT.c$COVERAGE.2.fq.tmp
