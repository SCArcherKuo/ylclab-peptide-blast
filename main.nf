#!/usr/bin/env nextflow

/*
 * Peptide BLAST Workflow
 * 
 * This workflow performs the complete peptide BLAST analysis pipeline:
 * 1. Prepare BLAST database from FASTA files
 * 2. Create BLAST database
 * 3. Execute BLAST search
 * 4. Filter and analyze results with R
 * 5. Merge duplicated rows in the analysis results
 */

nextflow.enable.dsl = 2

// Import workflows
include { MULTIPLE_FILES } from './workflows/main'

// Help message
def helpMessage() {
    log.info """
    ========================================================================
    Peptide BLAST Workflow
    ========================================================================
    
    Usage:
    nextflow run blast.nf [options]
    
    Input options:
    --query             Path to query FASTA file(s) [${params.query}]
    --raw_db_fasta      Path to raw database FASTA file [${params.raw_db_fasta}]
    
    BLAST options:
    --db_name           Database name [${params.db_name}]
    --evalue            E-value threshold [${params.evalue}]
    --num_threads       Number of threads [${params.num_threads}]
    
    Analysis options:
    --identity_threshold    Minimum identity percentage [${params.identity_threshold}]
    
    Output options:
    --output_dir        Output directory [${params.output_dir}]
    
    Profiles:
    -profile docker     Use Docker containers
    -profile test       Use test data
    
    Help:
    --help              Show this help message
    
    ========================================================================
    """.stripIndent()
}


// Main workflow selector
workflow {
    main:
    // Show help message if requested
    if (params.help) {
        helpMessage()
        exit 0
    }
    MULTIPLE_FILES()
}





