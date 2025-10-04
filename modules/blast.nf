/*
 * BLAST search module
 */

process BLAST_SEARCH {
    /*
     * Execute BLAST search for complete query files (for multiple file workflow)
     */
    
    tag { query_file.baseName }

    input:
    tuple path(query_file), val(blast_db)
    
    output:
    tuple val("${query_file.baseName}"), path("${query_file.baseName}_blast_results.csv")
    
    script:
    """
    blastp \\
        -query ${query_file} \\
        -db ${blast_db} \\
        -out ${query_file.baseName}_blast_results.csv \\
        -evalue ${params.evalue} \\
        -outfmt '${params.blast_outfmt}' \\
        -num_threads ${params.num_threads}
    """
}