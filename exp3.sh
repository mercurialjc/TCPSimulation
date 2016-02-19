#!/bin/bash
echo "Bash script for automating experiment 3. By Jiawei Cui."

queueAlgorithm[0]="droptail"
queueAlgorithm[1]="red"

variants[0]="reno"
variants[1]="sack"


for i in 0 1
do
	for j in 0 1
	do
		filename="3_"
		filename+=${queueAlgorithm[i]}
		filename+="_"
		filename+=${variants[j]}
		filename+=".tr"
		`/course/cs4700f12/ns-allinone-2.35/bin/ns exp3.tcl ${queueAlgorithm[i]} ${variants[j]} ${filename}`
	done
done