#!/usr/bin/perl

package Bravo2;

use strict;
use warnings;
 
use Device::USB;
use Data::Dumper;

our $VERSION = '0.03';
our $timeout = 1000;

sub new {
  my $class = shift;
  my $usb = Device::USB->new();
  my $dev = $usb->find_device( 0x0f25, 0x0008 );

  $dev->open() || die "$!";
  $dev->set_configuration(1);
  $dev->claim_interface(0);

  my $self = {};
  $self->{dev} = $dev;
  print "Connected: ", $dev->manufacturer(), " ", $dev->product(), "\n";
  bless($self, $class);
  return($self);
}


sub sendCommand {
  my $self = shift;
  my $command = shift;
  
  print "Command: ".$command."\n";

  my @cmd = (0x1b, 0x04, hex($command), 0x00, 0x00, 0x00, 0x00);
  my $sum = 0;
  my $cmdString = '';
  foreach (@cmd) {
        $sum += $_;
        $cmdString .= chr $_;
  }
  $cmdString .= chr ($sum % 255);
  print "Sending: ".unpack 'H*', $cmdString;
  print "\n";
  $self->{dev}->bulk_write(0x02, $cmdString, $timeout);
  sleep 1;
  while (1) { 
  if (! $self->busy()) {
    last;
   } 
  }


}


sub status {
  my $self = shift;
  my $buf = '';
  $self->{dev}->bulk_read(0x04, $buf, 0x5A, $timeout);

  my @array = unpack("(A)*", $buf);

  if (scalar(@array) eq 90) {
    #print "bravo: ".$array[70]."\n";          # I=idle, B=busy, C=cover open
    #print "printertray: ".$array[71]."\n";    # I=closed, O=open, D=disk insterted, X=no disk? 
    #print "picker: ".$array[72]."\n";         # X=no disk, O=grabbed disk
  }

  return $buf;
}

sub busy {
  my $self = shift;
  my $buf = '';
  $self->{dev}->bulk_read(0x04, $buf, 0x5A, $timeout);

  my @array = unpack("(A)*", $buf);

  if (scalar(@array) eq 90) {
    if ($array[70] eq "I") {
      return 0;
    } else {
      return 1; 
    }
    #print "bravo: ".$array[70]."\n";          # I=idle, B=busy, C=cover open
    #print "printertray: ".$array[71]."\n";    # I=closed, O=open, D=disk insterted, X=no disk? 
    #print "picker: ".$array[72]."\n";         # X=no disk, O=grabbed disk
    #print "\n";
  }
    return 1; 
  

}



# ubuntu@videobuntu:~$ sudo head -c89 /dev/usb/lp0 |hexdump -C
# 00000000  01 58 42 00 00 14 89 c7  2b 12 17 c4 d0 0f a8 84  |.XB.....+.......|
# 00000010  17 00 bf 28 5c 00 00 00  00 00 00 00 00 00 00 3b  |...(\..........;|
# 00000020  af 00 00 0b f4 00 00 0b  35 00 00 1b 21 ff ff 08  |........5...!...|
# 00000030  00 c2 87 05 31 2e 34 33  20 30 33 2f 31 39 2f 32  |....1.43 03/19/2|
# 00000040  30 30 38 43 00 02 49 49  58 00 04 07 0a 03 00 00  |008C..IIX.......|
# 00000050  32 00 fa 01 00 00 00 00  83                       |2........|
# 00000059
# 



##   Pipe Information (Handle 0x864b3dfc, Endpoint address 0x2)
## Maximum packet size: 0x40
## Endpoint address: 0x2
## Interval: 0x0
## Transfer Type: Bulk
## Maximum transfer size: 0x1000



  # 1b 04 05 00 00 00 00 24
  # 27 04 05             36




	

 ############# my $buf = '';
 ############# print $dev->bulk_read(0x04, $buf, 64, 1000)."\n";
 ############# print $buf."\n";

	#$dev->bulk_read( 2, $buf, 64, 1000 );
	#print Dumper $buf;
	#$dev->bulk_read( 132, $buf, 8, 1000 );
	#print Dumper $buf;
  
  
#}



#Bus 002 Device 003: ID 0f25:0008  
#Couldn't open device, some information will be missing
#Device Descriptor:
#  bLength                18
#  bDescriptorType         1
#  bcdUSB               1.00
#  bDeviceClass            0 (Defined at Interface level)
#  bDeviceSubClass         0 
#  bDeviceProtocol         0 
#  bMaxPacketSize0         8
#  idVendor           0x0f25 
#  idProduct          0x0008 
#  bcdDevice            1.00
#  iManufacturer           1 
#  iProduct                2 
#  iSerial                 3 
#  bNumConfigurations      1
#  Configuration Descriptor:
#    bLength                 9
#    bDescriptorType         2
#    wTotalLength           32
#    bNumInterfaces          1
#    bConfigurationValue     1
#    iConfiguration          0 
#    bmAttributes         0x40
#      (Missing must-be-set bit!)
#      Self Powered
#    MaxPower                4mA
#    Interface Descriptor:
#      bLength                 9
#      bDescriptorType         4
#      bInterfaceNumber        0
#      bAlternateSetting       0
#      bNumEndpoints           2
#      bInterfaceClass         7 Printer
#      bInterfaceSubClass      1 Printer
#      bInterfaceProtocol      2 Bidirectional
#      iInterface              0 
#      Endpoint Descriptor:
#        bLength                 7
#        bDescriptorType         5
#        bEndpointAddress     0x02  EP 2 OUT
#        bmAttributes            2
#          Transfer Type            Bulk
#          Synch Type               None
#          Usage Type               Data
#        wMaxPacketSize     0x0040  1x 64 bytes
#        bInterval               0
#      Endpoint Descriptor:
#        bLength                 7
#        bDescriptorType         5
#        bEndpointAddress     0x84  EP 4 IN
#        bmAttributes            2
#          Transfer Type            Bulk
#          Synch Type               None
#          Usage Type               Data
#        wMaxPacketSize     0x0008  1x 8 bytes
#        bInterval               0



# Interface Descriptor: 0, Alternate setting: 0
#  Number of endpoints: 2
#  Interface class: 0x7 - Printer
#  Interface subclass: 0x1 - Printer
#  Interface protocol: 0x2 - Bidirectional
#  Endpoint address 0x2, Output, Bulk, max packet size: 64 bytes
#  Endpoint address 0x4, Input, Bulk, max packet size: 8 bytes



