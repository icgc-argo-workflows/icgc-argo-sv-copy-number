#!/usr/bin/env bash

# make tar_content.json
echo "{
  \"sample_CN_bars.pdf\": \"sample_CN_bars.pdf\",
  \"sample_CP_contours.pdf\": \"sample_CP_contours.pdf\",
  \"sample_CP_contours_post_prob_distr.pdf\": \"sample_CP_contours_post_prob_distr.pdf\",
  \"sample_alternative_fit.pdf\": \"sample_alternative_fit.pdf\",
  \"sample_alternative_solutions.txt\": \"sample_alternative_solutions.txt\",
  \"sample_chromosome_depths.pdf\": \"sample_chromosome_depths.pdf\",
  \"sample_chromosome_view.pdf\": \"sample_chromosome_view.pdf\",
  \"sample_confints_CP.txt\": \"sample_confints_CP.txt\",
  \"sample_gc_plots.pdf\": \"sample_gc_plots.pdf\",
  \"sample_genome_view.pdf\": \"sample_genome_view.pdf\",
  \"sample_mutations.txt\": \"sample_mutations.txt\",
  \"sample_segments.txt\": \"sample_segments.txt\",
  \"sample_sequenza_cp_table.RData\": \"sample_sequenza_cp_table.RData\",
  \"sample_sequenza_extract.RData\": \"sample_sequenza_extract.RData\",
  \"sample_sequenza_log.txt\": \"sample_sequenza_log.txt\",
  \"sample_sequenza_session.RData\": \"sample_sequenza_session.RData\",
  \"sample_sessionInfo.txt\": \"sample_sessionInfo.txt\"
}" > tar_content.json

# tar the results
tar -czf seqz-main.tgz sample_CN_bars.pdf sample_CP_contours.pdf sample_CP_contours_post_prob_distr.pdf sample_alternative_fit.pdf sample_alternative_solutions.txt sample_chromosome_depths.pdf sample_chromosome_view.pdf sample_confints_CP.txt sample_gc_plots.pdf sample_genome_view.pdf sample_model_fit.pdf sample_mutations.txt sample_segments.txt sample_sequenza_cp_table.RData sample_sequenza_extract.RData sample_sequenza_log.txt sample_sequenza_session.RData sample_sessionInfo.txt tar_content.json