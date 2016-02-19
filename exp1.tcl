#Create a simulator object
set ns [new Simulator]

#Create six nodes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

if {$argc != 4} {
	puts "Experiment 1 requires 4 parameters: the CBR rate, the TCP variant(tahoe, reno, newreno, vegas), the packet size, and the output file name."
	puts "For example, ns exp1.tcl 1mb TCP 1000 out.tr"
	puts "Please try again."
}

set rate [lindex $argv 0]
set variant [lindex $argv 1]
set pkt_size [lindex $argv 2]
set filename [lindex $argv 3]

#Open the trace file
set tf [open $filename w]
$ns trace-all $tf

#Create agents and applications
set udp0 [new Agent/UDP]
set null0 [new Agent/Null]
set tcp0 [new Agent/TCP]
if {$variant == "tahoe"} {
	set tcp0 [new Agent/TCP]
}
if {$variant == "reno"} {
	set tcp0 [new Agent/TCP/Reno]
}
if {$variant == "newreno"} {
	set tcp0 [new Agent/TCP/Newreno]
}
if {$variant == "vegas"} {
	set tcp0 [new Agent/TCP/Vegas]
}
set tcpsink0 [new Agent/TCPSink]
set cbr0 [new Application/Traffic/CBR]
set ftp0 [new Application/FTP]


#Procedure that creates the topology, accepting different queuing disciplines
proc create_topology {} {
	global ns n1 n2 n3 n4 n5 n6

	#Create links between the nodes
	$ns duplex-link $n1 $n2 10Mb 10ms DropTail
	$ns duplex-link $n2 $n5 10Mb 10ms DropTail
	$ns duplex-link $n2 $n3 10Mb 10ms DropTail
	$ns duplex-link $n3 $n4 10Mb 10ms DropTail
	$ns duplex-link $n3 $n6 10Mb 10ms DropTail
}

#The procedure that creates
proc create_CBR_over_UDP {rate} {
	global ns n2 n3 udp0 null0 cbr0 pkt_size

	#Setup CBR over UDP connection
	$ns attach-agent $n2 $udp0
	$cbr0 attach-agent $udp0
	$cbr0 set type_ CBR
	$cbr0 set packet_size_ $pkt_size
	$cbr0 set rate_ $rate
	$cbr0 set random_ false
	$ns attach-agent $n3 $null0
	$ns connect $udp0 $null0
}

#Procedure that creates FTP over TCP, accepting different TCP variants
proc create_FTP_over_TCP {} {
	global ns n1 n4 tcp0 tcpsink0 ftp0

	#Setup FTP over TCP connection
	$ns attach-agent $n1 $tcp0
	$ftp0 attach-agent $tcp0
	$ns attach-agent $n4 $tcpsink0
	$ns connect $tcp0 $tcpsink0
}

#Prodecure that schedule the start time and end time
proc schedule {} {
	global ns cbr0 ftp0

	#Schedule events for CBR and FTP
	$ns at 0.1 "$ftp0 start"
	$ns at 30.0 "$cbr0 start"
	$ns at 55.0 "$cbr0 stop"
	$ns at 60.0 "$ftp0 stop"
	$ns at 65.0 "finish"
}

#Define a 'finish' procedure
proc finish {} {
	global ns tf
	# Close the trace file
	$ns flush-trace
	close $tf
	exit 0
}

create_topology
create_CBR_over_UDP $rate
create_FTP_over_TCP
schedule

$ns run
