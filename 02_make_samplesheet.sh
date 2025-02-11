#!/bin/bash

gsutil ls -r gs://nextflow-batch-input/platform/WGS/[PLACEHOLDERfx-y2021]_Broad/FASTQ_CONVERTED/**/*R1.fastq.gz > r1
gsutil ls -r gs://nextflow-batch-input/platform/WGS/[PLACEHOLDERfx-y2021]_Broad/FASTQ_CONVERTED/**/*R2.fastq.gz > r2
cat samples_all | awk -F ',' '{print $1}' | tail -n+2 > patient

rm lane; touch lane; 
rm RR1; touch RR1
rm RR2; touch RR2
while read line; do  
    echo L1 >> lane
    grep $line r1 >> RR1
    grep $line r2 >> RR2
done < patient

paste patient patient lane RR1 RR2 | tr '\t' ',' > samplesheet.csv
rm patient lane r1 r2 RR1 RR2