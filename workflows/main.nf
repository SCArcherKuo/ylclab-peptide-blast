/*
 * Multiple files workflow
 * 
 * This workflow processes multiple separate query files
 * without chunking and merges their results.
 */

include { PREPARE_DATABASE_FASTA; CREATE_BLAST_DATABASE } from '../modules/database'
include { BLAST_SEARCH } from '../modules/blast'
include { ANALYZE_BLAST_RESULTS; MERGE_MULTIPLE_RESULTS } from '../modules/analysis'

workflow FIND_PEPTIDE_MATCHES {
    main:
    /*
     * Workflow for processing multiple separate files and merging results
     */
    
    // Step 1: Prepare database FASTA (add sequence info to headers)
    blast_db_fasta = Channel
        .fromPath(params.raw_db_fasta, checkIfExists: true)
        .collectFile(
            name: 'blast_db.fasta',
            newLine: true,
            storeDir: "${params.output_dir}/database"
        )
    PREPARE_DATABASE_FASTA(blast_db_fasta)
    
    // Step 2: Create BLAST database
    blast_db = CREATE_BLAST_DATABASE(PREPARE_DATABASE_FASTA.out, params.db_name)
    
    // Step 3: Process multiple query files separately
    query_files = Channel.fromPath(params.query, checkIfExists: true)
    
    // Step 4: Construct the full path to the BLAST database
    blast_db_path = blast_db
        .map { files -> files[0].parent.resolve(params.db_name) }

    // Step 5: Run BLAST for each file
    blast_results_per_file = BLAST_SEARCH(
        query_files.combine(blast_db_path)
    )

    // Step 6: Analyze each file separately
    analyzed_results = ANALYZE_BLAST_RESULTS(
        blast_results_per_file,
        params.identity_threshold
    )

    // Step 7: Merge all analyzed results
    all_results = analyzed_results.filtered_results.collect()
    MERGE_MULTIPLE_RESULTS(all_results)
    
    emit:
    all_outputs = analyzed_results.filtered_results
        .mix(analyzed_results.analysis_summary)
        .mix(MERGE_MULTIPLE_RESULTS.out.filtered_results)
        .mix(MERGE_MULTIPLE_RESULTS.out.analysis_summary)
}