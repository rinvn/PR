#!/usr/bin/perl
use strict;
use warnings;

#save InstanceId into array
my $number_of_instance = `/usr/bin/aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name awseb-e-xekgxmtwmz-stack-AWSEBAutoScalingGroup-14CA68E9YM02J --region ap-northeast-1 | grep ""InstanceId"" | wc -l`;
my @instance;
open(my $fh, "<", "current_instances")
    or die "Failed to open file: $!\n";
while(<$fh>) {
    chomp;
    push @instance, $_;
}
close $fh;



#Function to reate Json file 

#print object into filename
sub printObject{
my $filename = $_[0];
my $object = $_[1];
my $fh;
if (open($fh, '>>', $filename)) {
    print $fh "$_[1]";
} else {
    warn "Could not create file '${filename}', Error: $!\n";
}
close($fh);
}
sub printNewline{
my $filename = $_[0];
my $fh;
if (open($fh, '>>', $filename)) {
    print $fh "\n";
} else {
    warn "Could not create file '${filename}', Error: $!\n";
}
close($fh);
}

#Print MemoryUtilization metric
sub printMemoryUtilization{
my $filename = $_[0];
my $memory_above_object = '{
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [';
my $memory_below_object = '],
                "view": "timeSeries",
                "stacked": false,
                "region": "ap-northeast-1",
                "period": 300
            }
        },';

my $memory_head_object = '[ "System/Linux", "MemoryUtilization", "InstanceId", ';
my $memory_tail_object = ' ],';

printObject($_[0],$memory_above_object);
printNewline($_[0]);

for (my $i=0; $i < $number_of_instance-1; $i++) {
    printObject($_[0],$memory_head_object);
    printObject($_[0],$instance[$i]);
    printObject($_[0],$memory_tail_object);
    printNewline($_[0]);
}

printObject($_[0],$memory_head_object);
printObject($_[0],$instance[-1]);
printObject($_[0]," ]");
printNewline($_[0]);

printObject($_[0],$memory_below_object);
printNewline($_[0]);
}

#Print DiskSpaceUtilization metric 
sub printDiskSpaceUtilization{
my $filename = $_[0];
my $disk_above_object = '{
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 12,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [';
my $disk_below_object = '],
                "region": "ap-northeast-1"
            }
        },';

my $disk_head_object = '[ "System/Linux", "DiskSpaceUtilization", "MountPath", "/", "InstanceId", ';
my $disk_tail_object = ', "Filesystem", "/dev/xvda1" ],';
my $disk_tail_object1 = ', "Filesystem", "/dev/xvda1" ]';
printObject($_[0],$disk_above_object);
printNewline($_[0]);

for (my $i=0; $i < $number_of_instance-1; $i++) {
    printObject($_[0],$disk_head_object);
    printObject($_[0],$instance[$i]);
    printObject($_[0],$disk_tail_object);
    printNewline($_[0]);
}

printObject($_[0],$disk_head_object);
printObject($_[0],$instance[-1]);
printObject($_[0],$disk_tail_object1);
printNewline($_[0]);

printObject($_[0],$disk_below_object);
printNewline($_[0]);
}

#Print 1MinLoadAverage metric 
sub printOneminla{
my $filename = $_[0];
my $oneminla_above_object = '{
            "height": 6,
            "width": 6,
            "y": 12,
            "x": 0,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [';
my $oneminla_below_object = '],
                "region": "ap-northeast-1"
            }
        },';

my $oneminla_head_object = '[ "System/Linux", "1MinLoadAverage", "InstanceId", ';
my $oneminla_tail_object = ' ],';

printObject($_[0],$oneminla_above_object);
printNewline($_[0]);

for (my $i=0; $i < $number_of_instance-1; $i++) {
    printObject($_[0],$oneminla_head_object);
    printObject($_[0],$instance[$i]);
    printObject($_[0],$oneminla_tail_object);
    printNewline($_[0]);
}

printObject($_[0],$oneminla_head_object);
printObject($_[0],$instance[-1]);
printObject($_[0]," ]");
printNewline($_[0]);

printObject($_[0],$oneminla_below_object);
printNewline($_[0]);
}

#Print 5MinLoadAverage metric
sub printFiveminla{
my $filename = $_[0];
my $fiveminla_above_object = '{
            "height": 6,
            "width": 6,
            "y": 12,
            "x": 6,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [';
my $fiveminla_below_object = '],
                "region": "ap-northeast-1"
            }
        },';

my $fiveminla_head_object = '[ "System/Linux", "5MinLoadAverage", "InstanceId", ';
my $fiveminla_tail_object = ' ],';

printObject($_[0],$fiveminla_above_object);
printNewline($_[0]);

for (my $i=0; $i < $number_of_instance-1; $i++) {
    printObject($_[0],$fiveminla_head_object);
    printObject($_[0],$instance[$i]);
    printObject($_[0],$fiveminla_tail_object);
    printNewline($_[0]);
}

printObject($_[0],$fiveminla_head_object);
printObject($_[0],$instance[-1]);
printObject($_[0]," ]");
printNewline($_[0]);

printObject($_[0],$fiveminla_below_object);
printNewline($_[0]);
}

#Print CPUUtilization metric
sub printCPUUtilization{
my $filename = $_[0];
my $CPUUtilization_above_object = '{
            "type": "metric",
            "x": 6,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [';
my $CPUUtilization_below_object = '],
                "region": "ap-northeast-1"
            }
        },';

my $CPUUtilization_head_object = '[ "AWS/EC2", "CPUUtilization", "InstanceId", ';
my $CPUUtilization_tail_object = ' ],';

printObject($_[0],$CPUUtilization_above_object);
printNewline($_[0]);

for (my $i=0; $i < $number_of_instance-1; $i++) {
    printObject($_[0],$CPUUtilization_head_object);
    printObject($_[0],$instance[$i]);
    printObject($_[0],$CPUUtilization_tail_object);
    printNewline($_[0]);
}

printObject($_[0],$CPUUtilization_head_object);
printObject($_[0],$instance[-1]);
printObject($_[0]," ]");
printNewline($_[0]);

printObject($_[0],$CPUUtilization_below_object);
printNewline($_[0]);
}

#Print DiskReadOps metric
sub printDiskReadOps{
my $filename = $_[0];
my $DiskReadOps_above_object = '{
            "height": 6,
            "width": 6,
            "y": 6,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [';
my $DiskReadOps_below_object = '],
                "view": "timeSeries",
                "stacked": false,
                "region": "ap-northeast-1"
            }
        },';

my $DiskReadOps_head_object = '[ "AWS/EC2", "DiskReadOps", "InstanceId", ';
my $DiskReadOps_tail_object = ' ],';

printObject($_[0],$DiskReadOps_above_object);
printNewline($_[0]);

for (my $i=0; $i < $number_of_instance-1; $i++) {
    printObject($_[0],$DiskReadOps_head_object);
    printObject($_[0],$instance[$i]);
    printObject($_[0],$DiskReadOps_tail_object);
    printNewline($_[0]);
}

printObject($_[0],$DiskReadOps_head_object);
printObject($_[0],$instance[-1]);
printObject($_[0]," ]");
printNewline($_[0]);

printObject($_[0],$DiskReadOps_below_object);
printNewline($_[0]);
}

#Print DiskWriteOps metric
sub printDiskWriteOps{
my $filename = $_[0];
my $DiskWriteOps_above_object = '{
            "height": 6,
            "width": 6,
            "y": 6,
            "x": 6,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [';
my $DiskWriteOps_below_object = '],
                "region": "ap-northeast-1"
            }
        },';

my $DiskWriteOps_head_object = '[ "AWS/EC2", "DiskWriteOps", "InstanceId", ';
my $DiskWriteOps_tail_object = ' ],';

printObject($_[0],$DiskWriteOps_above_object);
printNewline($_[0]);

for (my $i=0; $i < $number_of_instance-1; $i++) {
    printObject($_[0],$DiskWriteOps_head_object);
    printObject($_[0],$instance[$i]);
    printObject($_[0],$DiskWriteOps_tail_object);
    printNewline($_[0]);
}

printObject($_[0],$DiskWriteOps_head_object);
printObject($_[0],$instance[-1]);
printObject($_[0]," ]");
printNewline($_[0]);

printObject($_[0],$DiskWriteOps_below_object);
printNewline($_[0]);
}

#Print NetworkIn metric
sub printNetworkIn{
my $filename = $_[0];
my $NetworkIn_above_object = '{
            "height": 6,
            "width": 6,
            "y": 18,
            "x": 0,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [';
my $NetworkIn_below_object = '],
                "region": "ap-northeast-1"
            }
        },';

my $NetworkIn_head_object = '[ "AWS/EC2", "NetworkIn", "InstanceId", ';
my $NetworkIn_tail_object = ' ],';

printObject($_[0],$NetworkIn_above_object);
printNewline($_[0]);

for (my $i=0; $i < $number_of_instance-1; $i++) {
    printObject($_[0],$NetworkIn_head_object);
    printObject($_[0],$instance[$i]);
    printObject($_[0],$NetworkIn_tail_object);
    printNewline($_[0]);
}

printObject($_[0],$NetworkIn_head_object);
printObject($_[0],$instance[-1]);
printObject($_[0]," ]");
printNewline($_[0]);

printObject($_[0],$NetworkIn_below_object);
printNewline($_[0]);
}

#Print NetworkOut metric
sub printNetworkOut{
my $filename = $_[0];
my $NetworkOut_above_object = '{
            "height": 6,
            "width": 6,
            "y": 18,
            "x": 6,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [';
my $NetworkOut_below_object = '],
                "region": "ap-northeast-1"
            }
        }';

my $NetworkOut_head_object = '[ "AWS/EC2", "NetworkOut", "InstanceId", ';
my $NetworkOut_tail_object = ' ],';

printObject($_[0],$NetworkOut_above_object);
printNewline($_[0]);

for (my $i=0; $i < $number_of_instance-1; $i++) {
    printObject($_[0],$NetworkOut_head_object);
    printObject($_[0],$instance[$i]);
    printObject($_[0],$NetworkOut_tail_object);
    printNewline($_[0]);
}

printObject($_[0],$NetworkOut_head_object);
printObject($_[0],$instance[-1]);
printObject($_[0]," ]");
printNewline($_[0]);

printObject($_[0],$NetworkOut_below_object);
printNewline($_[0]);
}


my $filename = 'DashboardBody.json';
my $start_object = '{
    "widgets": [';

my $spliter1_object = '},';
my $spliter2_object = '}';
my $stop_object = '  ]
}';



#Create json file
printObject($filename,$start_object);
printNewline($filename);

printMemoryUtilization($filename);
printNewline($filename);

printDiskSpaceUtilization($filename);
printNewline($filename);

printOneminla($filename);
printNewline($filename);

printFiveminla($filename);
printNewline($filename);

printCPUUtilization($filename);
printNewline($filename);

printDiskReadOps($filename);
printNewline($filename);

printDiskWriteOps($filename);
printNewline($filename);

printNetworkIn($filename);
printNewline($filename);

printNetworkOut($filename);
printNewline($filename);

printObject($filename,$stop_object);
printNewline($filename);
