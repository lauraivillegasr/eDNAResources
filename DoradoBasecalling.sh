#!/bin/bash
#
#SBATCH --job-name=dorado_hac
#SBATCH --qos=high_prio_large
#SBATCH -o /home/lvilleg/out/dorado_hac_%j.out
#SBATCH -e /home/lvilleg/err/dorado_hac_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --nodes=1
#SBATCH --mem=64G
#SBATCH --time=24:00:00


module load gnu/12
module load samtools

source ~/.bashrc
conda activate base

# Paths
DORADO_BIN=/home/lvilleg/opt/dorado-1.4.0-linux-x64/bin/dorado
POD5_DIR=/home/lvilleg/nanopore_redsea/pod5
MODELDIR=/home/lvilleg/dorado_models
OUTDIR=/home/lvilleg/nanopore_redsea/basecalled_hac

mkdir -p "${MODELDIR}"
mkdir -p "${OUTDIR}"

# Model string (fixed as requested)
MODEL_NAME=dna_r10.4.1_e8.2_400bps_hac@v5.0.0

# Device: CPU only; change to "cuda:all" if you use GPUs
DEVICE=cpu

echo "=== Dorado version ==="
"${DORADO_BIN}" --version

echo "=== Downloading model if needed ==="
"${DORADO_BIN}" download \
  --model "${MODEL_NAME}" \
  --models-directory "${MODELDIR}"

echo "=== Starting basecalling with model: ${MODEL_NAME} ==="
"${DORADO_BIN}" basecaller \
  "${MODELDIR}/${MODEL_NAME}" \
  "${POD5_DIR}" \
  -x "${DEVICE}" \
  --recursive \
  --emit-fastq \
  --emit-moves \
  --output-dir "${OUTDIR}"

echo "=== Done ==="
