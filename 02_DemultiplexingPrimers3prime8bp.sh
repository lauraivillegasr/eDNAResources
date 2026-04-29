source ~/.bashrc
conda activate cutadapt

cd /home/lvilleg/Metabarcoding_maldives_210426/combined_barcodes

echo "=== cutadapt 8-bp 3'-core demux for all barcodes ==="

for bc in barcode01 barcode02 barcode03 barcode04 barcode05 unclassified; do
  fq=${bc}/${bc}.fastq.gz

  if [ ! -f "${fq}" ]; then
    echo "Skipping ${bc}, FASTQ not found: ${fq}"
    continue
  fi

  echo ">>> Processing ${fq}"

  cutadapt \
    -e 0.15 \
    -g scle12S=RANACTTA \
    -g calc28S=TAGCAATG \
    -g placo16S=CTTTACTA \
    -g fungi18S=TCGGTANT \
    -g bact16S=CGCGGTAA \
    --action=trim \
    --untrimmed-output ${bc}/${bc}.unassigned_8bp3p_nonN.fastq.gz \
    -o ${bc}/${bc}.8bp3p_nonN.{name}.fastq.gz \
    ${fq}
done

