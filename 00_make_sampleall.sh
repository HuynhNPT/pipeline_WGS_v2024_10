#!/bin/bash
# Clean folder of sample_list, cram, crai, and md5
# This is essential to restart the script at a clean slate
rm sample_list* md5* cram* crai*
while read line; do
    export newDir=$(echo $line | awk '{print $2}')
    export oldDir=$(echo $line | awk '{print $1}')
    export projectDir="gs://nextflow-batch-input/platform/WGS/${newDir}/${oldDir}/"
    gsutil ls "${projectDir}"*cram | sed 's#.*/##' | sed 's/\.cram//' > sample_list1
    cat sample_list1 | sed 's/$/\.cram/' | sed "s#^#${newDir}/${oldDir}/#" > cram_$newDir
    cat sample_list1 | sed 's/$/\.cram\.crai/' | sed "s#^#${newDir}/${oldDir}/#" > crai_$newDir
    cat sample_list1 | sed 's/$/\.cram\.md5sum/'  | sed "s#^#${newDir}/${oldDir}/#" > md5_$newDir
    cp sample_list1 sample_list_$newDir
    rm sample_list1
done < ../../00_download_sheets/y2025/transfer_data2.txt

cat sample_list_* > sample_list
cat cram_* > cram
cat crai_* > crai
cat md5_* > md5

wc -l cram_*; wc -l crai_*; wc -l md5_*; wc -l sample_list_*
paste -d ',' sample_list cram crai md5 > samples_all

sed -i '1i sample_name,cram,crai,checksum' samples_all
rm sample_list; rm cram; rm crai; rm md5
