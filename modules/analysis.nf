/*
 * Analysis module for R-based post-processing
 */

process ANALYZE_BLAST_RESULTS {
    /*
     * Analyze BLAST results for individual files
     */
    
    tag { file_id }
    
    input:
    tuple val(file_id), path(blast_results)
    val identity_threshold
    
    output:
    path "${file_id}_filtered_results.csv", emit: filtered_results
    path "${file_id}_analysis_summary.txt", emit: analysis_summary

    script:
    template 'analyze_individual.R'
}

process MERGE_MULTIPLE_RESULTS {
    /*
     * Merge multiple filtered BLAST result files
     * This corresponds to the merge_blast_R_analysis script
     */
    
    input:
    path filtered_files
    
    output:
    path "merged_filtered_results.csv", emit: filtered_results
    path "merged_analysis_summary.txt", emit: analysis_summary
    
    script:
    template 'merge_results.R'
}