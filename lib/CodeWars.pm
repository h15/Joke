package CodeWars;

use CodeWars::DB;
use CodeWars::User;
use CodeWars::Utils;

use Mojo::Base 'Mojolicious';

my $config = {
    cookies => 'some random string',
    salt    => 'some random string',
    db      => {
        host    => 'dbi:mysql:code_wars',
        user    => 'code_wars',
        passwd  => 'SCKM4FJS57BRL49x'
    },
};

# This method will run once at server start
sub startup {
    my $self = shift;
    
    # Mode, signed cookies' secret, session time
    $self->mode('development');
    $self->secret( $config->{'cookies'} );
    $self->sessions->default_expiration(3600*24*7);
    
    # Routes    
    my $route = $self->routes;
    
    #
    #   BIG INIT
    #
    my $r = $route->bridge('/')->to(cb => sub {
        # _shift_ for rendering errors.
        CodeWars::Utils->init( shift, $config->{'salt'} );
        
        # DataBase init
        CodeWars::DB->init( $config->{'db'} );
        
        # Global user object
        our $User = CodeWars::User->new( $self->session('user_id') );
    });
    
    $r->namespace('CodeWars::Controller');

    $r->route('/')->to('news#list', size => 10)->name('index');
    
    # News
    $r->route('/news/:id', id => qr/\d+/)->via('get')
        ->to('news#read')->name('news_read');
    $r->route('/news/new', id => qr/\d+/)->via('post')
        ->to('news#create')->name('news_create');
    
    # Sessions
    $r->route('/login')->via('post')->to('auths#login')->name('login');
    $r->route('/logout')->to('auths#logout')->name('logout');

    # User
    $r->route('/user/:id')->via('get')->to('users#read')
        ->name('users_read');
    $r->route('/user/:id')->via('put')->to('users#update');
    $r->route('/user/:id')->via('delete')->to('users#delete');
    $r->route('/user/new')->via('post')->to('users#create')
        ->name('users_create');

    # Forum
    $r->namespace('CodeWars::Controller::Forum');
    
    $r->route('/forum/topic/:id', id => qr/\d+/)->via('get')
        ->to('topics#read')->name('forum_topics_read');
    
    # Static
    $r->route('style')->to( cb => sub {
        shift->render(
            template => 'style',
            format => 'css',
        );
    })->name('style_main');
    
    # Include internalization plugin
    $self->plugin('i18n');
}

1;
