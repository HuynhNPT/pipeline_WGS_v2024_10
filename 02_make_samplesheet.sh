#!/bin/bash

gsutil ls -r gs://nextflow-batch-input/platform/WGS/y2023_Broad/FASTQ_CONVERTED/**/*R1.fastq.gz > r1
gsutil ls -r gs://nextflow-batch-input/platform/WGS/y2023_Broad/FASTQ_CONVERTED/**/*R2.fastq.gz > r2
cp r1 tmp
cat tmp  | sed 's#.*Sample_##' | sed 's#/.*##' > patient
rm lane; touch lane; 
for i in {1..57}; do  
    echo L1 >> lane
done
paste patient patient lane r1 r2 | tr '\t' ',' > samplesheet.csv
rm patient lane r1 r2 tmp