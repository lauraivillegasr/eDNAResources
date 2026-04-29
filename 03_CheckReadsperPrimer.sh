for bc in barcode01 barcode02 barcode03 barcode04 barcode05; do
  echo "== ${bc} =="
  for f in ${bc}/${bc}.8bp3p_nonN.*.fastq.gz; do
    n=$(zcat "$f" | awk 'NR%4==1' | wc -l)
    echo "$(basename "$f")  $n"
  done
  echo
done


== barcode01 ==
barcode01.8bp3p_nonN.bact16S.fastq.gz  3848
barcode01.8bp3p_nonN.calc28S.fastq.gz  21374
barcode01.8bp3p_nonN.fungi18S.fastq.gz  164899
barcode01.8bp3p_nonN.placo16S.fastq.gz  16914
barcode01.8bp3p_nonN.scle12S.fastq.gz  276720

== barcode02 ==
barcode02.8bp3p_nonN.bact16S.fastq.gz  15931
barcode02.8bp3p_nonN.calc28S.fastq.gz  64662
barcode02.8bp3p_nonN.fungi18S.fastq.gz  224248
barcode02.8bp3p_nonN.placo16S.fastq.gz  45206
barcode02.8bp3p_nonN.scle12S.fastq.gz  557503

== barcode03 ==
barcode03.8bp3p_nonN.bact16S.fastq.gz  8037
barcode03.8bp3p_nonN.calc28S.fastq.gz  26385
barcode03.8bp3p_nonN.fungi18S.fastq.gz  167636
barcode03.8bp3p_nonN.placo16S.fastq.gz  26281
barcode03.8bp3p_nonN.scle12S.fastq.gz  428153

== barcode04 ==
barcode04.8bp3p_nonN.bact16S.fastq.gz  5722
barcode04.8bp3p_nonN.calc28S.fastq.gz  32666
barcode04.8bp3p_nonN.fungi18S.fastq.gz  306310
barcode04.8bp3p_nonN.placo16S.fastq.gz  29334
barcode04.8bp3p_nonN.scle12S.fastq.gz  496328

== barcode05 ==
barcode05.8bp3p_nonN.bact16S.fastq.gz  8202
barcode05.8bp3p_nonN.calc28S.fastq.gz  32374
barcode05.8bp3p_nonN.fungi18S.fastq.gz  130672
barcode05.8bp3p_nonN.placo16S.fastq.gz  21483
barcode05.8bp3p_nonN.scle12S.fastq.gz  297468
