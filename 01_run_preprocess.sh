#!/bin/bash

if [ -s samples_all ];
then
    echo "Found required file: samples_all"
else
    echo "Missing required file: samples_all"
    exit 1
fi

lines=$(find . -name "*.yaml" ! -name 01_example.yaml | wc -l)

if [ $lines -eq 0 ];
then
    echo "Can not find required file: YYMMDD_Broad.yaml"
    exit 1
else
    YAML_FILE=$(find . -name "*.yaml" ! -name 01_example.yaml)
    echo Found ${YAML_FILE} to CONVERT to FASTQ
    echo "Proceed? (case sensitive: y/n)"
    read token
    if [ $token == "y" ]
    then
        nextflow run 01_preprocess.nf \
            -with-report -with-dag \
            -profile cloud \
            -params-file ${YAML_FILE}
    else
        echo "Exiting the pipeline! Adieu!"
    fi
fi