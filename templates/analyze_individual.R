#!/usr/local/bin/Rscript
library(readr)
library(tibble)
library(dplyr)
library(stringr)
library(magrittr)

# Read BLAST results
blast <- read_csv(
  "${blast_results}",
  col_names = c("qseqid", "sseqid", "pident", "nident", "length", 
               "qcovs", "qstart", "qend", "sstart", "send", 
               "gaps", "evalue", "staxids", "sacc"),
  show_col_types = FALSE
  ) %>%
  mutate(
    peplen = str_length(qseqid),
    sseq = str_extract(sacc, "(\\\\w+)=", 1),
    sacc = str_extract(sacc, "=(.+)", 1),
    slen = str_length(sseq),
    scov = round(nident / slen * 100, 3)
  ) %>%
  select("qseqid", "peplen", "pident", "nident", "scov", 
         "qstart", "qend", "sacc", "sseq", "sstart", "send", 
         "slen", "gaps")

# Create name mapping
name_map <- tibble(
  previous_name = character(),
  new_name = character()
) %>%
  add_row(previous_name = "qseqid", new_name = "query_peptide_sequence") %>%
  add_row(previous_name = "peplen", new_name = "query_peptide_length") %>%
  add_row(previous_name = "pident", new_name = "identity_percentage") %>%
  add_row(previous_name = "nident", new_name = "identically_aligned_amino_acid_length") %>%
  add_row(previous_name = "sacc", new_name = "target_protein_id") %>%
  add_row(previous_name = "sseq", new_name = "target_peptide_sequence") %>%
  add_row(previous_name = "slen", new_name = "target_peptide_length") %>%
  add_row(previous_name = "sstart", new_name = "target_alignment_start") %>%
  add_row(previous_name = "send", new_name = "target_alignment_end") %>%
  add_row(previous_name = "scov", new_name = "target_identically_aligned_coverage") %>%
  column_to_rownames(var = "previous_name")

# Filter results
filtered_blast <- blast %>%
  filter(qstart == 1, qend == peplen, pident >= ${identity_threshold}) %>%
  select("qseqid", "peplen", "pident", "nident", "scov", 
         "sacc", "sseq", "slen", "sstart", "send") %>%
  rename_with(~ name_map[.x, "new_name"], everything())

# Write results
write_csv(filtered_blast, "${file_id}_filtered_results.csv")

# Generate summary
summary_stats <- filtered_blast %>%
  summarise(
    total_matches = n(),
    unique_queries = n_distinct(query_peptide_sequence),
    unique_targets = n_distinct(target_protein_id),
    avg_identity = mean(identity_percentage, na.rm = TRUE),
    min_identity = min(identity_percentage, na.rm = TRUE),
    max_identity = max(identity_percentage, na.rm = TRUE)
  )

writeLines(c(
  "BLAST Analysis Summary",
  "=====================",
  paste("Total matches:", summary_stats[["total_matches"]]),
  paste("Unique query sequences:", summary_stats[["unique_queries"]]),
  paste("Unique target proteins:", summary_stats[["unique_targets"]]),
  paste(
    "Average identity percentage:",
    round(summary_stats[["avg_identity"]], 2)
  ),
  paste(
    "Identity range:",
    round(summary_stats[["min_identity"]], 2), "-",
    round(summary_stats[["max_identity"]], 2)
  )
), "${file_id}_analysis_summary.txt")