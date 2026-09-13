#!/bin/bash
# 04_alignment.sh — align paired reads to the chr17+chr13 reference.
set -euo pipefail
source "$(dirname "$0")/../config.sh"
require_file "${REF}"
require_file "${RAW_R1}"
require_file "${RAW_R2}"

bwa mem -t 4 -R "@RG\tID:${SAMPLE}\tPL:ILLUMINA\tSM:${SAMPLE}" \
  "${REF}" "${RAW_R1}" "${RAW_R2}" \
  | samtools sort -o "${SORTED_BAM}" -

samtools index "${SORTED_BAM}"
require_file "${SORTED_BAM}"
echo "Aligned BAM: ${SORTED_BAM}"
