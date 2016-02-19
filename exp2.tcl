set ns [new Simulator]

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

if {$argc != 4} {
	puts "Experiment 2 requires 3 parameters: the CBR rate, the TCP variants pair, the packet size, and the output file name."
	puts "For example, ns exp1.tcl 1mb reno_reno 1000 output.tr"
	puts "Please try again."
	exit 1
}

set rate [lindex $argv 0]
set variant_pair [lindex $argv 1]
set pkt_size [lindex $argv 2]
set filename [lindex $argv 3]

set tf [open $filename w]
$ns trace-all $tf

set udp [new Agent/UDP]
set null [new Agent/Null]
set cbr [new Application/Traffic/CBR]
set tcp0 [new Agent/TCP/Reno]
set ftp0 [new Application/FTP]
set tcpsink0 [new Agent/TCPSink]
set tcp1 [new Agent/TCP/Reno]
set ftp1 [new Application/FTP]
set tcpsink1 [new Agent/TCPSink]

if {$variant_pair == "reno_reno"} {
	set tcp0 [new Agent/TCP/Reno]
	set tcp1 [new Agent/TCP/Reno]
}
if {$variant_pair == "newreno_reno"} {
	set tcp0 [new Agent/TCP/Newreno]
	set tcp1 [new Agent/TCP/Reno]
}
if {$variant_pair == "vegas_vegas"} {
	set tcp0 [new Agent/TCP/Vegas]
	set tcp1 [new Agent/TCP/Vegas]
}
if {$variant_pair == "newreno_vegas"} {
	set tcp0 [new Agent/TCP/Newreno]
	set tcp1 [new Agent/TCP/Vegas]
}

proc finish {} {
	global ns tf
        $ns flush-trace
        close $tf
        exit 0

}

proc create_topology {} {
	global ns n1 n2 n3 n4 n5 n6

	$ns duplex-link $n1 $n2 10Mb 10ms DropTail
	$ns duplex-link $n2 $n3 10Mb 10ms DropTail
	$ns duplex-link $n3 $n4 10Mb 10ms DropTail
	$ns duplex-link $n2 $n5 10Mb 10ms DropTail
	$ns duplex-link $n3 $n6 10Mb 10ms DropTail
}

proc create_CBR_over_UDP {rate} {
	global ns n2 n3 udp null cbr pkt_size

	$ns attach-agent $n2 $udp

	$ns attach-agent $n3 $null
	$ns connect $udp $null

	$cbr attach-agent $udp
	$cbr set type_ CBR
	$cbr set packet_size_ $pkt_size
	$cbr set rate_ $rate
	$cbr set random_ false
}

proc create_FTP_over_TCP {} {
	global ns n1 tcp0 ftp0 n4 tcpsink0 n5 tcp1 ftp1 n6 tcpsink1

	$ns attach-agent $n1 $tcp0

	$ftp0 attach-agent $tcp0
	$ftp0 set typ_ FTP

	$ns attach-agent $n4 $tcpsink0
	$ns connect $tcp0 $tcpsink0

	$ns attach-agent $n5 $tcp1

	$ftp1 attach-agent $tcp1
	$ftp1 set typ_ FTP


	$ns attach-agent $n6 $tcpsink1
	$ns connect $tcp1 $tcpsink1
}

proc schedule {} {
	global ns ftp0 ftp1 cbr

	$ns at 0.0 "$ftp0 start"
	$ns at 0.0 "$ftp1 start"
	$ns at 10.0 "$cbr start"
	$ns at 28.5 "$cbr stop"
	$ns at 29.0 "$ftp0 stop"
	$ns at 29.5 "$ftp1 stop"
}

create_topology
create_CBR_over_UDP $rate
create_FTP_over_TCP
schedule

$ns at 30.0 finish

$ns run
