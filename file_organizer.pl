#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;

# ask user for input
print "Please enter the path to your desired directory: ";
my $dir = <STDIN>;
chomp($dir);

while (!-d $dir){
    print "Directory does not exist! Please enter a valid directory: ";
    $dir = <STDIN>;
    chomp($dir);
}

# set up folders for each file type
my %folders = (
    'Images' => ['jpg', 'jpeg', 'png', 'gif', 'HEIC'],
    'TextFiles' => ['txt', 'md', 'doc', 'docx'],
    'PDFs' => ['pdf'],
    'Zips' => ['zip']
);

# create each folder only if it doesn't exist
foreach my $folder (keys %folders) {
    unless (-d "$dir/$folder"){
        mkdir "$dir/$folder" or warn "Could not create folder $folder";
        print "Folder $folder created\n";
    }
}

# create misc folder
unless (-d "$dir/Misc") {
    mkdir "$dir/Misc" or warn "Could not create folder Misc";
    print "Folder Misc created\n";
}

# open directory
opendir(my $handle, $dir) or die "Failed: Cannot open directory $dir";

# sort each file
while (my $file = readdir($handle)) {

    # skip file if directory or hidden file
    next if (-d "$dir/$file" || $file =~ /^\./);

    # get extension of file
    my ($ext) = $file =~ /(\w+)$/;

    # skip if there is no extension
    next unless $ext;

    # create flag to track if file has been moved
    my $file_moved = 0;

    foreach my $folder (keys %folders) {
        # if the extension matches the file types for the folder, move file
        if (grep { $_ eq $ext } @{ $folders{$folder} }) {
            move("$dir/$file", "$dir/$folder/$file") or warn "Could not move $file";
            $file_moved = 1;
            last;
        }
    }

    # move file to misc if not moved
    unless ($file_moved) {
        move("$dir/$file", "$dir/Misc/$file") or warn "Could not move $file to Misc";
    }
}

print "Your files have been organized! ⸜(｡˃ ᵕ ˂ )⸝♡\n";

closedir($handle);