#!/bin/bash
# Use this script to rerun the subSheet that did not go through sucessfully 
# This information should be in tmp_log
# export YEAR=260427B
export YEAR=[PLACEHOLDER_YYMMDDalphabet]
# export SUBSHEET_TO_RERUN=subSheet_aa
# export PROJECT="Broad_y${YEAR}_${SUBSHEET_TO_RERUN}"

# export YEAR=260427C
# export ff=subSheet_ad
# export PROJECT="Broad_nr${YEAR}_${ff}"

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

# A log of whether this subSheet run was successful or not
if [ $? -eq 0 ]; then
    echo "Finished processing ${PROJECT}" >> tmp_log
else 
    echo "${PROJECT} error out with exit status $?" >> tmp_log
fi