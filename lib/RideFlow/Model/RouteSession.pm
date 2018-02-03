package RideFlow::Model::RouteSession;

use Moose;

# attribute definitions for this class are here:
extends 'RideFlow::Model::Attributes::RouteSession';

override save => sub { return shift->_save() };

sub _save {
    my $self  = shift;

    if ( ! $self->id && ! $self->session_start ) {
        $self->session_start( DateTime->now() );
    }

    if ( ! $self->in_storage ) {
        die "Route Session overlaps with existing session for this Driver or Vehicle"
            if $self->_overlaps_existing_session;
    }

    return $self->SUPER::save;
}

sub _overlaps_existing_session {
    my ( $self ) = @_;

    my $dtf = $self->_schema->storage->datetime_parser;
    my $start = $dtf->format_datetime($self->session_start);
    my $end   = $self->session_end ? $dtf->format_datetime($self->session_end) : undef;

    my $overlap_cases = $end
        # new session has end time
        ? [
            # start times match
            { session_start => $start },
            # existing is open-ended and new session end is before existing start
            { session_start => { '<', $end   }, session_end   => undef         },
            # new session start is between existing session's start and end
            { session_start => { '<', $start }, session_end => { '!=', undef, '>', $start } },
            # existing session's start is between new session's start and end
            [ session_start => { '>', $start, '<', $end } ],
          ]
        # new session is open-ended
        : [
            # both open-ended
            { session_end => undef           },
            # new start is before existing end
            { session_end => { '>', $start } },
          ];

    my $overlaps = RideFlow::Model->m('RouteSession')->list([
        -and => [
            ( $self->id ? { id => { '!=', $self->id } } : () ),
            [
                { driver_id  => $self->vehicle->id },
                { vehicle_id => $self->vehicle->id },
            ],
            $overlap_cases,
        ]
    ]);

    return scalar @$overlaps ? 1 : 0;

}

1;