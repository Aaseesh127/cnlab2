Mac/802_11 set cdma_code_bw_start_ 0
Mac/802_11 set cdma_code_bw_stop_ 63
Mac/802_11 set cdma_code_int_start_ 64
Mac/802_11 set cdma_code_int_stop_ 127
Mac/802_11 set cdma_code_cqich_start_ 128
Mac/802_11 set cdma_code_cqich_stop_ 195
Mac/802_11 set cdma_code_handover_start_ 196
Mac/802_11 set cdma_code_handover_stop_ 255

set f0 [open out02.tr w]
set f1 [open lost02.tr w]
set f2 [open delay02.tr w]

set ns [new Simulator]
set topo [new Topography]
set tf [open out.tr w]
set nf [open out.nam w]
$ns trace-all $tf
$ns namtrace-all-wireless $nf 1500 1500
$topo load_flatgrid 1500 1500
set god [create-god 25]







$ns color 0 red

$ns node-config -adhocRouting AODV \
         -llType LL \
         -macType Mac/802_11 \
         -ifqType Queue/DropTail/PriQueue \
         -ifqLen 1000 \
         -antType Antenna/OmniAntenna \
         -propType Propagation/TwoRayGround \
         -phyType Phy/WirelessPhy \
         -channelType Channel/WirelessChannel \
         -energyModel EnergyModel \
         -initialEnergy 100 \
         -rxPower 0.3 \
         -txPower 0.6 \
         -topoInstance $topo \
         -agentTrace ON \
         -routerTrace ON \
         -macTrace OFF 

for {set i 0} {$i<25} {incr i} {
set node_($i) [$ns node]
$node_($i) set X_ [expr rand()*1500]
$node_($i) set Y_ [expr rand()*1500]
$node_($i) set Z_ 0.00000000000;
}

for {set i 0} {$i<25} {incr i} {
set xx [expr rand()*1500]
set yy [expr rand()*1500]
$ns at 0.1 "$node_($i)setdest $xx $yy 5"
}

for {set i 0} {$i<25} {incr i} {
$ns initial_node_pos $node_($i) 55
}

for {set i 0} {$i<25} {incr i} {
$ns at 10.0 "$node_($i) reset"
}

set udp0 [new Agent/UDP]
$ns attach-agent $node_(4) $udp0

set sink [new Agent/LossMonitor]
$ns attach-agent $node_(20) $sink

set cbr0 [new Application/Traffic /CBR]
$cbr0 set packetSize_ 1000
$cbr0 set interval_ 0.01
$cbr0 set maxpkts_ 10000
$cbr0 attach-agent $udp0
$ns connect $udp0 $sink
$ns at 1.00 "$cbr0 start"

set holdtime 0
set holdseq 0
set holdrate1 0

proc record {} {
global sink f0 f1 f2 holdtime holdseq holdrate1
set ns [Simulator instance]
set time 0.9
set bw0 [$sink set bytes_]
set bw1 [$sink set nlost_]
set bw2 [$sink set lastPktTime_]
set bw3 [$sink set npkts_]
set now [$ns now]

puts $f0 "$now[expr (($bw0 + $holdrate1)*8)/(2* $time * 1000000)]"
puts $f1 "$now[expr $bw1 / $time ]"
if {$bw3 > $holdseq} {
  puts $f2 "$now[expr ($bw2-$holdtime)/($bw3-$holdseq)]"
} else {
  puts $f2 "$now[expr ($bw3 - $holdseq)]"
}

$sink set bytes_ 0
$sink set nlost_ 0
set holdtime $bw2
set holdseq $bw3
set holdrate1 $bw0
$ns at [expr $now + $time]"record"
}


$ns at 0.0 "record"
$ns at 1.0 "$node_(4) add-mark m blue square"
$ns at 1.0 "$node_(20) add-mark m magenta square"
$ns at 1.0 "$node_(4) label SENDER"
$ns at 1.0 "$node_(20) label RECEIVER"
$ns at 0.01 "$ns trace-annotate \"Network Deployment \""

proc stop {} {
global ns_tracefd f0 f1 f2
close $f0
close $f1
close $f2
exec nam out.nam
exec xgraph out02.tr -geometry -x TIME -y thr -t Throughput 800x400 &
exec xgraph lost02.tr -geometry -x TIME -y loss -t Packet_loss 800x400 &
exec xgraph delay02.tr -geometry -x TIME -y Delay -t End-to-End-Delay 800x400 &
$ns flush-trace
}

$ns at 10"stop"
$ns at 10.0002 "puts \"NS EXITING..\";$ns halt"
puts $tracefd "M 0.0 nn 25 x 1500 y 1500 rp"
puts $tracefd "M 0.0 prop Propagation/TwoRayGround ant Antenna/OmniAntenna"
puts "Starting Simulation"
$ns run
 





