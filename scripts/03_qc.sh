#!/bin/bash
# 03_qc.sh — quality control on the raw extracted reads.
set -euo pipefail
source "$(dirname "$0")/../config.sh"
require_file "${RAW_R1}"
require_file "${RAW_R2}"

mkdir -p "${QC_DIR}/fastqc"
fastqc "${RAW_R1}" "${RAW_R2}" -o "${QC_DIR}/fastqc"
echo "FastQC reports: ${QC_DIR}/fastqc"
