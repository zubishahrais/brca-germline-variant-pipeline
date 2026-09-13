#!/bin/bash
# 05_preprocessing.sh — mark duplicates, then BQSR using dbSNP138 known sites
# (fetched via a remote, region-restricted query, not a full genome-wide download).
set -euo pipefail
source "$(dirname "$0")/../config.sh"
require_file "${SORTED_BAM}"

gatk MarkDuplicates -I "${SORTED_BAM}" -O "${DEDUP_BAM}" \
  -M "${METRICS_DIR}/${SAMPLE}.dup_metrics.txt"
samtools index "${DEDUP_BAM}"

if [ ! -f "${KNOWN_SITES}" ]; then
  REGIONS=$(awk '{print $1}' "${TARGET_BED}" | sort -u | paste -sd',' -)
  bcftools view -r "${REGIONS}" "${DBSNP_URL}" -Oz -o "${KNOWN_SITES}"
  tabix -p vcf "${KNOWN_SITES}"
fi
require_file "${KNOWN_SITES}"

gatk BaseRecalibrator -I "${DEDUP_BAM}" -R "${REF}" \
  --known-sites "${KNOWN_SITES}" -O "${BQSR_DIR}/${SAMPLE}.recal_data.table"

gatk ApplyBQSR -I "${DEDUP_BAM}" -R "${REF}" \
  --bqsr-recal-file "${BQSR_DIR}/${SAMPLE}.recal_data.table" -O "${RECAL_BAM}"

samtools index "${RECAL_BAM}"
require_file "${RECAL_BAM}"
echo "Analysis-ready BAM: ${RECAL_BAM}"
