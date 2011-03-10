package CodeWars::User;

sub new {
    my ($self, $id) = @_;
    my $db = CodeWars::DB->handler();
    
    # Anonymous has 1st id.
    $id = 1 unless $id =~ /^[:digit:]$/;

	# Get accounts by id.
	my @users = $db->select(
        'forum__users', '*',
        {
            id => $id
        }
    )->hashes;

    unless( scalar @users == 1 ) {
		CodeWars::Utils->riseError(
            "User with this id does not exist."
        );
	}

    bless $users[0], $self;
}

sub isActive {
    my $self = shift;
    return 1 if $self->{'inactive_reason'} == 0;
    return 0;
}

sub isAdmin {
    my $self = shift;
    
    # In soviet Russia^W^W phpbb3 it's true.
    return 1 if $self->{'role'} == 3;
    return 0;
}

1;
