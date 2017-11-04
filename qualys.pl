#!/usr/bin/perl
use Time::Piece;

#local $/ = "\r\n";

sub tokenizeit {
	my ($string) = @_;
	if(length($string) < 10) { return; }
	@chars = split("", $string);
	$field = 0;
	$inquote = 0;
	$out = "";
	for($i = 0; $i < scalar(@chars); $i++){
		$c = @chars[$i];
		if($c eq "\""){
			$inquote = !$inquote;
		}
		if($c eq ","){
			if($inquote == 0){
				if($field == 0){
					$ipaddr = $out;
				}
				if($field == 11){
					$rating = $out;
				}
				if($field == 16){
					($first) = $out =~ /(.*) .*/;
					#$first_t = Time::Piece->strptime($first,"%m/%d/%Y");
				}
				if($field == 17){
					($last) = $out =~ /(.*) .*/;
					#$last_t = Time::Piece->strptime($last,"%m/%d/%Y");
				}
				if($field == 23){
					($cvss) = $out =~ /([0-9.]*) .*/;
					$level = "Low";
					if($cvss == 0){
						if($rating == 3){
							$level = "Medium";
							}
						if($rating == 4){
							#TM 02/08/16 Change to $level
							#$level = "Medium";
							$level = "High";
						}
						if($rating == 5){
							#TM 02/08/16 Change to $level
							#$level = "High";
							$level = "Critical";

						}
					} else {
						if($cvss >= 4){
							$level = "Medium";
						}
						if($cvss >= 7){
							$level = "High";
						}
						if($cvss == 10){
							$level = "Critical";
						}
					}
					$#days = ($last_t - $first_t)/86400;
					print "Q,$ipaddr,$first,$last,$level\n";
					return;
				}
				$field++;
				$out = "";
			}
		} else {
			if($c ne "\""){ $out = $out.$c; }
		}
	}
}

$wait = 0;
$q = "\"";
$c = 0;
$full_line = "";
while($line = <>){
	if($wait){
		$c += () = $line =~ /$q/g;
		$full_line = $full_line . $line;
		if($c % 2 == 0){
			tokenizeit($full_line);
			$full_line = "";
			$c = 0;
		}
	}
	if($line =~ /\"IP\",\"Network"\,\"DNS\",\"NetBIOS\",\"Tracking Method\".*/) { $wait = 1;}
}
