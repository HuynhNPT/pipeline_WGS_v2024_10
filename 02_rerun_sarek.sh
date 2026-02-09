#!/bin/bash
# Use this script to rerun the subSheet that did not go through sucessfully 
# This information should be in tmp_log
export YEAR=2026
export SUBSHEET_TO_RERUN=subSheet_aa
export PROJECT="Broad_y${YEAR}_${SUBSHEET_TO_RERUN}"
nextflow run nf-core/sarek \
            -r 3.4.4 \
            -with-report -resume \
            --input ${SUBSHEET_TO_RERUN}.csv \
            -profile cloud \
            -c gcp.config \
            --igenomes_base  gs://nextflow-batch-input/_resources/genomeMapping/GATK \
            --genome GATK.GRCh38 \
            --trim_fastq 0 \
            --outdir gs://nextflow-batch-output/WGS/${PROJECT} \
            --tools cnvkit,deepvariant,haplotypecaller,manta,strelka
