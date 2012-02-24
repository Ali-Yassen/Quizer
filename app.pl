use Wx 0.15 qw[:allclasses];
use strict;
1;

package main;

use MyFrame;

unless (caller) {
    local *Wx::App::OnInit = sub { 1 };
    my $quizer = Wx::App->new();
    Wx::InitAllImageHandlers();
    my $Quizer = MyFrame->new();
    $Quizer->draw;
    $quizer->SetTopWindow($Quizer);
    $Quizer->Show(1);
    $quizer->MainLoop();
}