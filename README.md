# Peptide BLAST Analysis Workflow

## Overview

This repository contains a comprehensive Nextflow workflow for **peptide BLAST analysis** against multiple species databases. The workflow automates the entire process from database preparation to final analysis, providing a reproducible and scalable approach to peptide sequence conservation analysis.

## Quick Start

```bash
# Show help and available parameters
nextflow run main.nf --help

# Use test data for validation
nextflow run main.nf -profile test,docker

# Run the complete workflow with Docker
nextflow run main.nf -profile docker
```

## Project Structure

```
├── main.nf                   # Main workflow entry point
├── nextflow.config           # Configuration and parameters
├── assets/                   # Input data directory
│   ├── blast_peptide_db/     # Database FASTA files
│   └── blast_query_peptide/  # Query FASTA files
├── workflows/                # Workflow definitions
│   └── main.nf               # Main workflow implementation
├── modules/                  # Process modules
│   ├── database.nf           # Database preparation processes
│   ├── blast.nf              # BLAST search processes
│   └── analysis.nf           # R analysis processes
├── templates/                # R script templates
│   ├── analyze_individual.R  # Individual file analysis
│   └── merge_results.R       # Results merging script
├── conf/                     # Configuration files
│   ├── base.config           # Base process configuration
│   ├── modules.config        # Module-specific settings
│   └── test.config           # Test configuration
├── test_data/                # Test datasets
└── dockerfiles/              # Custom container definitions
```

## Workflow Features

The workflow processes multiple peptide query files against multi-species databases and provides:

- **Automated Database Preparation**: Modifies FASTA headers and creates BLAST databases
- **Parallel BLAST Search**: Efficient protein sequence similarity search
- **Statistical Analysis**: R-based filtering and conservation analysis
- **Results Merging**: Combines and processes results from multiple files

## Installation and Setup

### Prerequisites

1. **Nextflow**: Nextflow (pretested on version 25.04.7)

2. **Container Engine**: Docker

### Data Preparation

1. **Query Files**: Place your peptide sequence files in FASTA format (*.fasta) in `assets/blast_query_peptide/`
2. **Database Files**: Place your peptide database files in FASTA format (*.fasta) in `assets/blast_peptide_db/`

## Usage

### Basic Usage

```bash
# Run with default parameters using Docker
nextflow run main.nf -profile docker

# Show help message with all available parameters
nextflow run main.nf --help

# Run workflow with custom parameters
nextflow run main.nf \
    --query "assets/blast_query_peptide/*.fasta" \
    --raw_db_fasta "assets/blast_peptide_db/*.fasta" \
    --identity_threshold 60 \
    --num_threads 8 \
    --output_dir "custom_results" \
    -profile docker
```

### Parameters

#### Input Options
- `--query`: Path to query FASTA file(s) (default: `assets/blast_query_peptide/*.fasta`)
- `--raw_db_fasta`: Path to raw database FASTA file(s) (default: `assets/blast_peptide_db/*.fasta`)

#### BLAST Options
- `--evalue`: E-value threshold (default: `100`)
- `--num_threads`: Number of threads for BLAST (default: `4`)

#### Analysis Options
- `--identity_threshold`: Minimum identity percentage for filtering (default: `50`)

#### Output Options
- `--output_dir`: Output directory (default: `results/`)

### Execution Profiles

#### Docker Profile (Recommended)
Uses containerized execution for reproducibility:
```bash
nextflow run main.nf -profile docker
```

#### Test Profile
Runs with small test datasets for validation:
```bash
nextflow run main.nf -profile test,docker
```

## Workflow Steps

The workflow consists of the following main steps:

### 1. Database Preparation
- Combines multiple database FASTA files
- Modifies FASTA headers to include sequence information for downstream analysis
- Uses BioPython for sequence processing

### 2. BLAST Database Creation
- Creates protein BLAST database using `makeblastdb`
- Optimizes database for efficient searching

### 3. BLAST Search
- Executes `blastp` search against the prepared database
- Processes multiple query files in parallel
- Uses customized output format for downstream analysis

### 4. Results Analysis
- Filters BLAST results based on identity threshold
- Calculates sequence coverage and conservation metrics
- Generates summary statistics using R

### 5. Results Merging
- Merges results from multiple query files
- Handles duplicate removal and data consistency
- Produces final consolidated output

## Container Requirements

The workflow uses the following Docker containers:

- **`archerkuo/nextflow-biopython:1.0.0`**: Homemade image for database preparation and sequence processing
- **`ncbi/blast:2.17.0`**: BLAST database creation and protein sequence searching
- **`rocker/tidyverse:4.5.1`**: R-based statistical analysis and data processing

All containers are automatically pulled and managed by Nextflow when using the Docker profile.

## Output Structure

The workflow generates a structured output directory:

```
results/
├── database/                     # Database files
│   ├── blast_db.fasta            # Combination of raw FASTA files
│   ├── prepared_database.fasta   # Modified FASTA with sequence info
│   └── blastdb/                  # BLAST database files
├── blast/                        # BLAST results per query file
│   └── <filename>_blast_result.csv
├── analysis/                     # Analysis results per file
│   ├── <filename>_filtered_results.csv
│   └── <filename>_analysis_summary.txt
├── final/                        # Final merged results
│   ├── merged_filtered_results.csv
│   └── merged_analysis_summary.txt
└── reports/                      # Execution reports
    ├── timeline.html
    ├── report.html
    ├── trace.txt
    └── dag.dot
```