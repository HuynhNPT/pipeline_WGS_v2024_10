#!/bin/bash

nextflow run 00_preprocess.nf \
            -with-report -with-dag \
            -profile cloud \
            -params-file MMYY_PROJECT.yaml