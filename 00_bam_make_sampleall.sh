#!/bin/bash
rm patient bam md5
gsutil ls -r gs://nextflow-batch-input/platform/WGS/Broad_[PLACEHOLDERfx-201020]_bam* > tmp
gsutil ls -r gs://nextflow-batch-input/platform/WGS/broad_checksums_v2411/ | grep md5$ > tmp_checksum
cat tmp | grep "bam$"  > bam
cat bam | sed 's#.*/##' | sed 's/\.bam.*//' > patient
while read line; do 
    grep $line tmp_checksum >> md5
done < patient

paste patient bam md5 | tr '\t' ',' > samples_all
sed -i '1i sample_name,bam,checksum' samples_all
sed -i 's#gs://nextflow-batch-input/platform/WGS/##g' samples_all

rm bam md5 patient 