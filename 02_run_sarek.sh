#!/bin/bash
export YEAR=[PLACEHOLDERfx-2021]
# export YEAR=2024
cat samplesheet.csv  | split -l 15  - subSheet_

for ff in subSheet_*; do
    sed -i '1i patient,sample,lane,fastq_1,fastq_2' ${ff}

    export PROJECT="Broad_y${YEAR}_${ff}"
    
    # Safeguard so that old PROJECT is not overwritten
    until ! gsutil ls gs://nextflow-batch-output/WGS/${PROJECT} &>/dev/null
    do
        echo "Detected conflicts in PROJECT name. Renaming..."
        RANDOM_TAG=$(openssl rand -hex 6)
        PROJECT="Broad_y${YEAR}_${RANDOM_TAG}"
    done
    
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
    
    # A log of whether this subSheet run was successful or not
    if [ $? -eq 0 ]; then
        echo "Finished processing ${PROJECT}" >> tmp_log
    else 
        echo "${PROJECT} error out with exit status $?" >> tmp_log
    fi

    # Rename subSheet to reflect new project name if new tag was added because of conflict
    if [ "$PROJECT" == "Broad_y${YEAR}_${ff}" ]
    then
        echo ""
    else
        echo "Renaming subsheet with random tag..."
        mv ${ff}.csv subSheet_${RANDOM_TAG}.csv
    fi

done