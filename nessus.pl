#!/usr/bin/perl
use Time::Piece;

$first = "";
$last = "";
$base = 0;
$temporal = 0;
$rating = "";

sub tokenizeit {
	my ($string) = @_;
	@chars = split("", $string);
	$field = 0;
	$inquote = 0;
	for($i = 0; $i < scalar(@chars); $i++){
		$c = @chars[$i];
		if($c eq "\""){
			$inquote = !$inquote;
		}
		if(($c eq ",") || ($c eq "\n")){
			if($inquote == 0){
				if($field == 1){
					$ipaddr = $out;
				}
				if($field == 0){
					$rating = $out;
				}
				if($field == 2){
					($timestr) = $out =~ /(.*) \d\d:\d\d:\d\d ...$/;
					$first_t = Time::Piece->strptime($timestr,"%b %d %Y %H:%M:%S");
					$first = $first_t->strftime("%m/%d/%Y");
				}
				if($field == 3){
					($timestr) = $out =~ /(.*) \d\d:\d\d:\d\d ...$/;
					$last_t = Time::Piece->strptime($timestr,"%b %d %Y %H:%M:%S");
					$last = $last_t->strftime("%m/%d/%Y");
					print "N,$ipaddr,$first,$last,$rating\n";
					$out = "";
					return;
				}
				$field++;
				$out = "";
			}
		} else {
			if($c ne "\""){ $out = $out . $c; }
		}
	}
}

$q = "\"";
$foo = 0;
while($line = <>){
	if($foo){
		tokenizeit($line);
	}
	$foo = 1;
}
