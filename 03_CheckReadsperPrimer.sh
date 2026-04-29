for bc in barcode01 barcode02 barcode03 barcode04 barcode05; do
  echo "== ${bc} =="
  for f in ${bc}/${bc}.8bp3p_nonN.*.fastq.gz; do
    n=$(zcat "$f" | awk 'NR%4==1' | wc -l)
    echo "$(basename "$f")  $n"
  done
  echo
done
