package RideFlow::Email;

use Moose;

use Email::Simple;
use Email::Sender::Simple;
use MooseX::ClassAttribute;
use Template;
use RideFlow::Config 'configure';

class_has tt => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $tt = Template->new({
            INCLUDE_PATH => 'templates/email',
            INTERPOLATE  => 0,
        }) or die "$Template::ERROR\n";

        return $tt;
    },
);

sub send_message {
    my( $self, %params ) = @_;

    if ( my $template = delete $params{template} ) {

        my $args = delete $params{args} || {};
        my $output;

        $self->tt->process($template,$args,\$output)
            or die $self->tt->error;

        my ($subject,$body) = split /\n-{4,}\n/, $output;

        $params{header}{Subject} = $subject;
        $params{body} = $body;
    }

    $params{header}{From} ||= configure->{email}{from};
    $params{header} = [ %{$params{header}} ];

    my $email = Email::Simple->create(%params);

    Email::Sender::Simple->send($email);

    return $email;
}

1;