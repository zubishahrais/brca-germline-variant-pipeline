#!/bin/bash
# 02_extract_target_reads.sh — pull only BRCA1/BRCA2/TP53 reads from NA12878's
# remote, indexed CRAM, then reconstruct paired FASTQ.
set -euo pipefail
source "$(dirname "$0")/../config.sh"
require_file "${TARGET_BED}"
require_file "${REF}"

REGIONS=$(awk '{print $1":"$2"-"$3}' "${TARGET_BED}" | paste -sd' ' -)

samtools view -b -T "${REF}" "${NA12878_CRAM_URL}" ${REGIONS} -o "${ALIGN_DIR}/${SAMPLE}.target.bam"
require_file "${ALIGN_DIR}/${SAMPLE}.target.bam"

# Position-sort + index (needed to inspect/verify the extraction)
samtools sort "${ALIGN_DIR}/${SAMPLE}.target.bam" -o "${ALIGN_DIR}/${SAMPLE}.target.sorted.bam"
samtools index "${ALIGN_DIR}/${SAMPLE}.target.sorted.bam"

# Name-sort + convert to paired FASTQ
samtools sort -n "${ALIGN_DIR}/${SAMPLE}.target.sorted.bam" -o "${ALIGN_DIR}/${SAMPLE}.target.qsort.bam"
samtools fastq -1 "${RAW_R1}" -2 "${RAW_R2}" -0 /dev/null -s /dev/null -n \
  "${ALIGN_DIR}/${SAMPLE}.target.qsort.bam"

require_file "${RAW_R1}"
require_file "${RAW_R2}"
echo "Reads ready: ${RAW_R1} / ${RAW_R2}"
