#!/usr/bin/perl

@crit = (0,0,0,0,0,0,0,0,0,0,0,0);
@high = (0,0,0,0,0,0,0,0,0,0,0,0);
@med = (0,0,0,0,0,0,0,0,0,0,0,0);
@low = (0,0,0,0,0,0,0,0,0,0,0,0);

$infilename = $ARGV[0];
$outfilename = $ARGV[1];
open IN, "<", $infilename;
$max = 0;
$cur_yr = 0;
$cur_mo = 0;
$cur_idx = 0;
while(<IN>){
	if (/.,\d+\.\d+\.\d+\.\d+,\d\d\/\d\d\/\d\d\d\d,(\d\d)\/\d\d\/(\d\d\d\d),.*/) {
		$last_mo = $1;
		$last_yr = $2;
		$index = (((int($last_yr) - 2000) * 12) + $last_mo);
		if($index > $max){
			$max = $index;
			$cur_idx = $index;
			$cur_yr = int($last_yr);
			$cur_mo = int($last_mo);
		}
	}
}
close IN;
open IN, "<", $infilename;
while(<IN>){
	if (/(.),(.*),(\d\d)\/\d\d\/(\d\d\d\d),(\d\d)\/\d\d\/(\d\d\d\d),(.*)/) {
		$src = $1;
		$ip = $2;
		$first_mo = $3;
		$first_yr = $4;
		$last_mo = $5;
		$last_yr = $6;
		$crit = $7;
		$index = (((int($last_yr) - 2000) * 12) + $last_mo);
		$max_idx = (((int($first_yr) - 2000) * 12) + $first_mo);
		$offset = $cur_idx - $index;
		$max_off = $cur_idx - $max_idx + 1;
		if($max_off > 12){
			$max_off = 12;
		}
		if($offset < 12){
			if($crit eq "Critical"){
				while($offset < $max_off){
					$crit[11 - $offset]++;
					$offset++;
				}
			}
			if($crit eq "High"){
				while($offset < $max_off){
					$high[11 - $offset]++;
					$offset++;
				}
			}
			if($crit eq "Medium"){
				while($offset < $max_off){
					$med[11 - $offset]++;
					$offset++;
				}
			}
			if($crit eq "Low"){
				while($offset < $max_off){
					$low[11 - $offset]++;
					$offset++;
				}
			}
		}
	}
}
close IN;
open OUT, ">", $outfilename;
print OUT "Criticality";
for($i = 12; $i > 0; $i--){
	$mo = $cur_mo - $i + 1;
	$yr = $cur_yr;
	if($mo <= 0){
		$mo += 12;
		$yr--;
		print OUT ",$mo/$yr";
	} else {
		print OUT ",$mo/$yr";
	}
}
print OUT "\nCritical," . join( ',', @crit) . "\n";
print OUT "High," . join( ',', @high) . "\n";
print OUT "Medium," . join( ',', @med) . "\n";
print OUT "Low," . join( ',', @low) . "\n";
print OUT "\nDatafile: $outfilename\n";
close OUT;
