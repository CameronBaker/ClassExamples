#!usr/bin/perl

#Cameron Baker
#This script searches through a file for specific genes and prints
#out the information to an outfile
#usage: perl perl_guide.pl infile outfile genename

#A couple things to note about perl
#1. Everything ends in brackets or semi colons
#2. Comments don't need to follow rule 1

#The following lines are pretty much standard for perl scripts
#They are modules that affect how the perl code is compiled.
#
#strict allows us to remove some of the "flexibility" built into perl in terms of variables
#warnings allows us to see if there are some potential errors in our code before we try to run it
use strict;
use warnings;

#Text::CSV is a module that allows us to easily parse CSV files
#Because it is not included normally, we need to install it.
#to install, type the following into your command lines. Keep pressing yes until it goes through
#cpan Text::CSV
#The following lines import Text::CSV into the perl scripts
#use lib... is needed because perl does not know where to look for custom installed modules
use lib '../perl5/lib/perl5';
use Text::CSV;

#This if loop checks the arguments to make sure we have enough
#If there are too few or too many, it kills the program
#More will be explained regarding arguments later
if(@ARGV != 3){
	die "usage: perl perl_guide.pl infile outfile genename\n";
}

#Lets break down what the next line means
#my $file: this is how you create variables in perl "my $variablename". Like R, perl is loose in
#  the way it defines variables
#$ARGV[0]: When you are running the program from the command line, you have the option of passing in arguments
#  under the form "perl programname arg0 arg1 arg2 ..."
#  These arguments can be retrieved using a built in variable, $ARGV[n] where n is the argument
#  unlike R, 0 is going to be the first argument passed in
#or die "No CSV provided\n": This is almost a compact if loop. 
#  If there are no arguments, then kill the program and print the message in quotes
#  The \n at the end of the message is a newline, which means the next line will start after this statement
#  newlines are important for seeing when a line ends and can change within systems.
my $infile = $ARGV[0] or die "No CSV provided \n";

#This command allows us to make a new object based on Text::CSV
#To make it, Text::CSV needs to know what seperation character to look for
my $parser = Text::CSV->new({sep_char=>","});

#This line allows us to open up a file to read what is inside, lets look at the arguments open needs
#my $data: a new variable that you can access the file from
#a character denoting what you want to do with the file
#  <: read the file
#  >: write the file (will overwrite whatever is there)
#  >>: append the file (will write to the end of the file)
#$file: the variable we defined above, the first argument from the program
open(my $data, '<', $infile) or die "could not open file\n";

#Lets open a file to write to as well
open(my $outfile, '>', $ARGV[1]) or die "could not open file\n";

#The way we get lines out of a file are using <$data>
#$data starts pointing at the first line of the file and each time you call it, it moves to the next one
#This is a little wonky because it means we can only read through a file once but whatever
#We have a problem
#while header information is usually vital when working within unknown data, we already know how the data is structured
#  Because of this, the header is in the way. To get rid of it, we make a dummy variable to start reading <$data> at 
#  The second line
#There are several ways to do this. Another example is
#while(condition){
#	next if $.==1
#	Other while loop stuff
#}
my $dummyline = <$data>;

#This loop is going to run until there are no more lines in the file
#We can access each line through the variable $line
while(my $line = <$data>){
	
	#The chomp command removes blank characters (white space) from infront of and behind the line
	#the clearing of white space is an important step in making sure we are reading only what we want to read
	chomp $line;

	#look for genes AT
	#Here we are checking to see if the CSV parser can parse the line
	#it may fail due to bad characters within the line, like incomplete quotes
	if($parser->parse($line)){
		#To actually get the fields within the line
		#@ is used to declare an array, which is like a vector in R
		my @fields = $parser->fields();
		
		#Now we need to extract the name from the line
		#to do that, we take the first field from the CSV 
		#Lets look at split
		# /"/ is the character to split on
		# @fields[0] is the string to split
		# It returns an array of the string split on those parts
		# For example:
		# split /e/, "refridgerator" will return ["r","fridg","rator"]
		my @field_parts = split /"/, $fields[0];
		
		#Lets extract the gene name form the cut up field
		#Annoyingly enough, perl reserves space after the split
		#@field_parts looks like [genename,(empty)]
		my $genename = $field_parts[0];
		
		#This checks to see if the genename contains the 3rd argument we passed in
		#There are several ways to check strings. index checks the second argument to
		#  the first and returns a number of the position where they match.
		#  for example: index("string","ing") will return 3
		#  if there is no match, it will return -1
		if(index($genename,$ARGV[2]) != -1){
		
			#Rather then printing to the command line, we can print directly to a file
			#by typing print $filename "whatever you want in that file"
			#if we don't include the newline, everything will be printed on the same line
			#perl knows to use the variable if you have a variable in the print command
			print $outfile "$line\n";
		}
	}
}

#the way perl handles files, it opens them up and leaves them open as long as the program is running
#closing them when you are finished with them is good practice either earlier in the program or at the end
#They SHOULD close after the program has finished running, but you don't want to leave things up to chance
close $data;
close $outfile;
