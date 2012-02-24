#####################################
# Arabic Linux Quizer
# Database by Linuxac.org
# Perl by Ali Al-Yassen
# Our version 1.2
#####################################
use Wx 0.15 qw[:allclasses];
use strict;

package MyFrame;

use Wx qw[:everything];
use base qw(Wx::Frame);
use strict;
use GD::Graph::bars3d;
use feature ':5.10';
use DBI;
use utf8;
use Encode;
my ( @question, @tries, @rands );

sub new {
    my ( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
    $parent //= undef;
    $id     //= -1;
    $title  //= "";
    $pos    //= wxDefaultPosition;
    $size   //= wxDefaultSize;
    $name   //= "";
    $style = wxDEFAULT_FRAME_STYLE unless defined $style;
    $self =
      $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );

    $self->{bitmap_button_1} =
      Wx::BitmapButton->new( $self, -1,
        Wx::Bitmap->new( "assets/vbulletin4_logo.png", wxBITMAP_TYPE_ANY ) );
    $self->{question} =
      Wx::TextCtrl->new( $self, -1, "", wxDefaultPosition, wxDefaultSize,
        wxTE_READONLY );
    $self->{friend} =
      Wx::BitmapButton->new( $self, -1,
        Wx::Bitmap->new( "assets/friend.png", wxBITMAP_TYPE_ANY ) );
    $self->{change} =
      Wx::BitmapButton->new( $self, -1,
        Wx::Bitmap->new( "assets/change.png", wxBITMAP_TYPE_ANY ) );
    $self->{remove} =
      Wx::BitmapButton->new( $self, -1,
        Wx::Bitmap->new( "assets/remove.png", wxBITMAP_TYPE_ANY ) );
    $self->{votes} =
      Wx::BitmapButton->new( $self, -1,
        Wx::Bitmap->new( "assets/votes.png", wxBITMAP_TYPE_ANY ) );
    $self->{opt2}  = Wx::Button->new( $self, -1, "2" );
    $self->{opt1}  = Wx::Button->new( $self, -1, "1" );
    $self->{opt4}  = Wx::Button->new( $self, -1, "4" );
    $self->{opt3}  = Wx::Button->new( $self, -1, "3" );
    $self->{quit}  = Wx::Button->new( $self, -1, "خروج" );
    $self->{about} = Wx::Button->new( $self, -1, "عن البرنامج" );

    $self->__set_properties();
    $self->__do_layout();

    Wx::Event::EVT_BUTTON( $self, $self->{friend}->GetId, \&call_my_friend );
    Wx::Event::EVT_BUTTON( $self, $self->{remove}->GetId, \&remove_two_opt );
    Wx::Event::EVT_BUTTON( $self, $self->{votes}->GetId,  \&voters );
     Wx::Event::EVT_BUTTON( $self, $self->{change}->GetId,  \&get_next_question );
    Wx::Event::EVT_BUTTON( $self, $self->{opt2}->GetId,   \&onClick );
    Wx::Event::EVT_BUTTON( $self, $self->{opt1}->GetId,   \&onClick );
    Wx::Event::EVT_BUTTON( $self, $self->{opt4}->GetId,   \&onClick );
    Wx::Event::EVT_BUTTON( $self, $self->{opt3}->GetId,   \&onClick );
    Wx::Event::EVT_BUTTON( $self, $self->{quit}->GetId,   \&onQuit );
    Wx::Event::EVT_BUTTON( $self, $self->{about}->GetId,  \&onAbout );

    return $self;

}

sub __set_properties {
    my $self = shift;

    $self->SetTitle("aQuizer");
    $self->SetSize( Wx::Size->new( 750, 500 ) );
    $self->{bitmap_button_1}
      ->SetSize( $self->{bitmap_button_1}->GetBestSize() );
    $self->{friend}->SetToolTipString("الاتصال بصديق");
    $self->{friend}->SetSize( $self->{friend}->GetBestSize() );
    $self->{change}->SetToolTipString("تغيير السؤال");
    $self->{change}->SetSize( $self->{change}->GetBestSize() );
    $self->{remove}->SetToolTipString("حذف اجابتين");
    $self->{remove}->SetSize( $self->{remove}->GetBestSize() );
    $self->{votes}->SetToolTipString("الاستعانة بالجمهور");
    $self->{votes}->SetSize( $self->{votes}->GetBestSize() );

}

sub __do_layout {
    my $self = shift;

    $self->{sizer_1}      = Wx::BoxSizer->new(wxVERTICAL);
    $self->{sizer_2}      = Wx::BoxSizer->new(wxVERTICAL);
    $self->{grid_sizer_1} = Wx::GridSizer->new( 1, 2, 0, 0 );
    $self->{grid_sizer_2} = Wx::GridSizer->new( 1, 2, 0, 0 );
    $self->{grid_sizer_3} = Wx::GridSizer->new( 1, 2, 0, 0 );
    $self->{grid_sizer_4} = Wx::GridSizer->new( 1, 4, 0, 0 );
    $self->{grid_sizer_5} = Wx::GridSizer->new( 1, 1, 0, 0 );
    $self->{sizer_2}->Add( $self->{bitmap_button_1}, 0, wxEXPAND, 0 );
    $self->{grid_sizer_5}->Add( $self->{question}, 0, wxEXPAND, 0 );
    $self->{sizer_2}->Add( $self->{grid_sizer_5}, 1, wxEXPAND, 0 );
    $self->{grid_sizer_4}->Add( $self->{friend}, 0, wxEXPAND, 0 );
    $self->{grid_sizer_4}->Add( $self->{change}, 0, wxEXPAND, 0 );
    $self->{grid_sizer_4}->Add( $self->{remove}, 0, wxEXPAND, 0 );
    $self->{grid_sizer_4}->Add( $self->{votes},  0, wxEXPAND, 0 );
    $self->{sizer_2}->Add( $self->{grid_sizer_4}, 1, wxEXPAND, 0 );
    $self->{grid_sizer_3}->Add( $self->{opt2}, 0, wxEXPAND, 0 );
    $self->{grid_sizer_3}->Add( $self->{opt1}, 0, wxEXPAND, 0 );
    $self->{sizer_2}->Add( $self->{grid_sizer_3}, 1, wxEXPAND, 0 );
    $self->{grid_sizer_2}->Add( $self->{opt4}, 0, wxEXPAND, 0 );
    $self->{grid_sizer_2}->Add( $self->{opt3}, 0, wxEXPAND, 0 );
    $self->{sizer_2}->Add( $self->{grid_sizer_2}, 1, wxEXPAND, 0 );
    $self->{grid_sizer_1}->Add( $self->{quit},  0, wxEXPAND, 0 );
    $self->{grid_sizer_1}->Add( $self->{about}, 0, wxEXPAND, 0 );
    $self->{sizer_2}->Add( $self->{grid_sizer_1}, 1, wxEXPAND, 0 );
    $self->{sizer_1}->Add( $self->{sizer_2},      1, wxEXPAND, 0 );
    $self->SetSizer( $self->{sizer_1} );
    $self->Layout();

}

sub onClick {
    my ( $self, $event ) = @_;
    my $choice     = $event->GetEventObject()->GetLabel();
    my $correct_id = $question[6];
    my $correct    = $self->{$correct_id}->GetLabel();
    push( @tries, 'صحيحة' ) if ( $correct eq $choice );
    push( @tries, 'خاطئة' ) if ( $correct ne $choice );

    if ( scalar @tries == 10 ) {
        $self->result;
    }
    else {
        $self->draw;
    }

}

sub result {
    my $self = shift;
    my $string;
    my $counter = 1;
    for my $try (@tries) {
        $string .= $counter . "-" . $try . "\n";
        $counter++;
    }
    my $report = "ملخص الاجابات : " . "\n" . $string;
    my $result = Wx::MessageDialog->new( $self, $report, "Results" );
    $result->ShowModal;
    undef @rands;
    undef @tries;
    $self->{votes}->Enable(1);
    $self->{friend}->Enable(1);
    $self->{remove}->Enable(1);
    $self->{change}->Enable(1);
    $self->draw;
}

sub draw {
    my $self = shift;
    @question = dispatch();

    my $style = Wx::TextAttr->new();
    $style->Wx::TextAttr::SetAlignment(3);
    $self->{question}->SetDefaultStyle($style);
    $self->{question}->SetValue( $question[1] );
    $self->{opt1}->SetLabel( $question[2] );
    $self->{opt2}->SetLabel( $question[3] );
    $self->{opt3}->SetLabel( $question[4] );
    $self->{opt4}->SetLabel( $question[5] );
    $self->{opt1}->Enable(1);
    $self->{opt2}->Enable(1);
    $self->{opt3}->Enable(1);
    $self->{opt4}->Enable(1);
}

sub dispatch {
    my $self = shift;
    my ( $range, $minimum ) = ( get_dbsize(), 1 );
    my $rand = int( rand($range) ) + $minimum;
    do {
        $rand = int( rand($range) ) + $minimum;
    } while ( grep { $_ eq $rand } @rands );
    push( @rands, $rand );
    return @question = get_question($rand);
}

sub get_question {
    my $id  = shift;
    my $dbh = DBI->connect("dbi:SQLite:assets/quizer.db")
      || die "Cannot connect: $DBI::errstr";
    my $query_handle = $dbh->prepare("SELECT * FROM questions where id = $id");
    $query_handle->bind_columns(
        \my ( $index, $question, $opt1, $opt2, $opt3, $opt4, $correct ) );
    $query_handle->execute();
    while ( $query_handle->fetch() ) {
        return ( $index, decode('UTF-8' => $question), decode('UTF-8' => $opt1),
        decode('UTF-8' => $opt2),decode('UTF-8' => $opt3), decode('UTF-8' => $opt4), $correct );
    }

}

sub get_dbsize {

    my $dbh = DBI->connect("dbi:SQLite:assets/quizer.db")
      || die "Cannot connect: $DBI::errstr";
    my ($count) = $dbh->selectrow_array("SELECT COUNT(*) FROM questions");
    return $count;
}

sub remove_two_opt {
    my ( $self, $event ) = @_;
    $self->{remove}->Enable(0);
    my $correct_id = $question[6];
    given ($correct_id) {
        when ('opt1') { $self->{opt2}->Enable(0); $self->{opt3}->Enable(0); }
        when ('opt2') { $self->{opt1}->Enable(0); $self->{opt4}->Enable(0); }
        when ('opt3') { $self->{opt4}->Enable(0); $self->{opt1}->Enable(0); }
        when ('opt4') { $self->{opt3}->Enable(0); $self->{opt2}->Enable(0); }
    }
}

sub get_next_question {
    my ( $self, $event ) = @_;
    $self->{change}->Enable(0);
    $self->draw;
}

sub call_my_friend {
    my ( $self, $event ) = @_;
    $self->{friend}->Enable(0);
    my @options = qw(opt1 opt2 opt3 opt4);
    my $guess   = rand @options;
    my @guess;
    push( @guess, $options[$guess] );
    my $correct_id = $question[6];
    push( @guess, $correct_id );
    push( @guess, $correct_id );
    $guess = rand @guess;
    $guess = $self->{ $guess[$guess] }->GetLabel();
    my $help = Wx::AboutDialogInfo->new();
    my $friend = Wx::Icon->new( 'assets/linus.jpg', wxBITMAP_TYPE_ANY );
    $help->SetIcon($friend);
    $help->SetName(' ');
    $help->SetDescription("ازا بتريد ممكن تكون الاجابة ...".$guess);
    my $box = Wx::AboutBox($help);
}

sub voters {
    my ( $self, $event ) = @_;
     $self->{votes}->Enable(0);
    my $correct = $question[6];
    my @array   = qw(opt1 opt1 opt2 opt2 opt3  opt3 opt4 opt4 );
    unshift @array, "$correct";
    my %stats = qw(opt1 0 opt2 0 opt3 0 opt4 0);
    for ( 1 .. 40 ) {
        my $index = rand @array;
        $stats{ $array[$index] } += 1;
    }

    my @data = (
        [ "opt4",         "opt3",         "opt2",         "opt1" ],
        [ $stats{'opt4'}, $stats{'opt3'}, $stats{'opt2'}, $stats{'opt1'} ],
    );
    my $graph = GD::Graph::bars3d->new( 500, 400 );
    $graph->set(
        title         => 'Audience Votes',
        y_max_value   => 40,
        y_tick_number => 4,
        y_label_skip  => 2
    );
    my $gd = $graph->plot( \@data );
    open( IMG, '>assets/votes.jpg' );
    binmode IMG;
    print IMG $gd->jpeg;

    my $help = Wx::AboutDialogInfo->new();
    my $voters = Wx::Icon->new( 'assets/votes.jpg', wxBITMAP_TYPE_ANY );
    $help->SetIcon($voters);
    $help->SetName(' ');
    $help->SetDescription("Votes graphed");
    my $box = Wx::AboutBox($help);

}

sub onAbout {
    my ( $self, $event ) = @_;
    my $credit = Wx::MessageDialog->new(
        $self,
        "Arab Linux Community presents : \n        
        A quiz application with Perl Frontend. Still under testing ;) 
        bugs to : perl_sourcer\@yahoo.com 
        Code by : Ali Al-Yassen (\@Me2Ali)
        Version :1.2 
        CPAN : SQLite, wxPerl, GD::Graph
        Icons by : http://www.iconarchive.com/       
        ",       
        "About"
    );
    $credit->ShowModal;
}

sub onQuit {
    my ( $self, $event ) = @_;
    $self->Close();
}

1;

