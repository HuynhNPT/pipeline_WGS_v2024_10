#!/bin/bash
export projectDir="gs://nextflow-batch-input/platform/WGS/250425_Broad/download_broad_4_25_2025/"

gsutil ls "${projectDir}"*cram | sed 's#.*/##' | sed 's/\.cram//' > sample_list1
cat sample_list1 | sed 's/$/\.cram/' | sed 's#^#250425_Broad/download_broad_4_25_2025/#' > cram
cat sample_list1 | sed 's/$/\.cram\.crai/' | sed 's#^#250425_Broad/download_broad_4_25_2025/#' > crai
cat sample_list1 | sed 's/$/\.cram\.md5sum/'  | sed 's#^#250425_Broad/download_broad_4_25_2025/#' > md5

export projectDir="gs://nextflow-batch-input/platform/WGS/250430_Broad/download_broad_4_30_2025/"

gsutil ls "${projectDir}"*cram | sed 's#.*/##' | sed 's/\.cram//' > sample_list2
cat sample_list2 | sed 's/$/\.cram/' | sed 's#^#250430_Broad/download_broad_4_30_2025/#' >> cram
cat sample_list2 | sed 's/$/\.cram\.crai/' | sed 's#^#250430_Broad/download_broad_4_30_2025/#' >> crai
cat sample_list2 | sed 's/$/\.cram\.md5sum/'  | sed 's#^#250430_Broad/download_broad_4_30_2025/#' >> md5

cat sample_list1 sample_list2 > sample_list

wc -l cram; wc -l crai; wc -l md5; wc -l sample_list
paste -d ',' sample_list cram crai md5 > samples_all

sed -i '1i sample_name,cram,crai,checksum' samples_all
rm sample_list; rm cram; rm crai; rm md5
