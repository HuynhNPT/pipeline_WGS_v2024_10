# pipeline_WGS_v2024_10
Pipeline first converts cram or bam files to FASTQs, then execute the whole nf-core/sarek pipeline on generated fastq files. 
Pipeline uses BWA-MEM for alignment to hg38 as default, then evoke varient calling with cnvkit, manta, deepvariant, haplotypecaller, and strelka

# Quick start: 
To run the pipeline:  <br>
- Consult `00_make_sampleall.sh` to see how we could create `00_example_samples_all` text file, where we can point the preprocess pipeline to. The text file name `samples_all` is hard-coded in `01_run_preprocess.sh`<br>
- Create `MMYY_PROJECT.yaml` based on `01_example.yaml` and modify accordingly. We will keep a log of this `MMYY_PROJECT.yaml` <br>
- Modify and run `01_run_preprocess.sh` based on this yaml file <br>
- After FASTQs are generated, make sampleSheet.csv that looks like `02_example_sampleSheet.csv`. We will keep this sampleSheet in the log as well. <br>
- Finally, modify `outdir` in `02_run_sarek.sh` and initiate the pipeline on GCloud. You will not need the `local` profile unless you're debugging.  <br>

```
./00_make_sampleall.sh
./01_run_preprocess.sh
./01_run_sarek.sh
```

# Pipeline file structure:
. <br>
├── 00_b_make_sampleall.sh <br>
├── 00_example_samples_all <br>
├── *00_make_sampleall.sh* <br>
├── 01_example.yaml <br>
├── 01_preprocess.nf <br>
├── *01_run_preprocess.sh* <br>
├── 02_example_sampleSheet.csv <br>
├── 02_make_samplesheet.sh <br>
├── *02_run_sarek.sh* <br>
├── README.md <br>
├── gcp.config <br>
└── nextflow.config <br>

## Static files:
This repository contains the following static components that you will not have to modify:  <br>
1. `README.md`: this file <br>
2. `gcp.config`: our own config files to run nf-core/sarek on our cloud structure <br>
3. `nextflow.config`: our config files to run step 1 `01_run_preprocess.nf` <br>
4. `00_example_samples_all`: exaple text file for how the csv should look for `00_preprocess.nf` <br>
5. `01_run_preprocess.sh`: script to evoke `nextflow run`. Script has been updated to search for standing yaml file within the working directory that is not the example yaml file. Script will then take user's input whether to proceed or not. <br>
6. `02_example_sampleSheet.csv`: example text file for how the csv should look for `nf-core/sarek` <br>

## Files need modifying:
1. `00_make_sampleall.sh` and `00_b_make_sampleall`: Consult this file as to how you would be able to make a `samples_all` (file name is hard-coded - DO NOT CHANGE) text file that could be fed into the `01_preprocess.nf` workflow. The way files are stored and how md5 files are named, this bit can be VERY inconsistent and VERY baby-sitty. <br>
2. `02_make_samplesheet.sh`: Similar to `00_make_sampleall.sh`. But this script is use to make `samplesheet.csv` that can be fed into the sarek pipeline. Filename is linked to `02_run_sarek.sh`. Therefore, if this filename is changed, you will need to edit the `--input` param in `02_run_sarek.sh` as well. <br>
3. `01_example.yaml`: Environmental variables are supplied in this example yaml file to run the first step of the pipeline (CRAM to FASTQ). The example here points to the human genome that needed to decode the CRAM file in `fastaDir`. The example also sets the project directory `projectDir` to the input bucket in `genome` google cloud project - where all input crams (or bams) live, and the output location `out_bucket` in `compute-workspace` - where all pipeline results will be stored.  <br>
4. `01_preprocess.nf`: Nextflow workflow to convert CRAM to FASTQs. The workflow depends on `samples_all` and have not been finalized in terms of standardization yet. <br>
5. `02_run_sarak.sh`: script to evoke nf-core/sarek pipeline. Make sure you have `sampleSheet.csv` for the `--input` and that you also modify the `--outdir`. <br>

# TODO:
ExpansionHunter <br>
Annotation <br>
Branch for BAM to FASTQ instead of CRAM to FASTQ


