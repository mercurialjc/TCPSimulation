#!/bin/bash
echo "Bash script for automating experiment 2. By Jiawei Cui."

rate[0]="1mb"
rate[1]="3mb"
rate[2]="6mb"
rate[3]="10mb"

variant_pairs[0]="reno_reno"
variant_pairs[1]="newreno_reno"
variant_pairs[2]="vegas_vegas"
variant_pairs[3]="newreno_vegas"

for i in 0 1 2 3
do
	for j in 0 1 2 3
	do
		filename="2_"
		filename+=${rate[i]}
		filename+="_"
		filename+=${variant_pairs[j]}
		filename+=".tr"
		`/course/cs4700f12/ns-allinone-2.35/bin/ns exp2.tcl ${rate[i]} ${variant_pairs[j]} ${filename}`
	done
done