// Use this script to preprocess Broad's delivered CRAM files into FASTQs 
// to feed into nf-core/sarek -ready pipeline
// Script aims to do two things: 
// 1. Compare checksum from Broad to storage checksum 
// 2. Use of samtools to reverse CRAM into FASTQ
process CHECKSUM {
    container 'us-east1-docker.pkg.dev/compute-workspace/omics-docker-repo/rnaseq2'
    cpus 4
    memory '32 GB'

    input:
    tuple val(SAMPLE),
    path(CRAM_FILE),
    path(CRAI_FILE),
    path (MD5_FILE)

    output:
    tuple val(SAMPLE), 
    env(is_faithful), emit: is_faithful

    shell:
    '''
    md5sum !{CRAM_FILE}  | awk '{print $1}' > file1
    cp !{MD5_FILE} file2
    echo "" >> file2
    if cmp --silent file1 file2
    then
        is_faithful=true
    else
        is_faithful=false
    fi
    '''


}

process CONVERT_TO_FASTQ {
    container 'us-east1-docker.pkg.dev/compute-workspace/omics-docker-repo/rnaseq2'
    cpus 10
    memory '80 GB'
    disk 1000.GB // disk option here overides google.batch.bootdisksize in config

    publishDir "${params.out_bucket}/Sample_${SAMPLE}", mode: 'copy'

    input:
    tuple val(SAMPLE), path(CRAM_FILE), path(CRAI_FILE), path(MD5_FILE)
    path FASTA_REF

    output:
    val "${SAMPLE}"
    path "${SAMPLE}_R1.fastq.gz"
    path "${SAMPLE}_R2.fastq.gz"

    script:
    """
    samtools view -b -T ${FASTA_REF} \
                  -@ ${task.cpus}-2 \
                  -o ${SAMPLE}_byCoord.bam \
                  ${CRAM_FILE}

    samtools sort -n \
                  -@ ${task.cpus}-2 \
                  -T ${SAMPLE}tmp \
                  -O bam \
                  -o ${SAMPLE}_sortedByName.bam \
                  ${SAMPLE}_byCoord.bam
                  
    samtools fastq -@ ${task.cpus}-2 \
                   --reference=${FASTA_REF} \
                   -1 ${SAMPLE}_R1.fastq.gz \
                   -2 ${SAMPLE}_R2.fastq.gz \
                   ${SAMPLE}_sortedByName.bam

    """
}

process CHECKSUM_FASTQ {
    container 'us-east1-docker.pkg.dev/compute-workspace/omics-docker-repo/rnaseq2'
    cpus 3
    memory '24 GB'
    disk 500.GB // disk option here overides google.batch.bootdisksize in config

    publishDir "${params.out_bucket}/Sample_${SAMPLE}", mode: 'copy'

    input:
    val SAMPLE
    path R1
    path R2

    output:
    path "*.md5"

    script:
    """
    md5sum ${R1} > ${R1}.md5
    md5sum ${R2} > ${R2}.md5
    """
}

workflow {
    reads_ch=Channel.fromPath("samples_all").splitCsv(header: true)
    | map {
        row -> [row.'sample_name', // tuple
                file("${params.projectDir}/${row.cram}"), 
                file("${params.projectDir}/${row.crai}"), 
                file("${params.projectDir}/${row.checksum}")] 
    }
    CHECKSUM(reads_ch)
    CHECKSUM.out.branch{
        failed: it[1]=="false"
        passed: it[1]=="true"
    }.set{ result }

    // Write out samples with corrupted CRAM files
    result.failed.map { sample, is_faithful -> sample }
                 .collectFile(name: "sample_corrupted.txt", storeDir: '.' , newLine: true )

    // Submit samples with integrity-checked CRAM files to convert to fastq
    input_ch = result.passed.map{sample, is_faithful -> sample}.join(reads_ch, remainder: false )
    input_ch.view()
    input_ref=file("${params.fastaDir}")
    CONVERT_TO_FASTQ(input_ch, input_ref)
    // Add checksums for newly generated fastq files
    CHECKSUM_FASTQ(CONVERT_TO_FASTQ.out)
}