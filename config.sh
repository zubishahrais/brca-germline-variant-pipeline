#!/bin/bash
# config.sh — shared settings, sourced by every script in scripts/
set -euo pipefail

PROJECT="$HOME/BRCA_Germline_Variant_Project"

REF_DIR="${PROJECT}/data/reference"
RAW_DIR="${PROJECT}/data/raw"
REGIONS_DIR="${PROJECT}/data/regions"
KNOWN_SITES_DIR="${PROJECT}/data/known_sites"
TRUTH_DIR="${PROJECT}/data/truth"

QC_DIR="${PROJECT}/results/qc"
ALIGN_DIR="${PROJECT}/results/alignment"
METRICS_DIR="${PROJECT}/results/metrics"
BQSR_DIR="${PROJECT}/results/bqsr"
VAR_DIR="${PROJECT}/results/variants"
BENCH_DIR="${PROJECT}/results/benchmark"
ANNOT_DIR="${PROJECT}/results/annotation"
FIG_DIR="${PROJECT}/results/figures"
LOG_DIR="${PROJECT}/logs"

mkdir -p "${REF_DIR}" "${RAW_DIR}" "${REGIONS_DIR}" "${KNOWN_SITES_DIR}" "${TRUTH_DIR}" \
         "${QC_DIR}" "${ALIGN_DIR}" "${METRICS_DIR}" "${BQSR_DIR}" "${VAR_DIR}" \
         "${BENCH_DIR}" "${ANNOT_DIR}" "${FIG_DIR}" "${LOG_DIR}"

SAMPLE="NA12878"

REF="${REF_DIR}/chr13_chr17.fa"
SDF="${REF_DIR}/chr13_chr17.sdf"
CHR17_URL="https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/chr17.fa.gz"
CHR13_URL="https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/chr13.fa.gz"

NA12878_CRAM_URL="https://ftp.sra.ebi.ac.uk/vol1/run/ERR323/ERR3239334/NA12878.final.cram"

DBSNP_URL="https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.gz"
KNOWN_SITES="${KNOWN_SITES_DIR}/dbsnp138_chr13_chr17.vcf.gz"

GIAB_TRUTH_VCF_URL="https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/NA12878_HG001/NISTv4.2.1/GRCh38/HG001_GRCh38_1_22_v4.2.1_benchmark.vcf.gz"
GIAB_CONF_BED_URL="https://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/release/NA12878_HG001/NISTv4.2.1/GRCh38/HG001_GRCh38_1_22_v4.2.1_benchmark.bed"

TARGET_BED="${REGIONS_DIR}/BRCA_panel_GRCh38.bed"

RAW_R1="${RAW_DIR}/${SAMPLE}_R1.fastq.gz"
RAW_R2="${RAW_DIR}/${SAMPLE}_R2.fastq.gz"
SORTED_BAM="${ALIGN_DIR}/${SAMPLE}.sorted.bam"
DEDUP_BAM="${ALIGN_DIR}/${SAMPLE}.dedup.bam"
RECAL_BAM="${ALIGN_DIR}/${SAMPLE}.recal.bam"

GVCF="${VAR_DIR}/${SAMPLE}.g.vcf.gz"
RAW_VCF="${VAR_DIR}/${SAMPLE}.raw.vcf.gz"
FILTERED_VCF="${VAR_DIR}/${SAMPLE}.filtered.vcf.gz"
PASS_VCF="${VAR_DIR}/${SAMPLE}.pass.vcf.gz"
BRCA_PANEL_PASS_VCF="${VAR_DIR}/${SAMPLE}.BRCA_panel.pass.vcf.gz"

# Simple, load-bearing checks — fail loudly and early rather than silently
# continuing on a missing input (this is the "no error handling" fix).
require_file() {
  if [ ! -s "$1" ]; then
    echo "ERROR: required input file missing or empty: $1" >&2
    exit 1
  fi
}
