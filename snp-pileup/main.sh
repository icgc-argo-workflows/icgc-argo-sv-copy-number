#!/usr/bin/env bash -eu

# This script runs snp-pileup. It's meant to deal with cram input, so the ref fasta is required (bam will work as well).

function usage() {
  if [ -n "$1" ]; then
    echo -e "Error: $1\n";
  fi
  echo "run picard CollectHsMetrics"
  echo "Usage: $0 [-t tumor] [-n normal] [-r reference] [-s dbsnp] [-q min-map-quality] [-Q min-base-quality] [-r min-read-counts] [-d max-depth] [-P pseudo-snps]"
  echo "  -t, --tumor             Tumor bam or cram file."
  echo "  -n, --normal            Normal bam or cram file."
  echo "  -g, --reference         Reference genome file (the same as the one used for cram/bam). Must be in the current folder"
  echo "                          The *.fai index must be available, as well as the *.gzi in case of a compressed fasta file."
  echo "  -s, --dbsnp             Path to the germline resource VCF."
  echo "  -q, --min-map-quality   Sets the minimum threshold for mapping quality."
  echo "  -Q, --min-base-quality  Sets the minimum threshold for base quality."
  echo "  -r, --min-read-counts   Comma separated list of minimum read counts for a position to be output."
  echo "  -d, --max-depth         Sets the maximum depth."
  echo "  -P, --pseudo-snps       If there is no SNP, insert a blank record with the total count every <P> position."
  echo "  -o, --outfile           Output file."
  echo ""
  exit 1
}

# parse params
while [[ "$#" > 0 ]]; do case $1 in
  -t|--tumor) TUMOR="$2"; shift;shift;;
  -n|--normal) NORMAL="$2"; shift;shift;;
  -g|--reference) REF="$2";shift;shift;;
  -s|--dbsnp) DBSNP="$2";shift;shift;;
  -q|--min-map-quality) MAPQ="$2";shift;shift;;
  -Q|--min-base-quality) BASEQ="$2";shift;shift;;
  -r|--min-read-counts) READC="$2";shift;shift;;
  -d|--max-depth) DEPTH="$2";shift;shift;;
  -P|--pseudo-snps) PSEUDO="$2";shift;shift;;
  -o|--outfile) OUTFILE="$2";shift;shift;;
  *) usage "Unknown parameter passed: $1"; shift; shift;;
esac; done

# verify params
if [ -z "$TUMOR" ]; then usage "TUMOR not provided"; fi;
if [ -z "$NORMAL" ]; then usage "NORMAL not provided"; fi;
if [ -z "$REF" ]; then usage "REF not provided."; fi;
if [ -z "$DBSNP" ]; then usage "DBSNP file not provided."; fi;
if [ -z "$MAPQ" ]; then usage "MAPQ not provided."; fi;
if [ -z "$BASEQ" ]; then usage "BASEQ not provided."; fi;
if [ -z "$READC" ]; then usage "READC not provided."; fi;
if [ -z "$DEPTH" ]; then usage "DEPTH not provided."; fi;
if [ -z "$PSEUDO" ]; then usage "PSEUDO not provided."; fi;
if [ -z "$OUTFILE" ]; then usage "OUTFILE not provided."; fi;

# verify input files
if [ ! -f "$TUMOR" ]; then usage "Input file $INPUT does not exist"; fi;
if [ ! -f "$NORMAL" ]; then usage "Input file $NORMAL does not exist"; fi;
# it's possible that REF is a full path to current folder
REF=$(basename "$REF")
if [ ! -f "$REF" ]; then usage "Reference file $REF does not exist in the current folder."; fi;
if [ ! -f "$REF.fai" ]; then usage "Index file $REF.fai does not exist."; fi;
if [ "${REF##*.}" == "gz" ]; then if [ ! -f "$REF.gzi" ]; then usage "Index file $REF.gzi does not exist."; fi; fi
if [ "${REF##*.}" == "bgz" ]; then if [ ! -f "$REF.bgzi" ]; then usage "Index file $REF.bgzi does not exist."; fi; fi
if [ ! -f "$DBSNP" ]; then usage "dbSNP file $DBSNP does not exist."; fi;


# if input is cram then fix the ref URL in the header to point to $REF
if [ "${TUMOR##*.}" == "cram" ]
then
  samtools view -H "$TUMOR" | sed -E "s/^(@SQ\t.+UR:).+/\1$REF/g" > tumor.header
  samtools reheader tumor.header "$TUMOR" > tumor_reheaded.cram
fi

if [ "${NORMAL##*.}" == "cram" ]
then
  samtools view -H "$NORMAL" | sed -E "s/^(@SQ\t.+UR:).+/\1.\/$REF/g" > normal.header
  samtools reheader normal.header "$NORMAL" > normal_reheaded.cram
fi

# run snp-pileup
snp-pileup -A -g -P "$PSEUDO" -d "$DEPTH" -q "$MAPQ" -Q "$BASEQ" -r "$READC" "$DBSNP" "$OUTFILE" "$(if [ "${NORMAL##*.}" == "cram" ]; then echo normal_reheaded.cram; else echo $NORMAL; fi)" "$(if [ "${TUMOR##*.}" == "cram" ]; then echo tumor_reheaded.cram; else echo $TUMOR; fi)"
rm -f tumor_reheaded.cram normal_reheaded.cram
