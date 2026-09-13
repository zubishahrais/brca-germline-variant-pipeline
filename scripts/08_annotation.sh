#!/bin/bash
# 08_annotation.sh — annotate PASS variants with SnpEff.
# Run this after: conda deactivate && conda activate snpeff-env
#
# SnpEff's GRCh38.mane database uses bare chromosome names ("17", not "chr17"),
# so we rename before annotating and restore names in the final output.
set -euo pipefail
source "$(dirname "$0")/../config.sh"
require_file "${BRCA_PANEL_PASS_VCF}"

SNPEFF_DB="GRCh38.mane.1.5.ensembl"
RENAMED_VCF="${VAR_DIR}/${SAMPLE}.BRCA_panel.pass.snpeff.vcf.gz"
ANNOTATED_VCF="${ANNOT_DIR}/${SAMPLE}.annotated.vcf.gz"

bcftools annotate --rename-chrs <(printf "chr13\t13\nchr17\t17\n") \
  "${BRCA_PANEL_PASS_VCF}" -Oz -o "${RENAMED_VCF}"
tabix -p vcf "${RENAMED_VCF}"

snpEff -Xmx4g ann -noStats "${SNPEFF_DB}" "${RENAMED_VCF}" | bgzip > "${ANNOTATED_VCF}"
tabix -p vcf "${ANNOTATED_VCF}"
require_file "${ANNOTATED_VCF}"

# Flat TSV of every variant + its top annotation, for the missense summary
# and for the effect-category plot in 09_make_figures.py
echo -e "CHROM\tPOS\tREF\tALT\tQUAL\tFILTER\tGENE\tEFFECT\tIMPACT\tTRANSCRIPT\tHGVS_C\tHGVS_P\tGENOTYPE" \
  > "${ANNOT_DIR}/${SAMPLE}.annotations.tsv"

bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\t%FILTER\t%ANN[\t%GT]\n' "${ANNOTATED_VCF}" \
  | awk -F'\t' 'BEGIN{OFS="\t"} {
      split($7, ann, ",");
      split(ann[1], a, "|");
      print $1,$2,$3,$4,$5,$6,a[4],a[2],a[3],a[7],a[10],a[11],$8
    }' >> "${ANNOT_DIR}/${SAMPLE}.annotations.tsv"

echo "Annotated: ${ANNOTATED_VCF}"
echo "Summary table: ${ANNOT_DIR}/${SAMPLE}.annotations.tsv"
