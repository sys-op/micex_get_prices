# /bin/perl -w

use Encode;
use JSON;
use LWP::Simple;

my ($trader, $emitent, $emitent_file, $trader_url);
my ($trader_uid, $trader_code, $emitent_code, $emitent_uid);

$emitent_file = "emitents.json";

sub get_price_from_json {
	my $raw_str = @_[0];

	my $price	= "WAPRICE";
	my $time	= "SYSTIME";

	my $json_str	= encode ( 'utf8' , $raw_str );
	my $json_ok,$json_short_ok;

	eval {
		$json_ok     = decode_json($json_str);
	};
	if ($@) {
		return undef;
	} else {

#	my %price_info = ();

#	$price_info{price}	= $json_ok->[1]->{"$price"};
#	$price_info{time}	= $json_ok->[1]->{"$time"};

#	return %price_info;
	$json_short_ok = encode_json($json_ok->[1]);

		return (wantarray ? ($json_ok->[1]->{$price}, $json_ok->[1]->{$time},$json_short_ok) : undef);
	}
}

sub do_each_emitent {
	my $h = @_[0];

	my $code	= "code";
	my $name	= "name";
	my $curr	= "Currency";
	my $version	= "version";
	my $board	= "BoardID";

	my $url = "$trader_url?secid=$h->{$code}\&boardid=$h->{$board}";
	my $json_content = get $url;
	print "$url\n";

	my ($json_price, $json_time,$json_short_content);
	($json_price, $json_time,$json_short_content) = get_price_from_json($json_content);
	print "Price of $emitent is [$json_price] at [$json_time]\n";
	
}

sub get_emitents_from_json {
    my $raw_str = "";
    open(FH_JSON, "<", $emitent_file) or die "Cannot open $emitent_file: $!";
    while (<FH_JSON>) {
	$raw_str .= $_;
    }
    close(FH_JSON);

#    my $json_str= encode ( 'utf8' , $raw_str );
    my $json_str= $raw_str;
    my $json_ok	= decode_json($json_str);

    #NB! When MMVB and RTS was united, there is no reason to run cycle for traders
    #NB! But this code must be rewritten if other traders will appear.
    $trader_code = $json_ok->{root}->{trader}->{code};
    $trader = $json_ok->{root}->{trader}->{name};
    $trader_url = $json_ok->{root}->{trader}->{url};

    my $tmp = $json_ok->{root}->{trader}->{emitents};

    while (my ($k, $v) = each %$tmp) {
    
    	if (ref($v) eq "HASH") {
		$emitent = $v->{code};
		do_each_emitent($v);
	}
    }
}

get_emitents_from_json();
