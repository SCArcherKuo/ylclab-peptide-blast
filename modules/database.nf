/*
 * Database preparation module
 */

process PREPARE_DATABASE_FASTA {
    /*
     * Prepare database FASTA file by modifying headers to include sequence information
     */
    
    input:
    path raw_fasta
    
    output:
    path "prepared_database.fasta"
    
    script:
    """
    #!/usr/local/bin/python
    from Bio import SeqIO
    
    # Read input FASTA and modify headers
    with open("prepared_database.fasta", 'w') as output_handle:
        for record in SeqIO.parse("${raw_fasta}", 'fasta'):
            output_handle.write(f">{record.seq}={record.id}\\n{record.seq}\\n")
    """
}

process CREATE_BLAST_DATABASE {
    /*
     * Create BLAST protein database from prepared FASTA file
     */
    
    input:
    path db_fasta
    val db_name
    
    output:
    path "blastdb/*"
    
    script:
    """
    mkdir -p blastdb
    makeblastdb \\
        -in ${db_fasta} \\
        -dbtype prot \\
        -out blastdb/${db_name} \\
        -title "Peptide Database"
    """
}