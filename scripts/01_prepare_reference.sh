#!/bin/bash
# 01_prepare_reference.sh — download chr17+chr13 (not the whole genome),
# build .fai/.dict/BWA index, and the RTG SDF used later for benchmarking.
set -euo pipefail
source "$(dirname "$0")/../config.sh"

if [ ! -f "${REF}" ]; then
  wget -c -P "${REF_DIR}" "${CHR17_URL}"
  wget -c -P "${REF_DIR}" "${CHR13_URL}"
  gunzip -kf "${REF_DIR}/chr17.fa.gz"
  gunzip -kf "${REF_DIR}/chr13.fa.gz"
  cat "${REF_DIR}/chr17.fa" "${REF_DIR}/chr13.fa" > "${REF}"
fi
require_file "${REF}"

samtools faidx "${REF}"
[ -f "${REF_DIR}/chr13_chr17.dict" ] || gatk CreateSequenceDictionary -R "${REF}" -O "${REF_DIR}/chr13_chr17.dict"
[ -f "${REF}.bwt" ] || bwa index "${REF}"
[ -d "${SDF}" ] || rtg format -o "${SDF}" "${REF}"

echo "Reference ready: ${REF}"
