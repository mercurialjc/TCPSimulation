#!/bin/bash
echo "Bash script for automating experiment 1. By Jiawei Cui."

rate[0]="1mb"
rate[1]="3mb"
rate[2]="6mb"
rate[3]="10mb"

variants[0]="tahoe"
variants[1]="reno"
variants[2]="newreno"
variants[3]="vegas"

pkt_size[0]="1000"
pkt_size[1]="12000"

for i in 0 1 2 3
do	
	csv_file="1_"
	csv_file+=${rate[i]}
	throughput_filename=${csv_file}"_throughput.csv"
	latency_filename=${csv_file}"_latency.csv"
	droprate_filename=${csv_file}"_droprate.csv"	

	for j in 0 1 2 3
	do

		for k in 0 1
		do
			filename="1_"
			filename+=${rate[i]}
			filename+="_"
			filename+=${variants[j]}

			filename+="_"
			filename+=${pkt_size[k]}
			trace_filename=${filename}".tr"
			#`/course/cs4700f12/ns-allinone-2.35/bin/ns exp1.tcl ${rate[i]} ${variants[j]} ${pkt_size[k]} ${trace_filename}`
			#`./throughput ${trace_filename} ${throughput_filename} "3"`
			#`./endtoenddelay ${trace_filename} ${latency_filename} "0" "3"`
			`./droprate ${trace_filename} ${droprate_filename} "0"`

		done
	done
done
