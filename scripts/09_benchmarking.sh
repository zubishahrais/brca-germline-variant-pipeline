#!/bin/bash
# 09_benchmarking.sh — score PASS calls against the GIAB HG001 v4.2.1 truth
# set, restricted to GIAB confident regions intersected with our gene panel.
set -euo pipefail
source "$(dirname "$0")/../config.sh"
require_file "${PASS_VCF}"
require_file "${SDF}"

if [ ! -f "${TRUTH_DIR}/giab_truth_chr13_chr17.vcf.gz" ]; then
  bcftools view -r chr17,chr13 "${GIAB_TRUTH_VCF_URL}" \
    -Oz -o "${TRUTH_DIR}/giab_truth_chr13_chr17.vcf.gz"
  tabix -p vcf "${TRUTH_DIR}/giab_truth_chr13_chr17.vcf.gz"
fi
require_file "${TRUTH_DIR}/giab_truth_chr13_chr17.vcf.gz"

[ -f "${TRUTH_DIR}/giab_confident_regions.bed" ] || \
  wget -O "${TRUTH_DIR}/giab_confident_regions.bed" "${GIAB_CONF_BED_URL}"
require_file "${TRUTH_DIR}/giab_confident_regions.bed"

OUT="${BENCH_DIR}/${SAMPLE}_vcfeval"
rm -rf "${OUT}"   # rtg refuses to write into an existing directory

rtg vcfeval \
  -b "${TRUTH_DIR}/giab_truth_chr13_chr17.vcf.gz" \
  -c "${PASS_VCF}" \
  -e "${TRUTH_DIR}/giab_confident_regions.bed" \
  --bed-regions "${TARGET_BED}" \
  -t "${SDF}" \
  -o "${OUT}"

echo "Benchmark results: ${OUT}"
