#!/usr/bin/perl

@crit = (0,0,0,0,0,0,0,0,0,0,0,0);
@high = (0,0,0,0,0,0,0,0,0,0,0,0);
@med = (0,0,0,0,0,0,0,0,0,0,0,0);
@low = (0,0,0,0,0,0,0,0,0,0,0,0);
@crit_mos = (0,0,0,0,0,0,0,0,0,0,0,0);
@high_mos = (0,0,0,0,0,0,0,0,0,0,0,0);
@med_mos = (0,0,0,0,0,0,0,0,0,0,0,0);
@low_mos = (0,0,0,0,0,0,0,0,0,0,0,0);
@crit_a = (0,0,0,0,0,0,0,0,0,0,0,0);
@high_a = (0,0,0,0,0,0,0,0,0,0,0,0);
@med_a = (0,0,0,0,0,0,0,0,0,0,0,0);
@low_a = (0,0,0,0,0,0,0,0,0,0,0,0);

$infilename = $ARGV[0];
$outfilename = $ARGV[1];
# run through the file and fins out when the most recent scan data was grabbed:
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
	if (/(.),(\d+\.\d+\.\d+\.\d+),(\d\d)\/\d\d\/(\d\d\d\d),(\d\d)\/\d\d\/(\d\d\d\d),(.*)/) {
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
		$active_months = ((((int($last_yr) - 2000) * 12) + int($last_mo)) - (((int($first_yr) - 2000) * 12) + int($first_mo))) + 1;
		if($offset < 12){
			if($crit eq "Critical"){
				while($offset < $max_off){
					$crit[11 - $offset]++;
					$crit_mos[11 - $offset] += $active_months;
					$offset++;
					$active_months--;
					if($active_months < 0){
						$offset = 999;
					}
				}
			}
			if($crit eq "High"){
				while($offset < $max_off){
					$high[11 - $offset]++;
					$high_mos[11 - $offset] += $active_months;
					$offset++;
					$active_months--;
					if($active_months < 0){
						$offset = 999;
					}
				}
			}
			if($crit eq "Medium"){
				while($offset < $max_off){
					$med[11 - $offset]++;
					$med_mos[11 - $offset] += $active_months;
					$offset++;
					$active_months--;
					if($active_months < 0){
						$offset = 999;
					}
				}
			}
			if($crit eq "Low"){
				while($offset < $max_off){
					$low[11 - $offset]++;
					$low_mos[11 - $offset] += $active_months;
					$offset++;
					$active_months--;
					if($active_months < 0){
						$offset = 999;
					}
				}
			}
		}
	}
}
close IN;
for($i = 0; $i < 12; $i++){
	$crit_a[$i] = 0;
	$high_a[$i] = 0;
	$med_a[$i] = 0;
	$low_a[$i] = 0;
	if($crit[$i] > 0){
		$crit_a[$i] = $crit_mos[$i] / $crit[$i];
	}
	if($high[$i] > 0){
		$high_a[$i] = $high_mos[$i] / $high[$i];
	}
	if($med[$i] > 0){
		$med_a[$i] = $med_mos[$i] / $med[$i];
	}
	if($low[$i] > 0){
		$low_a[$i] = $low_mos[$i] / $low[$i];
	}
}
open OUT, ">", $outfilename;
print OUT "Avg. Months/Vuln";
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
print OUT "\nCritical," . join( ',', @crit_a) . "\n";
print OUT "High," . join( ',', @high_a) . "\n";
print OUT "Med," . join( ',', @med_a) . "\n";
print OUT "Low," . join( ',', @low_a) . "\n";
print OUT "\nDatafile: $outfilename\n";
close OUT;
