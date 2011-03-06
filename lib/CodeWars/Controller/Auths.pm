package CodeWars::Controller::Auth;

use Digest::MD5 'md5_hex';

use base 'Mojolicious::Controller';

sub login {
	my $self = shift;
	my $db = CodeWars::DB->handler();
	
	# It's not an e-mail!
	unless( CodeWars::Utils->isMail( $self->param('mail') ) ) {
		CodeWars::Utils->riseError("It's not an e-mail!");
	}
	
	# Get accounts by e-mail.
	my @users = $db->select(
        'forum__users', '*',
        {
            user_email => $self->param('mail')
        }
    )->hashes;
    
    # If this e-mail does not exist
    # or more than one account has this e-mail.
    unless( scalar @users == 1 ) {
		CodeWars::Utils->riseError(
			"This pair(e-mail and password) doesn't exist!"
		);
	}
    
    my $user = $users[0];
    
    # hash != md5( salt + md5( regdate + md5( password ) ) )
    return false if $user->{'password'} ne md5_hex
		CodeWars::Utils->salt() . md5_hex
			$user->{'regdate'} . md5_hex $self->param('passwd');
	
	# Init session.
	$self->session(
		user_id  => $user->{'id'},
		username => $user->{'username'},
		role     => $user->{'role'}
	)->redirect_to('users_read');
}

1;
