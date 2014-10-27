#!/usr/bin/perl

use Bravo2;
use Data::Dumper;
use POSIX qw(strftime);
use IPC::Run qw( start );

my $bravo2 = Bravo2->new();

for (my $i=1; $i <= 1; $i++) {



	$bravo2->sendCommand('0x05');
	#sleep 15;
	#$bravo2->sendCommand('0x05');
	my $driveno = `drutil list|grep USB|cut -d" " -f1`;
	
	print "Drive: ".$driveno."\n";
	system("drutil", "-drive", $driveno, "tray", "eject");
	
	
	
	#$bravo2->sendCommand('0x80'); #get left put in drive (stays busy) 
	#$bravo2->sendCommand('0x81'); #get left, put in printer
	#$bravo2->sendCommand('0x82'); #get left, put right
	$bravo2->sendCommand('0x83'); #get right, put in drive
	system("drutil", "-drive", $driveno, "tray", "close");
	sleep 30;
	my $partno = `df -lH|grep "100%"|grep -v "MobileBackups"|cut -d" " -f1|head -1`;
	chomp($partno);
	my $devno = `df -lH|grep "100%"|grep -v "MobileBackups"|cut -d" " -f1|sed s"/s[0-9]//"`;
	chomp($devno);
	my $command = "diskutil info ".$devno."|grep \"Volume Name\"|cut -d\":\" -f2|sed s\"/\ *//\"";
	my $volname = `$command`;
	chomp($volname);
	#my $volname = system("diskutil", "info", $partno, "|", "grep", "\"Volume Name: \"", "|", "sed", "s\"/Volume\ Name\://\"", "|", "sed s\"/\ *//\"");
	my $now_string = strftime "%Y%m%d_%H%M%S", localtime;
	print $devno."\n";
	print $now_string."\n";
	
	#$h = start ['ddrescue', '-n','-b2048',$partno,'/Users/picturae/Desktop/'.$now_string.'.iso','/Users/picturae/Desktop/'.$now_string.'.log'], $out;
	$h = start ['diskutil', 'unmount', $partno], $out;
	$h->finish;
	#$h = start ['hdiutil', 'makehybrid', '-ov', '-o', '/Volumes/ZEB_9878_D_001/DVDRIP/'.$now_string.'_'.$volname.'.iso', $devno], $out;
	#$h->finish;

	$h = start ['dd', 'bs=20480', 'if='.$devno, 'of=/Volumes/ZEB_9878_D_001/DVDRIP/'.$now_string.'_'.$volname.'.iso'], $out;
	$h->finish;

	#finish $h
	#$h->kill_kill;
	
	system("drutil", "-drive", $driveno, "tray", "eject");
	#$bravo2->sendCommand('0x84'); #get right, put in printer
	#$bravo2->sendCommand('0x85'); #get right, put left
	#$bravo2->sendCommand('0x86'); #drive to printer
	#$bravo2->sendCommand('0x87'); #drive to right
	$bravo2->sendCommand('0x88'); #drive to left
	system("drutil", "-drive", $driveno, "tray", "close");
	#$bravo2->sendCommand('0x89'); #drive to drive (kick from printer)
	#$bravo2->sendCommand('0x8a'); #get printer, put right (stays busy)
	#$bravo2->sendCommand('0x8b'); #get printer, put left
	#$bravo2->sendCommand('0x8c'); #get printer, put drive
	#$bravo2->sendCommand('0x8d'); #go to left tray
	#$bravo2->sendCommand('0x8e'); #go to middle (stays busy)
	#$bravo2->sendCommand('0x8f'); #go to middle (stays busy)
	
	
	#while (1) {
	#  #print Dumper $bravo2->busy(); 
	#  if (! $bravo2->busy()) {
	#    last;
	#   } 
	#}
	
	#`drutil -drive 1 tray close`;
	
	print "Done\n";
}



