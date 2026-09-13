#!/bin/bash
# 06_variant_calling.sh — call variants in GVCF mode, then genotype them.
set -euo pipefail
source "$(dirname "$0")/../config.sh"
require_file "${RECAL_BAM}"

gatk HaplotypeCaller -R "${REF}" -I "${RECAL_BAM}" \
  -ERC GVCF -O "${GVCF}"
require_file "${GVCF}"

gatk GenotypeGVCFs -R "${REF}" -V "${GVCF}" -O "${RAW_VCF}"
require_file "${RAW_VCF}"

echo "Raw variant calls: ${RAW_VCF}"
bcftools view -H "${RAW_VCF}" | wc -l
