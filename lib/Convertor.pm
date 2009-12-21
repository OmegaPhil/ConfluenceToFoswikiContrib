##########################################################################
#
# This software/utility is developed by TWIKI.NET (http://www.twiki.net)
# Copyright (C) 1999-2008  TWIKI.NET, sales@twiki.net
#
##########################################################################


package Convertor;

use strict;
use warnings;
use Exporter;
use TWiki;
use TWiki::Func;
use Utils::Common;

our @ISA = qw(Exporter);
our @EXPORTS = qw(createSession saveTopic saveAttachment webExists sanitizeAttachmentName
                    attachmentExists);

our $logger;



=head1 NAME

Convertor - convert to twiki web.

=head1 DESCRIPTION
Implemented createSession, saveTopic, saveAttachment

=cut


#######################################################################
#Function Name : createSession
#Purpose : create session logging in twiki 
#Input : user, passowrd ( for twiki ) 
#Output : hash of spaces with key as spacekey and value as spacename
#######################################################################

sub createSession {
    my ($user, $password) = @_;
    $TWiki::Plugins::SESSION = new TWiki($user);
    $TWiki::cfg{DefaultUserLogin} = $user;
    $TWiki::cfg{Password} = $password;
    my $session = $TWiki::Plugins::SESSION;
    return $session;
}

#######################################################################
#Function Name : saveTopic
#Purpose : save topic for twiki 
#Input : confluence object, token 
#Output : undef if success , error string if not.
#######################################################################

sub saveTopic {
    my( $session, $web, $topic, $parent, $text, $options ) = @_;
    my $return1 = webExists($web);

	if (!defined $return1 or $return1 != 1) {
	     $logger->info("Creating web \"$web\"");
         createWeb($web);
	}
	else {
		$logger->debug("Web \"$web\" already exists not creating");
	}

	my $return2 = topicExists($web, $topic);
    
	if (!defined $return2 or $return2 != 1) {
	    $logger->info("Creating topic \"$topic\"\n");	
        #$text = Utils::Common::quote($text);
        require TWiki::Meta;
        my $meta = new TWiki::Meta($session, $web, $topic, $text);
        if ($parent) {
            $meta->put('TOPICPARENT', { name => $parent });
        }
        my $result = TWiki::Func::saveTopic( $web, $topic, $meta, $text);
        return $result;
	}
	else {
		$logger->info("Topic \"$topic\" already exists not creating");
        return ;
	}
   
}

#######################################################################
#Function Name : saveAttachment
#Purpose : Saving attacment for specific topic
#Input :  webname, topic name, attachment name, attachment details
#Output : undef if success , error string if not.
#######################################################################

sub saveAttachment {
    my( $web, $topic, $name, $data ) = @_;
     
    $logger->info("Attaching $name to $topic in web $web");
    $logger->debug("file attached is $data->{'filepath'}/1");
    
    my $result = TWiki::Func::saveAttachment($web, $topic, $name, 
    {
        file => "$data->{filepath}/1",
        comment => $data->{'comment'},
        filedate => $data->{'creationdate'}
    });
    return $result;
}

sub createWeb {
    my ( $newWeb, $baseWeb, $opts ) = @_;
    $baseWeb = '_default';
    $logger->debug("Creating Web $newWeb with baseweb $baseWeb");
    $opts = {METATOPICPARENT => "WebHome"};
    my $return = TWiki::Func::createWeb($newWeb, $baseWeb, $opts);
    return $return;
}


sub webExists { 
	my ($web) = @_;
    my $ret = TWiki::Func::webExists($web);
    return $ret;
}


sub topicExists {
	my ($web , $topic) = @_;
	my $ret = TWiki::Func::topicExists($web, $topic);
	return $ret;
}


sub attachmentExists {
    my( $web, $topic, $attachment ) = @_;
    my $ret = TWiki::Func::attachmentExists($web, $topic, $attachment);
    return $ret;
}


1;