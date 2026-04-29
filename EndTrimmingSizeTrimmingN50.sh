module load gnu/12

source ~/.bashrc
conda activate cutadapt   # cutadapt env

BASEDIR=/home/lvilleg/Metabarcoding_maldives_210426/combined_barcodes
cd "${BASEDIR}" || exit 1

echo "=== 3' quality trimming with cutadapt (Q10, min len 100) ==="

for bc in barcode01 barcode02 barcode03 barcode04 barcode05 unclassified; do
  echo ">>> ${bc}"
  for f in ${bc}/${bc}.8bp3p_nonN.*.fastq.gz; do
    [ -e "$f" ] || continue

    fname=$(basename "$f")
    trimmed=${bc}/${fname%.fastq.gz}.trim.fastq.gz

    echo "  Trimming ${fname} -> $(basename "${trimmed}")"

    cutadapt \
      -q 0,10 \
      -m 200 \
      -o "${trimmed}" \
      "$f"
  done
done

echo "=== Done trimming ==="
module load gnu/12

source ~/.bashrc
conda activate nanopore-tools   # env with NanoPlot

BASEDIR=/home/lvilleg/Metabarcoding_maldives_210426/combined_barcodes
OUTQC=${BASEDIR}/qc_trimmed
mkdir -p "${OUTQC}"

cd "${BASEDIR}" || exit 1

echo "=== NanoPlot on trimmed demuxed files ==="

for bc in barcode01 barcode02 barcode03 barcode04 barcode05 unclassified; do
  echo ">>> ${bc}"
  for f in ${bc}/${bc}.8bp3p_nonN.*.trim.fastq.gz; do
    [ -e "$f" ] || continue

    fname=$(basename "$f")   # e.g. barcode01.8bp3p_nonN.scle12S.trim.fastq.gz
    marker=${fname#${bc}.8bp3p_nonN.}     # scle12S.trim.fastq.gz
    marker=${marker%.trim.fastq.gz}       # scle12S

    NP_OUT=${OUTQC}/nanoplot_${bc}_${marker}
    mkdir -p "${NP_OUT}"

    echo "  NanoPlot on ${fname} -> ${NP_OUT}"

    NanoPlot \
      --fastq "${f}" \
      --N50 \
      --loglength \
      --threads 4 \
      --outdir "${NP_OUT}" \
      --title "${bc} ${marker} trimmed"
  done
done

echo "=== Done NanoPlot ==="



