#!/bin/bash
gsutil ls -r gs://nextflow-batch-input/platform/WGS/23* > tmp

cat tmp | grep "cram$"  > cram
cat tmp | grep "crai$"  > crai
cat tmp | grep "md5"  > md5

cat cram | sed 's#.*/##' | sed 's/\.cra.*//' > patient

paste patient cram crai md5 | tr '\t' ',' > samples_all
sed -i '1i sample_name,cram,crai,checksum' samples_all
sed -i 's#gs://nextflow-batch-input/platform/WGS/##g' samples_all

rm cram crai md5 patient tmp