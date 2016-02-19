set ns [new Simulator]

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

if {$argc != 3} {
	puts "Experiment 4 requires 3 parameters: the queuing algorithm(droptail, red), the TCP variant(reno, sack) and the output file name."
	puts "For example, ns exp1.tcl red reno output.tr"
	puts "Please try again."
	exit 1
}

set queueAlgorithm [lindex $argv 0]
set variant [lindex $argv 1]
set filename [lindex $argv 2]

set tf [open $filename w]
$ns trace-all $tf

set udp0 [new Agent/UDP]
set null0 [new Agent/Null]
set tcp0 [new Agent/TCP]
if {$variant == "reno"} {
	set tcp0 [new Agent/TCP/Reno]
}
if {$variant == "sack"} {
	set tcp0 [new Agent/TCP/Sack1]
}
set tcpsink0 [new Agent/TCPSink]
set cbr0 [new Application/Traffic/CBR]
set ftp0 [new Application/FTP]

proc create_topology {} {
	global ns n1 n2 n3 n4 n5 n6 queueAlgorithm

	$ns duplex-link $n1 $n2 10Mb 10ms DropTail
	$ns duplex-link $n2 $n5 10Mb 10ms DropTail
	$ns duplex-link $n2 $n3 10Mb 10ms DropTail
	if {$queueAlgorithm == "droptail"} {
		$ns duplex-link $n2 $n3 10Mb 10ms DropTail
	}
	if {$queueAlgorithm == "red"} {
		$ns duplex-link $n2 $n3 10Mb 10ms RED
	}
	$ns duplex-link $n3 $n4 10Mb 10ms DropTail
	$ns duplex-link $n3 $n6 10Mb 10ms DropTail
}

proc create_CBR_over_UDP {} {
	global ns n5 n6 udp0 null0 cbr0

	$ns attach-agent $n5 $udp0
	$cbr0 attach-agent $udp0
	$cbr0 set type_ CBR
	$cbr0 set packet_size_ 1000
	$cbr0 set rate_ 1mb
	$cbr0 set random_ false
	$ns attach-agent $n6 $null0
	$ns connect $udp0 $null0
}

proc create_FTP_over_TCP {} {
	global ns n1 n4 tcp0 tcpsink0 ftp0

	$ns attach-agent $n1 $tcp0
	$ftp0 attach-agent $tcp0
	$ns attach-agent $n4 $tcpsink0
	$ns connect $tcp0 $tcpsink0
}

proc schedule {} {
	global ns cbr0 ftp0

	$ns at 0.0 "$ftp0 start"
	$ns at 10.0 "$cbr0 start"
	$ns at 29.0 "$ftp0 stop"
	$ns at 29.5 "$cbr0 stop"
	$ns at 30.0 "finish"
}

proc finish {} {
	global ns tf
	$ns flush-trace
	close $tf
	exit 0
}

create_topology
create_CBR_over_UDP
create_FTP_over_TCP
schedule

$ns run
