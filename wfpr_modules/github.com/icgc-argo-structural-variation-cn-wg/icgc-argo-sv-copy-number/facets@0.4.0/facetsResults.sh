#!/bin/bash

function usage() {
  if [ -n "$1" ]; then
    echo -e "Error: $1\n";
  fi
  echo "extracts facets metrics and archives facets results"
  echo "Usage: $0 [-s summary] [-c cncf] [-p plot]"
  echo "  -s, --summary   facets summary file"
  echo "  -c, --cncf      facets cncf file"
  echo "  -p, --plot      facets plot file"
  echo ""
  exit 1
}

# parse params
while [[ "$#" > 0 ]]; do case $1 in
  -s|--summary) SUMMARY="$2"; shift;shift;;
  -c|--cncf) CNCF="$2";shift;shift;;
  -p|--plot) PLOT="$2";shift;shift;;
  *) usage "Unknown parameter passed: $1"; shift; shift;;
esac; done

# verify mandatory inputs
if [ -z "$SUMMARY" ]; then usage "Summary file not provided"; fi;

# verify input files

if [ ! -f "$SUMMARY" ]; then usage "Input file $SUMMARY does not exist"; fi;


echo "{
  \"tool\": {
    \"name\": \"facets\",
    \"version\": \"$(grep Version $SUMMARY | sed -E -e 's/.+= //g' -e 's/ $//')\"
  },
  \"metrics\": {" > facets_metrics.json

# fill json report from facets summary file
tail -n+2 $SUMMARY | sed -E -e 's/\# /    \"/' -e 's/ \= (.+) $/\": \"\1\",/g' -e 's/\"([0-9\.\-]+)\"/\1/g' -e 's/dipt =/dipt" : ,/' -e 's/(loglik.+),/\1\n  }\n}/' >> facets_metrics.json

# make tar_content.json
# cncf and plot can be missing from facets results, but if produced both will be available
if [[ -f "$CNCF" && -f "$PLOT" ]]
then
 echo "{
  \"facets_metrics\": \"facets_metrics.json\",
  \"facets_summary\": \"$(basename $SUMMARY)\",
  \"facets_cncf\": \"$(basename $CNCF)\",
  \"facets_plot\": \"$(basename $PLOT)\"
}" > tar_content.json
else
echo "{
  \"facets_metrics\": \"facets_metrics.json\",
  \"facets_summary\": \"$(basename $SUMMARY)\"
}" > tar_content.json
fi

# tar the results
tar -czf $(basename -s .out $SUMMARY).tgz facets_metrics.json tar_content.json $SUMMARY $CNCF $PLOT
