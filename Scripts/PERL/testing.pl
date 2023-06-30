#!/usr/bin/perl
use strict;
use warnings;
use Cwd;

#Error handling, needs directory string
if ($#ARGV != 0 && $#ARGV != 1) {
    print "Invalid arguments count. Usage: perl FileCount.pl directory [-sub]\n";
    exit 3;
}

#Set global variables
my $dir = $ARGV[0];
my $count = 0;
my $files = "";
my $now = time();

#Change to desired directory
chdir $ARGV[0];

#Open the directory
opendir(my $dh, $dir) or die "$0: $dir: $!\n";

#Loop through each file in the directory
while (my $file = readdir($dh)) {
    #We only want files
    next unless (-f "$dir/$file");
    #Get the last modified time, convert to minutes
    my $modifiedTimeinDays = -M $file;
    my $modifiedTimeinMinutes = $modifiedTimeinDays*24*60;
    #We only want files older than 5 min
    next unless ($modifiedTimeinMinutes > 5);
    #Add the file to the file name string
    $files = $files."$file, ";
    #Increment the count
    $count = $count + 1;
}

#Close the directory
closedir($dh);

#Send back the relevant info
print "Script OK - Directory: $dir FileCount: $count Files: $files";
exit 0;