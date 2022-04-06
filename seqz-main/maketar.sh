#!/bin/bash

function usage() {
  if [ -n "$1" ]; then
    echo -e "Error: $1\n";
  fi
  echo "extracts sequenza metrics and archives sequenza results"
  echo "  --fit        alternative_fit.pdf"
  echo "  --solutions  alternative_solutions.txt"
  echo "  --depths     chromosome_depths.pdf"
  echo "  --chrview    chromosome_view.pdf"
  echo "  --bars       CN_bars.pdf"
  echo "  --confints   confints_CP.txt"
  echo "  --contours   CP_contours.pdf"
  echo "  --contpost   CP_contours_post_prob_distr.pdf"
  echo "  --gc         gc_plots.pdf"
  echo "  --genomeview genome_view.pdf"
  echo "  --modelfit   model_fit.pdf"
  echo "  --mutations  mutations.txt"
  echo "  --segments   segments.txt"
  echo "  --cptable    sequenza_cp_table.RData"
  echo "  --extract    sequenza_extract.RData"
  echo "  --log        sequenza_log.txt"
  echo "  --session    sequenza_session.RData"
  echo ""
  exit 1
}

# parse params
while [[ "$#" > 0 ]]; do case $1 in
  --fit) FIT="$2"; shift;shift;;
  --solutions) SOLUTIONS="$2"; shift;shift;;
  --depths) DEPTHS="$2"; shift;shift;;
  --chrview) CHRVIEW="$2"; shift;shift;;
  --bars) BARS="$2"; shift;shift;;
  --confints) CONFINTS="$2"; shift;shift;;
  --contours) CONTOURS="$2"; shift;shift;;
  --contpost) CONTPOST="$2"; shift;shift;;
  --gc) GC="$2"; shift;shift;;
  --genomeview) GENOMEVIEW="$2"; shift;shift;;
  --modelfit) MODELFIT="$2"; shift;shift;;
  --mutations) MUTATIONS="$2"; shift;shift;;
  --segments) SEGMENTS="$2"; shift;shift;;
  --cptable) CPTABLE="$2"; shift;shift;;
  --extract) EXTRACT="$2"; shift;shift;;
  --log) LOG="$2"; shift;shift;;
  --session) SESSION="$2"; shift;shift;;
  *) usage "Unknown parameter passed: $1"; shift; shift;;
esac; done

# verify mandatory inputs
if [ -z "$SOLUTIONS" ]; then usage "alternative_solutions.txt not provided"; fi;

# verify input files
if [ ! -f "$SOLUTIONS" ]; then usage "Input file $SOLUTIONS does not exist"; fi;

# make json report
echo "{
  \"tool\": {
    \"name\": \"R\",
    \"version\": \"$(R --version 2>&1 | sed -n -e 's/^.*R version //p' | sed -n -e 's/ .*//p')\"
    \"name\": \"Sequenza package\",
    \"version\": \"$(R -e "packageVersion('sequenza')" 2>&1 | sed -n -e 's/^.*\‘//p'| sed -n -e 's/\’.*//p')\"
  }," > sequenza_metrics.json

# make tar_content.json
echo "{
    \"sequenza_metrics.json\": \"sequenza_metrics.json\",
    \"fit\": \"$(basename $FIT)\",
    \"solutions\": \"$(basename $SOLUTIONS)\",
    \"depths\": \"$(basename $DEPTHS)\",
    \"chrview\": \"$(basename $CHRVIEW)\",
    \"bars\": \"$(basename $BARS)\",
    \"confints\": \"$(basename $CONFINTS)\",
    \"contours\": \"$(basename $CONTOURS)\",
    \"contpost\": \"$(basename $CONTPOST)\",
    \"gc\": \"$(basename $GC)\",
    \"genomeview\": \"$(basename $GENOMEVIEW)\",
    \"modelfit\": \"$(basename $MODELFIT)\",
    \"mutations\": \"$(basename $MUTATIONS)\",
    \"segments\": \"$(basename $SEGMENTS)\",
    \"cptable\": \"$(basename $CPTABLE)\",
    \"extract\": \"$(basename $EXTRACT)\",
    \"log\": \"$(basename $LOG)\",
    \"session\": \"$(basename $SESSION)\"
}" > tar_content.json

# fill json report from sequenza summary file
CELLULARITY=$(cat $SOLUTIONS | awk 'FNR == 2 {print $1}')
PLOIDY=$(cat $SOLUTIONS | awk 'FNR == 2 {print $2}')

echo "  \"metrics\": {
    \"cellularity\": \"$CELLULARITY\",
    \"ploidy\": \"$PLOIDY\"
  }
}" >> sequenza_metrics.json


# tar the results
tar -czf sequenza.tgz \
sequenza_metrics.json \
$FIT \
$SOLUTIONS \
$DEPTHS \
$CHRVIEW \
$BARS \
$CONFINTS \
$CONTOURS \
$CONTPOST \
$GC \
$GENOMEVIEW \
$MODELFIT \
$MUTATIONS \
$SEGMENTS \
$CPTABLE \
$EXTRACT \
$LOG \
$SESSION \
tar_content.json