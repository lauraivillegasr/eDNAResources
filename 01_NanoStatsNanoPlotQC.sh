source ~/.bashrc
conda activate nanopore-tools

# Paths
BASEDIR=/home/lvilleg/Metabarcoding_maldives_210426/combined_barcodes
OUTDIR=/home/lvilleg/nanopore_maldives/qc_combined_barcodes
mkdir -p "${OUTDIR}"

echo "=== Starting NanoStat / NanoPlot per barcode ==="

# Loop over all .fastq.gz files in combined_barcodes
for fq in "${BASEDIR}"/*/*.fastq.gz; do
    # fq looks like: /.../combined_barcodes/barcode01/barcode01.fastq.gz
    sample_dir=$(basename "$(dirname "${fq}")")    # barcode01
    sample_name=$(basename "${fq}" .fastq.gz)      # barcode01 or unclassified

    echo ">>> Processing ${sample_dir}/${sample_name}"

    # NanoStat
    NS_OUT="${OUTDIR}/nanostat_${sample_name}"
    mkdir -p "${NS_OUT}"

    NanoStat \
      --fastq "${fq}" \
      --outdir "${NS_OUT}" \
      --name "${sample_name}" \
      --threads 4

    # NanoPlot
    NP_OUT="${OUTDIR}/nanoplot_${sample_name}"
    mkdir -p "${NP_OUT}"

    NanoPlot \
      --fastq "${fq}" \
      --N50 \
      --threads 4 \
      --loglength \
      --outdir "${NP_OUT}" \
      --title "Maldives ${sample_name} combined_barcodes"

done

echo "=== Done ==="
