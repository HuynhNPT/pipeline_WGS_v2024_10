#!/bin/bash
export projectDir="gs://nextflow-batch-input/platform/WGS/Broad_240829/download_broad_8_29_2024/"

gsutil ls "${projectDir}"*cram | sed 's#.*/##' | sed 's/\.cram//' > sample_list
cat sample_list | sed 's/$/\.cram/' > cram
cat sample_list | sed 's/$/\.cram\.crai/' > crai
cat sample_list | sed 's/$/\.cram\.md5sum/'  > md5

wc -l cram; wc -l crai; wc -l md5; wc -l sample_list
paste -d ',' sample_list cram crai md5 > samples_all

sed -i '1i sample_name,cram,crai,checksum' samples_all
rm sample_list; rm cram; rm crai; rm md5
