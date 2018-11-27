set ns [new Simulator]
set topo [new Topography]
$topo load_flatgrid 1052 600
create-god 6

set tf [open GSM1.tr w]
$ns trace-all $tf
set nf [open GSM1.nam w]
$ns namtrace-all $nf

$ns namtrace-all-wireless $nf 1052 600
set chan [new Channel/WirelessChannel]

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

set n0 [$ns node]
$n0 set X_ 303
$n0 set Y_ 302
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20

set n1 [$ns node]
$n1 set X_ 527
$n1 set Y_ 301
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20

set n2 [$ns node]
$n2 set X_ 748
$n2 set Y_ 300
$n2 set Z_ 0.0
$ns initial_node_pos $n2 20

set n3 [$ns node]
$n3 set X_ 952
$n3 set Y_ 299
$n3 set Z_ 0.0
$ns initial_node_pos $n3 20

set n4 [$ns node]
$n4 set X_ 228
$n4 set Y_ 500
$n4 set Z_ 0.0
$ns initial_node_pos $n4 20

set n5 [$ns node]
$n5 set X_ 305
$n5 set Y_ 72
$n5 set Z_ 0.0
$ns initial_node_pos $n5 20

$ns at 2 "$n5 setdest 900 72 75"

set tcp0 [new Agent/TCP]	
$ns attach-agent $n4 $tcp0

set sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $sink1

$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 1500

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 1.0 "$ftp0 start"
$ns at 10.0 "$ftp0 stop"

proc finish {} {
global ns tf nf
$ns flush-trace
close $tf
close $nf
exec nam GSM1.nam &
exit 0
}

for {set i 0} {$i<6} {incr i} {
$ns at 10 "\$n$i reset"
}
$ns at 10 "$ns nam-end-wireless 10"
$ns at 10 "finish"
$ns run
