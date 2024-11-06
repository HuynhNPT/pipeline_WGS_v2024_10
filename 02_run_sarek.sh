#!/bin/bash

cat samplesheet.csv  | split -l 10 - subSheet_

for ff in subSheet_*; do
    sed -i '1i patient,sample,lane,fastq_1,fastq_2' ${ff}
    export PROJECT="Broad_y2023_${ff}"
    echo ${PROJECT}

    cp ${ff} ${ff}.csv
    nextflow run nf-core/sarek \
                -r 3.4.4 \
                -with-report \
                --input ${ff}.csv \
                -profile cloud \
                -c gcp.config \
                --igenomes_base  gs://nextflow-batch-input/_resources/genomeMapping/GATK \
                --genome GATK.GRCh38 \
                --trim_fastq 0 \
                --outdir gs://nextflow-batch-output/WGS/${PROJECT} \
                --tools cnvkit,deepvariant,haplotypecaller,manta,strelka
    if [ $? -eq 0 ]; then
        echo "Finished processing ${PROJECT}" >> tmp_log
    else 
        echo "${PROJECT} error out with exit status $?" >> tmp_log
    fi
done