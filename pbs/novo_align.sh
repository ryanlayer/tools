#!/bin/sh

############################################################
#  Program: decrypt, extrast fastq from sra, align bwith bwq
#    need to add:
#       - extract NM from SAM push to a fasta file
#       - asseble the NM 
#       - align again with bwa
#       - extract NM to fasta
#       - align with novoalign
#       - extract NM to fasta
#       - blast
#  Author :
############################################################


## BEGIN SCRIPT
usage()
{
    cat << EOF

usage: $0 OPTIONS

OPTIONS can be:
  -h           Show this message
  -p  postfix  Target postfix (e.g., bwa.sorted.bam.NM.fastq)
  -t  dir      Target directory (default .)
  -i  index	   Index file (default hg19, k14, s2)
  -s           Print what would be qsubed
EOF
}

# Show usage when there are no arguments.
if test -z "$1"
then
    usage
    exit
fi

APP=novo_align
BIN=/net/dutta_tumor/bin
SAM_TOOLS=$BIN/samtools
RM=/bin/rm

NOVO="/net/dutta_tumor/bin/novoalign"
REF="/net/dutta_tumor/ref/novoalign/hg19_all_k14_s2"
OPT="-o SAM -r Random -e 50 -c 8"

TARGET_DIR=
TARGET_POST=
SIM=


# Check options passed in.
while getopts "s h t: p:i:" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        t)
            TARGET_DIR=$OPTARG
            ;;
        i)
            REF=$OPTARG
            ;;
        p)
            TARGET_POST=$OPTARG
            ;;
        s)
            SIM=1
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

if test -z "$TARGET_DIR"
then
	echo "No password target directory set"
	usage
	exit
fi

JIDS=

FILES=`find $TARGET_DIR -name "*$TARGET_POST"`
for FILE in $FILES
do
	DIR=`dirname $FILE`
	FASTQ_FILE=`basename $FILE`
	NAME=`basename $FILE .$TARGET_POST`

	NOVO_CMD="$NOVO $OPT -d $REF -f $FILE > $DIR/$NAME.novo.sam"

	TO_BAM="$SAM_TOOLS view -bS $DIR/$NAME.novo.sam -o $DIR/$NAME.novo.bam"
	RM_SAM="$RM $DIR/$NAME.novo.sam"
	SORT_BAM="$SAM_TOOLS sort $DIR/$NAME.novo.bam $DIR/$NAME.novo.sorted"
	INDEX_SAM="$SAM_TOOLS index $DIR/$NAME.novo.sorted.bam"

	CMD="$NOVO_CMD && \
		 $TO_BAM && \
		 $RM_SAM && \
		 $SORT_BAM && \
		 $INDEX_SAM"

	MEM="5g"
	THREADS="8"
	QSUB="/usr/pbs/bin/qsub"
	#RUN_NAME="novo_$NAME"
	#QSUB_CMD="$QSUB -l select=1:mem=$MEM:ncpus=$THREADS -m bae -N $RUN_NAME -M rl6sf@virginia.edu"
	RUN_NAME="novo_$NAME"
	QSUB_CMD="$QSUB -l select=1:mem=$MEM:ncpus=$THREADS -m bae -M rl6sf@virginia.edu"

	if test -z $SIM
	then
		#echo "cd \$PBS_O_WORKDIR; $CMD"
		#JID=`echo "cd \$PBS_O_WORKDIR; $CMD" | $QSUB_CMD`
		JID=`echo "cd \\$PBS_O_WORKDIR; $CMD" | $QSUB_CMD`
		#JID=`echo "cd \$PBS_O_WORKDIR; $CMD" | $QSUB_CMD`
		#echo $JID
		JIDS="$JIDS $JID"
	else
		echo $CMD
	fi
done

if test -n "$JIDS"
then
	DATE=`date +%Y%m%d_%T`
	echo $JIDS > $APP.$DATE.log
	cat $APP.$DATE.log
fi
