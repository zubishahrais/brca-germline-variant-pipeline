#!/usr/bin/env python3
"""
09_make_figures.py — generate labeled, captioned result figures.
Generates a figure from the completed BRCA panel annotation results.
Reads results/variants/NA12878.BRCA_panel.clean.tsv and writes
results/figures/variant_effect_breakdown.png.
"""
import csv
import os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

PROJECT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
TSV = os.path.join(PROJECT, "results/variants/NA12878.BRCA_panel.clean.tsv")
OUT = os.path.join(PROJECT, "results/figures/variant_effect_breakdown.png")

counts = {}
with open(TSV) as f:
    reader = csv.DictReader(f, delimiter="\t")
    for row in reader:
        effect = row["EFFECT"]
        counts[effect] = counts.get(effect, 0) + 1

items = sorted(counts.items(), key=lambda x: x[1], reverse=True)
labels = [k for k, _ in items]
values = [v for _, v in items]

fig, ax = plt.subplots(figsize=(9, 5))
bars = ax.bar(labels, values, color="#3b6ea5")
ax.set_ylabel("Number of variants")
ax.set_xlabel("Predicted effect (SnpEff)")
total_variants = sum(values)
ax.set_title(f"Variant effect breakdown — BRCA1/BRCA2/TP53, NA12878 (n={total_variants} PASS variants)")
plt.xticks(rotation=40, ha="right")
for bar, v in zip(bars, values):
    ax.text(bar.get_x() + bar.get_width() / 2, v + 2, str(v), ha="center", fontsize=9)
plt.tight_layout()
plt.savefig(OUT, dpi=150)
print(f"Saved: {OUT}")
