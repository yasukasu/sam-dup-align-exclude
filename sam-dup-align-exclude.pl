#! /usr/bin/perl
use strict;
use Getopt::Long;

### initail parameters

### processing  value entered in the command-line
my %opts=();
GetOptions(\%opts, "input=s") or exit 1;

foreach my $field ("input"){
    if ( ! exists $opts{$field} ){die "The option '--$field' is required.\n"; }
}


### file IO

my $file_in = $opts{input};

if($file_in =~ /.sam$/) {
    open IN, $file_in or die "$file_in could  - not be opened!:$!", "\n";
}
else {die "$file_in is not sam file.", "\n";}

my $file_out_ex  = $file_in;
my $file_out_dup = $file_in;

$file_out_ex =~ s/.sam$/.a1.sam/;
$file_out_dup =~ s/.sam$/.am.sam/;

print "Input file:\t", $file_in, "\n";
print "Onput file (non-redundant align.):\t", $file_out_ex, "\n";
print "Onput file (duplicated align.)   :\t", $file_out_dup, "\n";

open OUT1, ">$file_out_ex" or die "$file_out_ex could not be opened!:$!", "\n";
open OUT2, ">$file_out_dup" or die "$file_out_dup could not be opened!:$!", "\n";


my $line_R1 = "";
my $line_R2 = "";

my $line_n = 0;
my $ax_ref = "";

my $id_R1 ="";
my $id_R2 ="";
my $flag_R1=0;
my $flag_R2=0;
my $AS_R2 =0;
my $AS_R1 =0;
my $XS_R1 =0;
my $XS_R2 =0;

my $out_all =0;
my $out_noXS=0;
my $out_1XS=0;
my $out_dup=0;

while(<IN>){
	chop;

	if(substr($_, 0, 1) eq "@"){
    print OUT1 "$_\n";
    print OUT2 "$_\n";
    next;
  }

  ###  R1 reads

  if($line_n % 2==0){

    #if($XS_R1==0 || $XS_R2==0){ # if previous R1&R2 does not con

      $line_R1 = $_;

      $ax_ref = extarct_AS_XS($_);
      ($id_R1, $flag_R1, $AS_R1, $XS_R1) = @{$ax_ref};
      #print "AS:", $AS_R1, "\tXS:", $XS_R1,"\n";

      $line_n++;

    #} else {



    #}

    next;

  }

  ### R2 reads

  if($line_n % 2==1){

    $line_R2 = $_;

    $ax_ref = extarct_AS_XS($_);
    ($id_R2, $flag_R2, $AS_R2, $XS_R2) = @{$ax_ref};
    #print "AS:", $AS_R2, "\tXS:", $XS_R2,"\n";

    if($id_R1 ne $id_R2){die "Error in input of pair end reads. R1:$id_R1, R2:$id_R2 (line:$line_n)";}
    $line_n++;

    if($flag_R1 & 2){

      $out_all++;

      if($XS_R1 eq "NA" || $XS_R1 eq "NA"){
        print OUT1 "$line_R1\n";
        print OUT1 "$line_R2\n";
        $out_noXS++;
        next;
      }
      elsif($AS_R1>$XS_R1 || $AS_R2>$XS_R2){
        print OUT1 "$line_R1\n";
        print OUT1 "$line_R2\n";
        $out_1XS++;
        next;
      }
      else {
        #XS_mode="dup";
        print OUT2 "$line_R1\n";
        print OUT2 "$line_R2\n";
        $out_dup++;
      }
    }

  }

}

close(OUT1);
close(OUT2);

print "Number of inputted clusters   :\t", $line_n/2, "\n";
print "Number of All concordant align.:\t", $out_all,  " (", sprintf("%.2f",$out_all/$line_n*2*100), "%)\n";
print " > no multipe aligment (no XS tag in both reads).:\t", $out_noXS,  " (", sprintf("%.2f",$out_noXS/$line_n*2*100), "%)\n";
print " > multipe aligments in one read (1 XS tag).     :\t", $out_1XS,  " (", sprintf("%.2f",$out_1XS/$line_n*2*100), "%)\n";
print "   => file: $file_out_ex total: ", $out_noXS+$out_1XS, " (", sprintf("%.2f",($out_noXS+$out_1XS)/$line_n*2*100), "%) \n";
print " > duplicated align (AS=XS in both reads).       :\t", $out_dup, " (", sprintf("%.2f",$out_dup/$line_n*2*100), "%)\n";
print "   => file: $file_out_dup\n";

sub  extarct_AS_XS{

    (my $id_cls, my $flag,  my @others) = split /\s+/, $_[0];

    my $as_n ="NA";
    my $xs_n ="NA";

    my @as_ex = grep {/AS:i:.*[0-9]/} @others;
    my @xs_ex = grep {/XS:i:.*[0-9]/} @others;

    if(my $l=@as_ex){
      my @as_ss = split(/:/, @as_ex[0],3);
      $as_n = pop(@as_ss);
    }

    if(my $l=@xs_ex){
      my @xs_ss = split(/:/, @xs_ex[0],3);
      $xs_n = pop(@xs_ss);
    }

    my @ax = ($id_cls, $flag, $as_n, $xs_n);

    return (\@ax);
}
