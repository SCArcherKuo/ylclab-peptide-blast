#!/usr/bin/env Rscript
library(dplyr)
library(readr)
library(purrr)

# Read all filtered files
file_list <- list.files(
  path = dirname("."),
  pattern = "*_filtered_results.csv",
  full.names = TRUE
)
all_data <- map_dfr(file_list, read_csv, show_col_types = FALSE)

# Remove target_alignment_start and target_alignment_end columns if they exist
if("target_alignment_start" %in% names(all_data)) {
    all_data <- all_data %>% select(-target_alignment_start)
}
if("target_alignment_end" %in% names(all_data)) {
    all_data <- all_data %>% select(-target_alignment_end)
}

# Check for inconsistencies in duplicate combinations
duplicate_check <- all_data %>%
  group_by(query_peptide_sequence, target_peptide_sequence) %>%
  summarise(
    n_identity_pct = n_distinct(identity_percentage),
    n_aligned_aa_len = n_distinct(identically_aligned_amino_acid_length),
    .groups = "drop"
  ) %>%
  filter(n_aligned_aa_len > 1 | n_identity_pct > 1)
# For each pair of query and target sequences, there should be only one unique
# value for identically_aligned_amino_acid_length and identity_percentage.
# Based on these checks, for each pair of query and target sequences,
# the only column that can have multiple values is target_protein_id.
# P.S. The following relationships hold:
# f(query_peptide_sequence) = query_peptide_length
# f(target_peptide_sequence) = target_peptide_length
# f(target_peptide_sequence, identically_aligned_amino_acid_length) =
# target_identically_aligned_coverage

# Remove duplicates
deduplicated_data <- all_data %>%
  distinct(
    query_peptide_sequence,
    target_protein_id,
    target_peptide_sequence,
    .keep_all = TRUE
  )

# Merge rows with same query and target sequences
final_data <- deduplicated_data %>%
  group_by(query_peptide_sequence, target_peptide_sequence) %>%
  summarise(
    query_peptide_length = paste(unique(query_peptide_length), collapse = ";"),
    identity_percentage = paste(unique(identity_percentage), collapse = ";"),
    identically_aligned_amino_acid_length = paste(unique(identically_aligned_amino_acid_length), collapse = ";"),
    target_identically_aligned_coverage = paste(unique(target_identically_aligned_coverage), collapse = ";"),
    target_protein_id = paste(unique(target_protein_id), collapse = ";"),
    target_peptide_length = paste(unique(target_peptide_length), collapse = ";"),
    .groups = "drop"
  )

# Write merged results
write_csv(final_data, "merged_filtered_results.csv")

# Generate summary
writeLines(c(
    "Merge Summary",
    "=============",
    if(nrow(duplicate_check) > 0) paste("Warning: Found", nrow(duplicate_check), "inconsistent duplicate combinations") else "No inconsistent duplicates found",
    paste("Input files processed:", length(file_list)),
    paste("Total rows before deduplication:", nrow(all_data)),
    paste("Total rows after deduplication:", nrow(deduplicated_data)),
    paste("Final merged rows:", nrow(final_data)),
    paste("Unique query sequences:", n_distinct(final_data[["query_peptide_sequence"]])),
    paste("Unique target sequences:", n_distinct(final_data[["target_peptide_sequence"]]))
  ),
  "merged_analysis_summary.txt"
)