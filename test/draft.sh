# PepPre
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 2 -n 1:0.2:4 -o out/Zubarev-Human-2/PepPre@2 data/Zubarev-Human-2/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 2 -n 1:0.2:4 -o out/Zubarev-Human-4/PepPre@2 data/Zubarev-Human-4/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 2 -n 1:0.2:4 -o out/Zubarev-Human-6/PepPre@2 data/Zubarev-Human-6/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 2 -n 1:0.2:4 -o out/Zubarev-Human-8/PepPre@2 data/Zubarev-Human-8/

julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 4 -n 1:0.2:4 -o out/Zubarev-Human-2/PepPre@4 data/Zubarev-Human-2/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 4 -n 1:0.2:4 -o out/Zubarev-Human-4/PepPre@4 data/Zubarev-Human-4/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 4 -n 1:0.2:4 -o out/Zubarev-Human-6/PepPre@4 data/Zubarev-Human-6/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 4 -n 1:0.2:4 -o out/Zubarev-Human-8/PepPre@4 data/Zubarev-Human-8/

julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 6 -n 1:0.2:4 -o out/Zubarev-Human-2/PepPre@6 data/Zubarev-Human-2/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 6 -n 1:0.2:4 -o out/Zubarev-Human-4/PepPre@6 data/Zubarev-Human-4/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 6 -n 1:0.2:4 -o out/Zubarev-Human-6/PepPre@6 data/Zubarev-Human-6/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 6 -n 1:0.2:4 -o out/Zubarev-Human-8/PepPre@6 data/Zubarev-Human-8/

julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 8 -n 1:0.2:4 -o out/Zubarev-Human-2/PepPre@8 data/Zubarev-Human-2/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 8 -n 1:0.2:4 -o out/Zubarev-Human-4/PepPre@8 data/Zubarev-Human-4/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 8 -n 1:0.2:4 -o out/Zubarev-Human-6/PepPre@8 data/Zubarev-Human-6/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 8 -n 1:0.2:8 -o out/Zubarev-Human-8/PepPre@8 data/Zubarev-Human-8/

julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:4 -o out/Dong-DSS-1.6/PepPre   data/Dong-DSS-1.6/

## pFind & pLink
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PepPre@2/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PepPre@4/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PepPre@6/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PepPre@8/1.0/ 1:0.2:4

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-4/PepPre@2/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-4/PepPre@4/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-4/PepPre@6/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-4/PepPre@8/1.0/ 1:0.2:4

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-6/PepPre@2/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-6/PepPre@4/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-6/PepPre@6/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-6/PepPre@8/1.0/ 1:0.2:4

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/PepPre@2/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/PepPre@4/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/PepPre@6/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/PepPre@8/1.0/ 1:0.2:8

julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext out/Dong-DSS-1.6/PepPre/1.0/   1:0.2:4

## PepPre+
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:4 -o out/Zubarev-Human-2/PepPre+@2 data/Zubarev-Human-2/ -i
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -o out/Zubarev-Human-8/PepPre+@8 data/Zubarev-Human-8/ -i
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:4 -o out/Dong-DSS-1.6/PepPre+      data/Dong-DSS-1.6/ -i

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PepPre+@2/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/PepPre+@8/1.0/ 1:0.2:8
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/PepPre+/1.0/      1:0.2:4

## Exclusion
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 2 -n 1:0.2:4 -o out/Zubarev-Human-2/PepPre@t0.0 data/Zubarev-Human-2/ -t 0.0
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 2 -n 1:0.2:4 -o out/Zubarev-Human-2/PepPre@t0.1 data/Zubarev-Human-2/ -t 0.1
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 2 -n 1:0.2:4 -o out/Zubarev-Human-2/PepPre@t0.5 data/Zubarev-Human-2/ -t 0.5
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 2 -n 1:0.2:4 -o out/Zubarev-Human-2/PepPre@t1.0 data/Zubarev-Human-2/ -t 1.0
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 2 -n 1:0.2:4 -o out/Zubarev-Human-2/PepPre@t2.0 data/Zubarev-Human-2/ -t 2.0

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PepPre@t0.0/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PepPre@t0.1/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PepPre@t0.5/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PepPre@t1.0/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PepPre@t2.0/1.0/ 1:0.2:4

## Score by m
git checkout score-by-m
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 2 -n 1:0.2:4 -o out/Zubarev-Human-2/PepPre-m data/Zubarev-Human-2/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 8 -n 1:0.2:4 -o out/Zubarev-Human-8/PepPre-m data/Zubarev-Human-8/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 1.6 -n 1:0.2:4 -o out/Dong-DSS-1.6/PepPre-m data/Dong-DSS-1.6/

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PepPre-m/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/PepPre-m/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/PepPre-m/1.0/    1:0.2:4

## Score by x
git checkout score-by-x
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 2 -n 1:0.2:4 -o out/Zubarev-Human-2/PepPre-x data/Zubarev-Human-2/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 8 -n 1:0.2:4 -o out/Zubarev-Human-8/PepPre-x data/Zubarev-Human-8/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -w 1.6 -n 1:0.2:4 -o out/Dong-DSS-1.6/PepPre-x data/Dong-DSS-1.6/

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PepPre-x/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/PepPre-x/1.0/ 1:0.2:4
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/PepPre-x/1.0/    1:0.2:4

## Mono Error
git checkout export-mono-error
julia ~/Projects/PepPre.jl/src/PepPre.jl -f csv,mgf -w 2 -n 4.0:4.0 -o out/Zubarev-Human-2/PepPre-mono data/Zubarev-Human-2/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f csv,mgf -w 8 -n 4.0:4.0 -o out/Zubarev-Human-8/PepPre-mono data/Zubarev-Human-8/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f csv,mgf -w 1.6 -n 4.0:4.0 -o out/Dong-DSS-1.6/PepPre-mono data/Dong-DSS-1.6/

## DIA
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -o out/Bruderer-Human-DIA30k/PepPre data/Bruderer-Human-DIA30k/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -o out/Bruderer-Human-DIA60k/PepPre data/Bruderer-Human-DIA60k/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -o out/Bruderer-Human-DIA120k/PepPre data/Bruderer-Human-DIA120k/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -o out/Bruderer-Human-DIA240k/PepPre data/Bruderer-Human-DIA240k/

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Bruderer-Human-DIA30k/PepPre/1.0/ 1:0.2:8
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Bruderer-Human-DIA60k/PepPre/1.0/ 1:0.2:8
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Bruderer-Human-DIA120k/PepPre/1.0/ 1:0.2:8
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Bruderer-Human-DIA240k/PepPre/1.0/ 1:0.2:8

julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -e 5 -o out/Bruderer-Human-DIA30k/PepPre@5ppm data/Bruderer-Human-DIA30k/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -e 5 -o out/Bruderer-Human-DIA60k/PepPre@5ppm data/Bruderer-Human-DIA60k/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -e 5 -o out/Bruderer-Human-DIA120k/PepPre@5ppm data/Bruderer-Human-DIA120k/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -e 5 -o out/Bruderer-Human-DIA240k/PepPre@5ppm data/Bruderer-Human-DIA240k/

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Bruderer-Human-DIA30k/PepPre@5ppm/1.0/ 1:0.2:8
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Bruderer-Human-DIA60k/PepPre@5ppm/1.0/ 1:0.2:8
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Bruderer-Human-DIA120k/PepPre@5ppm/1.0/ 1:0.2:8
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Bruderer-Human-DIA240k/PepPre@5ppm/1.0/ 1:0.2:8

julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -e 20 -o out/Bruderer-Human-DIA30k/PepPre@20ppm data/Bruderer-Human-DIA30k/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -e 20 -o out/Bruderer-Human-DIA60k/PepPre@20ppm data/Bruderer-Human-DIA60k/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -e 20 -o out/Bruderer-Human-DIA120k/PepPre@20ppm data/Bruderer-Human-DIA120k/
julia ~/Projects/PepPre.jl/src/PepPre.jl -f mgf -n 1:0.2:8 -e 20 -o out/Bruderer-Human-DIA240k/PepPre@20ppm data/Bruderer-Human-DIA240k/

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Bruderer-Human-DIA30k/PepPre@20ppm/1.0/ 1:0.2:8
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Bruderer-Human-DIA60k/PepPre@20ppm/1.0/ 1:0.2:8
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Bruderer-Human-DIA120k/PepPre@20ppm/1.0/ 1:0.2:8
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Bruderer-Human-DIA240k/PepPre@20ppm/1.0/ 1:0.2:8

# pParse
julia ~/Code/PepPre/cfg/pParse.jl 2 data-pParse/Zubarev-Human-2/ out/Zubarev-Human-2/pParse@2 -1:0.1:1
julia ~/Code/PepPre/cfg/pParse.jl 2 data-pParse/Zubarev-Human-4/ out/Zubarev-Human-4/pParse@2 -1:0.1:1
julia ~/Code/PepPre/cfg/pParse.jl 2 data-pParse/Zubarev-Human-6/ out/Zubarev-Human-6/pParse@2 -1:0.1:1
julia ~/Code/PepPre/cfg/pParse.jl 2 data-pParse/Zubarev-Human-8/ out/Zubarev-Human-8/pParse@2 -1:0.1:1

julia ~/Code/PepPre/cfg/pParse.jl 4 data-pParse/Zubarev-Human-2/ out/Zubarev-Human-2/pParse@4 -1:0.1:1
julia ~/Code/PepPre/cfg/pParse.jl 4 data-pParse/Zubarev-Human-4/ out/Zubarev-Human-4/pParse@4 -1:0.1:1
julia ~/Code/PepPre/cfg/pParse.jl 4 data-pParse/Zubarev-Human-6/ out/Zubarev-Human-6/pParse@4 -1:0.1:1
julia ~/Code/PepPre/cfg/pParse.jl 4 data-pParse/Zubarev-Human-8/ out/Zubarev-Human-8/pParse@4 -1:0.1:1

julia ~/Code/PepPre/cfg/pParse.jl 6 data-pParse/Zubarev-Human-2/ out/Zubarev-Human-2/pParse@6 -1:0.1:1
julia ~/Code/PepPre/cfg/pParse.jl 6 data-pParse/Zubarev-Human-4/ out/Zubarev-Human-4/pParse@6 -1:0.1:1
julia ~/Code/PepPre/cfg/pParse.jl 6 data-pParse/Zubarev-Human-6/ out/Zubarev-Human-6/pParse@6 -1:0.1:1
julia ~/Code/PepPre/cfg/pParse.jl 6 data-pParse/Zubarev-Human-8/ out/Zubarev-Human-8/pParse@6 -1:0.1:1

julia ~/Code/PepPre/cfg/pParse.jl 8 data-pParse/Zubarev-Human-2/ out/Zubarev-Human-2/pParse@8 -1:0.1:1
julia ~/Code/PepPre/cfg/pParse.jl 8 data-pParse/Zubarev-Human-4/ out/Zubarev-Human-4/pParse@8 -1:0.1:1
julia ~/Code/PepPre/cfg/pParse.jl 8 data-pParse/Zubarev-Human-6/ out/Zubarev-Human-6/pParse@8 -1:0.1:1
julia ~/Code/PepPre/cfg/pParse.jl 8 data-pParse/Zubarev-Human-8/ out/Zubarev-Human-8/pParse@8 -1:0.1:1

julia ~/Code/PepPre/cfg/pParse.jl 1.6 data-pParse/Dong-DSS-1.6/   out/Dong-DSS-1.6/pParse   -1:0.1:1

## pFind & pLink
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/pParse@2/1.0/ -1:0.1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-4/pParse@2/1.0/ -1:0.1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-6/pParse@2/1.0/ -1:0.1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/pParse@2/1.0/ -1:0.1:1

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/pParse@4/1.0/ -1:0.1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-4/pParse@4/1.0/ -1:0.1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-6/pParse@4/1.0/ -1:0.1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/pParse@4/1.0/ -1:0.1:1

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/pParse@6/1.0/ -1:0.1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-4/pParse@6/1.0/ -1:0.1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-6/pParse@6/1.0/ -1:0.1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/pParse@6/1.0/ -1:0.1:1

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/pParse@8/1.0/ -1:0.1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-4/pParse@8/1.0/ -1:0.1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-6/pParse@8/1.0/ -1:0.1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/pParse@8/1.0/ -1:0.1:1

julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext out/Dong-DSS-1.6/pParse/1.0/   -1:0.1:1


# EnumInst
julia ~/Code/PepPre/conv/ms2_nda.jl data/Zubarev-Human-2/ out/Zubarev-Human-2/EnumInst/
julia ~/Code/PepPre/conv/ms2_nda.jl data/Zubarev-Human-8/ out/Zubarev-Human-8/EnumInst/
julia ~/Code/PepPre/conv/ms2_nda.jl data/Dong-DSS-1.6/    out/Dong-DSS-1.6/EnumInst/

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/EnumInst/1/ 1:4
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/EnumInst/1/ 1:4
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/EnumInst/1/    1:4


# EnumIW
julia ~/Code/PepPre/conv/ms2_enum.jl data/Zubarev-Human-2/ out/Zubarev-Human-2/EnumIW/1/ 0
julia ~/Code/PepPre/conv/ms2_enum.jl data/Zubarev-Human-8/ out/Zubarev-Human-8/EnumIW/1/ 0
julia ~/Code/PepPre/conv/ms2_enum.jl data/Dong-DSS-1.6/    out/Dong-DSS-1.6/EnumIW/1/ 0

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/EnumIW/1/ 1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/EnumIW/1/ 1:1
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/EnumIW/1/    1:1


# EnumEx
julia ~/Code/PepPre/conv/ms2_enum.jl data/Zubarev-Human-2/ out/Zubarev-Human-2/EnumEx/1/ 1
julia ~/Code/PepPre/conv/ms2_enum.jl data/Zubarev-Human-8/ out/Zubarev-Human-8/EnumEx/1/ 1
julia ~/Code/PepPre/conv/ms2_enum.jl data/Dong-DSS-1.6/    out/Dong-DSS-1.6/EnumEx/1/ 1

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/EnumEx/1/ 1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/EnumEx/1/ 1:1
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/EnumEx/1/    1:1


# Decon2LS
julia ~/Code/PepPre/conv/decon.jl data/Zubarev-Human-2/ data-Decon2LS/Zubarev-Human-2/ out/Zubarev-Human-2/Decon2LS/1/ 1
julia ~/Code/PepPre/conv/decon.jl data/Zubarev-Human-8/ data-Decon2LS/Zubarev-Human-8/ out/Zubarev-Human-8/Decon2LS/1/ 1
julia ~/Code/PepPre/conv/decon.jl data/Dong-DSS-1.6/    data-Decon2LS/Dong-DSS-1.6/    out/Dong-DSS-1.6/Decon2LS/1/ 1

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/Decon2LS/1/ 1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/Decon2LS/1/ 1:1
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/Decon2LS/1/    1:1


# RAPID
# change max_z to 6
julia ~/Code/PepPre/cfg/RAPID.jl data-RAPID/Zubarev-Human-2/ data-RAPID/Zubarev-Human-2/
julia ~/Code/PepPre/cfg/RAPID.jl data-RAPID/Zubarev-Human-8/ data-RAPID/Zubarev-Human-8/
julia ~/Code/PepPre/cfg/RAPID.jl data-RAPID/Dong-DSS-1.6/    data-RAPID/Dong-DSS-1.6/

java -jar software/RAPID/jRAPID_v1.15.jar data-RAPID/Zubarev-Human-2/RAPID.txt 
java -jar software/RAPID/jRAPID_v1.15.jar data-RAPID/Zubarev-Human-8/RAPID.txt 
java -jar software/RAPID/jRAPID_v1.15.jar data-RAPID/Dong-DSS-1.6/RAPID.txt 

julia ~/Code/PepPre/conv/decon.jl data/Zubarev-Human-2/ data-RAPID/Zubarev-Human-2/ out/Zubarev-Human-2/RAPID/1/ 1
julia ~/Code/PepPre/conv/decon.jl data/Zubarev-Human-8/ data-RAPID/Zubarev-Human-8/ out/Zubarev-Human-8/RAPID/1/ 1
julia ~/Code/PepPre/conv/decon.jl data/Dong-DSS-1.6/    data-RAPID/Dong-DSS-1.6/    out/Dong-DSS-1.6/RAPID/1/ 1

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/RAPID/1/ 1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/RAPID/1/ 1:1
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/RAPID/1/    1:1


# MaxQuant
julia ~/Code/PepPre/conv/apl.jl data-MQ/Zubarev-Human-2/ out/Zubarev-Human-2/MaxQuant/1/
julia ~/Code/PepPre/conv/apl.jl data-MQ/Zubarev-Human-8/ out/Zubarev-Human-8/MaxQuant/1/
julia ~/Code/PepPre/conv/apl.jl data-MQ/Dong-DSS-1.6/    out/Dong-DSS-1.6/MaxQuant/1/

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/MaxQuant/1/ 1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/MaxQuant/1/ 1:1
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/MaxQuant/1/    1:1


# Dinosaur
find data/Zubarev-Human-2 -name "*.mzML" -exec java -jar software/Dinosaur/Dinosaur-1.2.0.free.jar --verbose --concurrency=1 --profiling --outDir=out/Zubarev-Human-2/Dinosaur/1/ {} \;
find data/Zubarev-Human-8 -name "*.mzML" -exec java -jar software/Dinosaur/Dinosaur-1.2.0.free.jar --verbose --concurrency=1 --profiling --outDir=out/Zubarev-Human-8/Dinosaur/1/ {} \;
find data/Dong-DSS-1.6    -name "*.mzML" -exec java -jar software/Dinosaur/Dinosaur-1.2.0.free.jar --verbose --concurrency=1 --profiling --outDir=out/Dong-DSS-1.6/Dinosaur/1/ {} \;

julia ~/Code/PepPre/conv/feat.jl data/Zubarev-Human-2/ out/Zubarev-Human-2/Dinosaur/1/ 2
julia ~/Code/PepPre/conv/feat.jl data/Zubarev-Human-8/ out/Zubarev-Human-8/Dinosaur/1/ 8
julia ~/Code/PepPre/conv/feat.jl data/Dong-DSS-1.6/    out/Dong-DSS-1.6/Dinosaur/1/    1.6

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/Dinosaur/1/ 1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/Dinosaur/1/ 1:1
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/Dinosaur/1/    1:1


# RawConverter
julia ~/Code/PepPre/conv/rawconv.jl data/Zubarev-Human-2/ out/Zubarev-Human-2/RawConverter/1/
julia ~/Code/PepPre/conv/rawconv.jl data/Zubarev-Human-8/ out/Zubarev-Human-8/RawConverter/1/
julia ~/Code/PepPre/conv/rawconv.jl data/Dong-DSS-1.6/    out/Dong-DSS-1.6/RawConverter/1/

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/RawConverter/1/ 1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/RawConverter/1/ 1:1
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/RawConverter/1/    1:1


# PointIso
rsync -av --progress /Volumes/E-Disk/Data/PepPre/data-PointIso/ms/ pgpu1:~/PepPre/data

for filename in `find ../data -name "*.ms1" -exec basename {} .ms1 \;`
do
    python -u read_pointCloud.py ../data/ ../data/ $filename
    for i in 400 600 800 1000 1200 1400 1600 1800;
    do
        python -u isoDetecting_scan_MS1_pointNet.py ../data/ $filename 3D_models_IsoDetecting/ 0 $i ../data/
    done
    python -u makeCluster.py ../data/ $filename ../data/
    python -u IsoGrouping_reportFeature_ev2r4.py ../data/ ../data/ 3D_models_IsoGrouping/ $filename ../data/ 0
done

rsync -av --progress pgpu1:~/PepPre/data/*.features.tsv /Volumes/E-Disk/Data/PepPre/data-PointIso/ms

julia ~/Code/PepPre/conv/feat.jl data/Zubarev-Human-2/ out/Zubarev-Human-2/PointIso/1/ 2
julia ~/Code/PepPre/conv/feat.jl data/Zubarev-Human-8/ out/Zubarev-Human-8/PointIso/1/ 8
julia ~/Code/PepPre/conv/feat.jl data/Dong-DSS-1.6/ out/Dong-DSS-1.6/PointIso/1/ 1.6

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/PointIso/1/ 1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/PointIso/1/ 1:1
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/PointIso/1/    1:1


# Monocle
Monocle.CLI.exe -f ..\..\data-Monocle\Zubarev-Human-2\20131202_hela1_120min_2MZ.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Zubarev-Human-8\20131202_hela1_120min_8MZ.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV1_DSS_CV9_0DOT5_HC_R2.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV1_DSS_CV9_0DOT5_HC_R3.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV1_DSS_CV9_0DOT5_R1.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV2_DSS_CF4_6_0DOT5ul_R1.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV2_DSS_CF4_6_0DOT5ul_R2.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV2_DSS_CV10_0DOT3ul_R2.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV2_DSS_CV10_0DOT5ul_R1.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV4_DSS_CF1_3_75min_R1.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV7_DSS_CF4_6_0DOT5ul_R1.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV7_DSS_CF4_6_0DOT5ul_R2.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV7_DSS_CV5_0DOT5_R1.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV7_DSS_CV5_0DOT5_R2.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV8_DSS_CV6_60min_0dot2_R1.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV8_DSS_CV6_75min_0dot2_R2.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV8_DSS_CV6_75min_0dot2_R2_20200118124826.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV8_DSS_CV9_60min_0dot2_R1.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV8_DSS_CV9_75min_0dot2_R2.raw -t csv
Monocle.CLI.exe -f ..\..\data-Monocle\Dong-DSS-1.6\CV8_DSS_CV9_75min_0dot2_R2_20200118145136.raw -t csv

julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-2/Monocle/1/ 1:1
julia ~/Code/PepPre/cfg/pFind.jl fasta/human.fasta out/Zubarev-Human-8/Monocle/1/ 1:1
julia ~/Code/PepPre/cfg/pLink.jl DSS dong-syn_ext  out/Dong-DSS-1.6/Monocle/1/    1:1


# Comet
for i in 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0 3.2 3.4 3.6 3.8 4.0;
do
    mkdir ../../out/Zubarev-Human-2/PepPre@2/$i/Comet/
    ./comet -Pcomet.cfg -N../../out/Zubarev-Human-2/PepPre@2/$i/Comet/Comet ../../out/Zubarev-Human-2/PepPre@2/$i/20131202_hela1_120min_2MZ.mgf
    mkdir ../../out/Zubarev-Human-8/PepPre@8/$i/Comet/
    ./comet -Pcomet.cfg -N../../out/Zubarev-Human-8/PepPre@8/$i/Comet/Comet ../../out/Zubarev-Human-8/PepPre@8/$i/20131202_hela1_120min_8MZ.mgf
done

for i in 1 2 3 4;
do
    mkdir ../../out/Zubarev-Human-2/EnumInst/$i/Comet/
    ./comet -Pcomet.cfg -N../../out/Zubarev-Human-2/EnumInst/$i/Comet/Comet ../../out/Zubarev-Human-2/EnumInst/$i/20131202_hela1_120min_2MZ.mgf
    mkdir ../../out/Zubarev-Human-8/EnumInst/$i/Comet/
    ./comet -Pcomet.cfg -N../../out/Zubarev-Human-8/EnumInst/$i/Comet/Comet ../../out/Zubarev-Human-8/EnumInst/$i/20131202_hela1_120min_8MZ.mgf
done

mkdir ../../out/Zubarev-Human-2/EnumInst/1/CometIso/
./comet -Pcomet-iso.cfg -N../../out/Zubarev-Human-2/EnumInst/1/CometIso/Comet ../../out/Zubarev-Human-2/EnumInst/1/20131202_hela1_120min_2MZ.mgf
mkdir ../../out/Zubarev-Human-8/EnumInst/1/CometIso/
./comet -Pcomet-iso.cfg -N../../out/Zubarev-Human-8/EnumInst/1/CometIso/Comet ../../out/Zubarev-Human-8/EnumInst/1/20131202_hela1_120min_8MZ.mgf

# Eval
julia ~/Code/PepPre/eval_pLink.jl data/Dong-DSS-1.6/ fasta/dong-syn.fasta \
    out/Dong-DSS-1.6/pParse/ 1:-0.1:-1 \
    out/Dong-DSS-1.6/PepPre/ 1:0.2:4 \
    out/Dong-DSS-1.6/EnumInst/ 1:4 \
    out/Dong-DSS-1.6/MaxQuant/ 1:1 \
    out/Dong-DSS-1.6/Dinosaur/ 1:1 \
    out/Dong-DSS-1.6/RawConverter/ 1:1 \
    fig/sub/Dong-DSS-1.6_

julia ~/Code/PepPre/eval_pFind.jl data/Zubarev-Human-2/ \
    out/Zubarev-Human-2/pParse@2/ 1:-0.1:-0.8 \
    out/Zubarev-Human-2/PepPre@2/ 1:0.2:4 \
    out/Zubarev-Human-2/EnumInst/ 1:4 \
    out/Zubarev-Human-2/MaxQuant/ 1:1 \
    out/Zubarev-Human-2/Dinosaur/ 1:1 \
    out/Zubarev-Human-2/RawConverter/ 1:1 \
    fig/sub/Zubarev-Human-2_

julia ~/Code/PepPre/eval_pFind.jl data/Zubarev-Human-8/ \
    out/Zubarev-Human-8/pParse@8/ 1:-0.1:0.1 \
    out/Zubarev-Human-8/PepPre@8/ 1:0.2:4 \
    out/Zubarev-Human-8/EnumInst/ 1:4 \
    out/Zubarev-Human-8/MaxQuant/ 1:1 \
    out/Zubarev-Human-8/Dinosaur/ 1:1 \
    out/Zubarev-Human-8/RawConverter/ 1:1 \
    fig/sub/Zubarev-Human-8_


time julia ~/Projects/PepPre.jl/src/PepPre.jl -n 4 data/Zubarev-Human-2/ >> log
time julia ~/Projects/PepPre.jl/src/PepPre.jl -n 4 data/Zubarev-Human-2/ >> log
time julia ~/Projects/PepPre.jl/src/PepPre.jl -n 4 data/Zubarev-Human-2/ >> log
time julia ~/Projects/PepPre.jl/src/PepPre.jl -n 4 data/Zubarev-Human-4/ >> log
time julia ~/Projects/PepPre.jl/src/PepPre.jl -n 4 data/Zubarev-Human-4/ >> log
time julia ~/Projects/PepPre.jl/src/PepPre.jl -n 4 data/Zubarev-Human-4/ >> log
time julia ~/Projects/PepPre.jl/src/PepPre.jl -n 4 data/Zubarev-Human-6/ >> log
time julia ~/Projects/PepPre.jl/src/PepPre.jl -n 4 data/Zubarev-Human-6/ >> log
time julia ~/Projects/PepPre.jl/src/PepPre.jl -n 4 data/Zubarev-Human-6/ >> log
time julia ~/Projects/PepPre.jl/src/PepPre.jl -n 4 data/Zubarev-Human-8/ >> log
time julia ~/Projects/PepPre.jl/src/PepPre.jl -n 4 data/Zubarev-Human-8/ >> log
time julia ~/Projects/PepPre.jl/src/PepPre.jl -n 4 data/Zubarev-Human-8/ >> log
