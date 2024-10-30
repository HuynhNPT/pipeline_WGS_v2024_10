#!/bin/bash

nextflow run nf-core/sarek \
            -r 3.4.4 \
            -with-report \
            --input samplesheet.csv \
            -profile cloud \
            -c gcp.config \
            --igenomes_base  gs://nextflow-batch-input/_resources/genomeMapping/GATK \
            --genome GATK.GRCh38 \
            --trim_fastq 0 \
            --outdir gs://nextflow-batch-output/WGS/Broad_240829_noTRIM \
            --tools cnvkit,deepvariant,haplotypecaller,manta,strelka