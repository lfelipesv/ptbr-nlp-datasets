#!/usr/bin/perl
# Program to calculate de WER and the PER (using Levenshstein Distance)
# In this version, the inputs are the reference set, the hypothesis set and the PATH!

# Author: Luiz Felipe Santos Vecchietti
# Signal Processing Lab - UFRJ

# Find Error Rate Program
# Mentor: Fernando Gil Vianna Resende Junior

use feature qw( unicode_strings );
use List::Util qw[min max];

$|=3;

if (@ARGV<3) {
   print "usage: finder.pl [reference] [hypothesis] [findER-home]\n";
   exit(0);
}

$reflist = $ARGV[0];
$hyplist = $ARGV[1];
$hbpttsdir = $ARGV[2]; # Nao esta sendo usado...

@refvalues;
@hypvalues;

open(FILETEXT1, '<',$reflist) || die "Não foi possível abrir o arquivo '$reflist' $!"; 
while (<FILETEXT1>) {
  $text = $_;
  chomp $text;
  push @refvalues, $text;

}
close(FILETEXT1);

open(FILETEXT2, '<',$hyplist) || die "Não foi possível abrir o arquivo '$hyplist' $!"; 
while (<FILETEXT2>) {
  $text = $_;
  chomp $text;
  push @hypvalues, $text;

}
close(FILETEXT2);

#foreach (@hypvalues){
#  print "$_\n";
#}

# Error when exists different words in the reference and hypothesis sets
$tamref = @refvalues;
$tamhyp = @hypvalues;
if($tamref != $tamhyp){
  die "Different number of words in the Reference set and in the Hypothesis set\n"
}

# Word Error Rate
$worderrors=0;
for (my $i=0; $i<$tamref; $i++)
{
  if ($refvalues[$i] ne $hypvalues[$i])
  {
    $worderrors++;
  }
}

$wer = $worderrors*100/$tamref;
print "Word Errors = $worderrors\n";
print "Total Number of Words = $tamref\n";
print "WER= $wer%\n\n";

# Phone Error Rate using Levenshstein Distance
$phonemeerrors = 0;
$totalphonemes = 0;
# Para cada linha:
for (my $z=0; $z<$tamref; $z++)
{

  # Pegar somente fonemas do arquivo de REFERENCIA
  $textref = $refvalues[$z];
  $textref =~ s/\[.*?\]//g;
  @plistref = split(/ +/,$textref);  
  # Delete the first element of the file (WORD PHO PHO PHO PHO)
  $cnt=0;
  @plistref = grep { ++$cnt > 1 } @plistref;
  # Done  
  $tamphoref = @plistref;
  #print "Number of Phonemes Ref: $tamphoref\n";
  #print "Text Ref: @plistref\n";

  # Pegar somente fonemas do arquivo de HYPOTHESIS
  $texthyp = $hypvalues[$z];
  $texthyp =~ s/\[.*?\]//g;
  @plisthyp = split(/ +/,$texthyp); 
  # Delete the first element of the file (WORD PHO PHO PHO PHO)
  $cnt=0;
  @plisthyp = grep { ++$cnt > 1 } @plisthyp;
  # Done  
  $tamphohyp = @plisthyp;
  #print "Number of Phonemes Hyp: $tamphohyp\n";
  #print "Text Hyp: @plisthyp\n";

  # Levenshstein Algorithm
  # Listas: @plistref, @plisthyp
  # Tamanhos: m = $tamphoref, n = $tamphohyp
  @dist = ([(0) x ($tamphoref+1)],[(0) x ($tamphohyp+1)]);
  # Inicializacao
  for (my $i=1; $i<($tamphoref+1); $i++)
  {
    $dist[$i][0]=$i;
  }
  for (my $j=1; $j<($tamphohyp+1); $j++)
  {
    $dist[0][$j]=$j;
  }
  #print $d[0][3], "\n";
  # Computando o Algoritmo
  for (my $i=1; $i<($tamphoref+1); $i++)
  {
    for (my $j=1; $j<($tamphohyp+1); $j++)
    {
      if ($plistref[$i-1] eq $plisthyp[$i-1])
      {
        $dist[$i][$j]=$dist[$i-1][$j-1];
      }
      else
      {
        $substitution=$dist[$i-1][$j-1]+1;
        $insertion=$dist[$i][$j-1]+1;
        $deletion=$dist[$i-1][$j]+1;
        $dist[$i][$j]=min($substitution,$insertion,$deletion);
      }
    }  
  }

#  if ($dist[$tamphoref][$tamphohyp] != 0)
#  {
#    print "Text Ref: @plistref\n";
#    print "Text Hyp: @plisthyp\n";
#  }

  $phonemeerrors = $phonemeerrors + $dist[$tamphoref][$tamphohyp];
  $totalphonemes = $totalphonemes + $tamphoref;

}

print "\nPhoneme Errors (I+S+D)= $phonemeerrors\n";
print "Total Number of Phonemes = $totalphonemes\n";
$per = $phonemeerrors*100/$totalphonemes;
print "PER= $per%\n";

sub shell($) {
   my($command) = @_;
   my($exit);

   $exit = system($command);

   if($exit/256 != 0){
      die "Error in $command\n"
   }
}
