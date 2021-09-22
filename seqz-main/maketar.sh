#!/usr/bin/env bash

# make tar_content.json
echo "{
  \"CN_bars.pdf\": \"CN_bars.pdf\",
  \"CP_contours.pdf\": \"CP_contours.pdf\",
  \"CP_contours_post_prob_distr.pdf\": \"CP_contours_post_prob_distr.pdf\",
  \"alternative_fit.pdf\": \"alternative_fit.pdf\",
  \"alternative_solutions.txt\": \"alternative_solutions.txt\",
  \"chromosome_depths.pdf\": \"chromosome_depths.pdf\",
  \"chromosome_view.pdf\": \"chromosome_view.pdf\",
  \"confints_CP.txt\": \"confints_CP.txt\",
  \"gc_plots.pdf\": \"gc_plots.pdf\",
  \"genome_view.pdf\": \"genome_view.pdf\",
  \"model_fit.pdf\": \"model_fit.pdf\",
  \"mutations.txt\": \"mutations.txt\",
  \"segments.txt\": \"segments.txt\",
  \"sequenza_cp_table.RData\": \"sequenza_cp_table.RData\",
  \"sequenza_extract.RData\": \"sequenza_extract.RData\",
  \"sequenza_log.txt\": \"sequenza_log.txt\",
  \"sequenza_session.RData\": \"sequenza_session.RData\"
}" > tar_content.json

# tar the results
tar -czf sequenza-outputs.tgz CN_bars.pdf CP_contours.pdf CP_contours_post_prob_distr.pdf alternative_fit.pdf alternative_solutions.txt chromosome_depths.pdf chromosome_view.pdf confints_CP.txt gc_plots.pdf genome_view.pdf model_fit.pdf mutations.txt segments.txt sequenza_cp_table.RData sequenza_extract.RData sequenza_log.txt sequenza_session.RData tar_content.json tar_content.json