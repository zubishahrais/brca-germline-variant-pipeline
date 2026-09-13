#!/bin/bash
# 07_filtering.sh — GATK Best Practices hard filtering (single-sample project;
# VQSR is not appropriate without a large multi-sample cohort).
set -euo pipefail
source "$(dirname "$0")/../config.sh"
require_file "${RAW_VCF}"

gatk SelectVariants -R "${REF}" -V "${RAW_VCF}" --select-type SNP   -O "${VAR_DIR}/${SAMPLE}.snps.vcf.gz"
gatk SelectVariants -R "${REF}" -V "${RAW_VCF}" --select-type INDEL -O "${VAR_DIR}/${SAMPLE}.indels.vcf.gz"

gatk VariantFiltration -R "${REF}" -V "${VAR_DIR}/${SAMPLE}.snps.vcf.gz" \
  -filter "QD < 2.0"              --filter-name "QD2" \
  -filter "FS > 60.0"             --filter-name "FS60" \
  -filter "MQ < 40.0"             --filter-name "MQ40" \
  -filter "MQRankSum < -12.5"     --filter-name "MQRankSum-12.5" \
  -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
  -filter "SOR > 3.0"             --filter-name "SOR3" \
  -O "${VAR_DIR}/${SAMPLE}.snps.filtered.vcf.gz"

gatk VariantFiltration -R "${REF}" -V "${VAR_DIR}/${SAMPLE}.indels.vcf.gz" \
  -filter "QD < 2.0"               --filter-name "QD2" \
  -filter "FS > 200.0"             --filter-name "FS200" \
  -filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
  -filter "SOR > 10.0"             --filter-name "SOR10" \
  -O "${VAR_DIR}/${SAMPLE}.indels.filtered.vcf.gz"

gatk MergeVcfs \
  -I "${VAR_DIR}/${SAMPLE}.snps.filtered.vcf.gz" \
  -I "${VAR_DIR}/${SAMPLE}.indels.filtered.vcf.gz" \
  -O "${FILTERED_VCF}"

bcftools view -f PASS "${FILTERED_VCF}" -Oz -o "${PASS_VCF}"
tabix -p vcf "${PASS_VCF}"
require_file "${PASS_VCF}"

# Restrict to exactly the three target genes for annotation
# (PASS_VCF above is used as-is for GIAB benchmarking in 09, which applies
# its own --bed-regions restriction rather than needing this file).
bcftools view -R "${TARGET_BED}" "${PASS_VCF}" -Oz -o "${BRCA_PANEL_PASS_VCF}"
tabix -p vcf "${BRCA_PANEL_PASS_VCF}"
require_file "${BRCA_PANEL_PASS_VCF}"

echo "Total:"; bcftools view -H "${FILTERED_VCF}" | wc -l
echo "PASS:";  bcftools view -H "${PASS_VCF}" | wc -l
echo "PASS, BRCA panel only:"; bcftools view -H "${BRCA_PANEL_PASS_VCF}" | wc -l
