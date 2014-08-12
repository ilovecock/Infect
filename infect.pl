#!/usr/bin/perl

use warnings; use strict;
use Time::HiRes;
use Term::ANSIColor qw(:constants);
my @grid;
my $days     = 0;
my $doctors  = 10;
my $infected = 3;
my $dead     = 0;
my $citizens = 4986;
my $gen      = 0;
my $count    = 0;
my $soldiers = 1;
my $disp     = 0;
my $nurses   = 0;
my $ff       = 0;
my $wood     = 5500;
my $timeout  = 200000;

#Generate the grid
for(my $i=0; $i<50; $i++) {
    for(my $j=0; $j<100; $j++) {
        $grid[$i][$j] = "O";
    }
}

#Assign the units to random locations within the array constraints
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "I";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "I";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "I";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "D";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "D";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "D";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "D";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "D";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "D";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "D";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "D";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "D";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "D";
$grid[int(rand(scalar(@grid)))][int(rand(scalar(@grid)))] = "S";

#Uncomment and comment above to manually set locations.
#maybe command line arguments like a normal person? hint hint
#$grid[7][0] = "D";
#$grid[8][0] = "D";
#$grid[2][0] = "D";
#$grid[3][0] = "D";
#$grid[8][1] = "D";
#$grid[9][1] = "D";
#$grid[0][1] = "D";
#$grid[1][1] = "D";
#$grid[2][1] = "D";
#$grid[0][2] = "D";
#$grid[9][0] = "I";
#$grid[0][0] = "I";
#$grid[1][0] = "I";

while (1) {
    $days++;
    if ($infected >= 4990) { win(0); }
    if ($count >= $timeout) { win(1); }

    #If there's no infected, y'dun winned
    my $noin = 0;
    for(my $n=0; $n<50; $n++) {
        for(my $m=0; $m<100; $m++) {
            if (!grep(/I/, $grid[$n][$m])) {
                $noin++;
            }
        }
    }
    if ($noin >= 5000) {
        win(1);
    }
    
    #Just keep iterating through the entire grid one by one
    for(my $i=0; $i<50; $i++) {
        for(my $j=0; $j<100; $j++) {
            my $chance = int(rand(101));
            my $doctor = int(rand(101));
            $count++;
            my $ci = $i;
            my $cj = $j;
            if ($grid[$i][$j] eq "W" or $grid[$i][$j] eq "X") { next; }
            if ($grid[$i][$j] eq "I") {
                if ($chance >= 75) {
                    my $dir = int(rand(4));
                    if ($dir == 0) {
                        $ci++;
                    } elsif ($dir == 1) {
                        $cj--;
                    } elsif ($dir == 2) {
                        $ci--;
                    } elsif ($dir == 3) {
                        $cj++;
                    }
                    if (defined($grid[$ci][$cj])) {
                        if ($grid[$ci][$cj] eq "O") {
                            #citizen becomes infected
                            $grid[$ci][$cj] =  "I";
                            $infected++; $citizens--;
                            $count = 0;
                        } elsif ($grid[$ci][$cj] eq "D" or $grid[$ci][$cj] eq "N") {
                            my $which = $grid[$ci][$cj];
                            if ($doctor <= 25) {
                                #doctor dies
                                $grid[$ci][$cj] = "X";
                                $dead++;
                                if ($which eq "D") {
                                    $doctors--;
                                } elsif ($which eq "N") {
                                    $nurses--;
                                }
                                $count = 0;
                            } elsif ($doctor <= 50) {
                                #infected dies
                                $grid[$i][$j] = "X";
                                $dead++; $infected--;
                                $count = 0;
                            } elsif ($doctor <= 55) {
                                #infected converted into nurse
                                $grid[$i][$j] = "N";
                                $nurses++; $infected--;
                                $count = 0;
                            } elsif ($doctor <= 80) {
                                #doctor/nurse converted into infected
                                $grid[$ci][$cj] = "I";
                                $infected++;
                                if ($which eq "D") {
                                    $doctors--;
                                } elsif ($which eq "N") {
                                    $nurses--;
                                }
                                $count = 0;
                            } elsif ($doctor <= 85) {
                                #infected healed to citizen
                                $grid[$i][$j] = "O";
                                $infected--; $citizens++;
                                $count = 0;
                            } elsif ($doctor <= 90) {
                                #infected healed to soldier
                                $grid[$i][$j] = "S";
                                $infected--;
                                $soldiers++;
                                $count = 0;
                            } elsif ($doctor <= 100) {
                                #both doctor/nurse and infected die
                                $grid[$i][$j]   = "X";
                                $grid[$ci][$cj] = "X";
                                $infected--;
                                $count = 0;
                                if ($which eq "D") {
                                    $doctors--;
                                } elsif ($which eq "N") {
                                    $nurses--;
                                }
                            }
                        }
                    }
                }
            } elsif ($grid[$i][$j] eq "D" or $grid[$i][$j] eq "N") {
                my $doctor = int(rand(101));
                my $dir = int(rand(4));
                if ($dir == 0) {
                    $ci++;
                } elsif ($dir == 1) {
                    $cj--;
                } elsif ($dir == 2) {
                    $ci--;
                } elsif ($dir == 3) {
                    $cj++;
                }
                my $let   = $grid[$ci][$cj];
                my $which = $grid[$i][$j];
                if (defined($let)) {
                    #Miraculous revival
                    if ($doctor == 0 and $let eq "X") {
                        $grid[$ci][$cj] = "O";
                        $dead--; $citizens++;
                        $count = 0;
                        next;
                    }
                    #Our medics don't do anything for these doomed souls/saviors
                    if ($let eq "X" or $let eq "D" or $let eq "S" or 
                        $let eq " " or $let eq "N" or $let eq "W") { next; }

                    if ($which eq "N" and $doctor <= 3 and $let eq "I") {
                        $infected--; $nurses++;
                        $grid[$ci][$cj] = "N";    
                    } elsif ($which eq "D" and $doctor <= 7) {
                        if ($let eq "I") { 
                            $infected--; $nurses++;
                            $grid[$ci][$cj] = "N";
                        }
                        if ($let eq "O") {
                            $citizens--; $nurses++;
                            $grid[$ci][$cj] = "N";
                        }
                    } elsif ($doctor <= 17) {
                        if ($let eq "I") {
                            $infected--; $citizens++;
                            $grid[$ci][$cj] = "O";
                        }
                    }
                    $count = 0;
                }
            } elsif ($grid[$i][$j] eq "O") {
                #Citizen's turn
                my $chance = int(rand(101));
                if ($chance == 100) {
                    $grid[$i][$j] = "D";
                    $doctors++; $citizens--;
                    $count = 0;
                } elsif ($chance == 1) {
                    $grid[$i][$j] = "I";
                    $citizens--; $infected++;
                    $count = 0;
                } elsif ($chance > 1 and $chance <= 16) {
                    my $dir = int(rand(4));
                    if ($dir == 0) {
                        $ci++;
                    } elsif ($dir == 1) {
                        $cj--;
                    } elsif ($dir == 2) {
                        $ci--;
                    } elsif ($dir == 3) {
                        $cj++;
                    }
                    #Can we build here? Do we have enough resources?
                    #Has enough time passed to take up carpentry?
                    if (defined($grid[$ci][$cj])) {
                        if ($grid[$ci][$cj] eq " ") {
                            if ($wood >= 25) {
                                if ($days >= 100) {
                                    $grid[$ci][$cj] = "W";
                                    $wood -= int(rand(24))+1;
                                    $count = 0;
                                }
                            }
                        }
                    }
                }
            } elsif ($grid[$i][$j] eq "S") {
                #Murderous Soldier's turn
                my $r1 = int(rand(2));
                my $r2 = int(rand(3));
                my $p1 = int(rand(2));
                my $p2 = int(rand(2));
                my $ci = $i;
                my $cj = $j;
                my $rchance = int(rand(101));
                if ($p1) { $ci += $r1; } else { $ci -= $r1; }
                if ($p2) { $cj += $r2; } else { $cj -= $r2; }
                if(defined($grid[$ci][$cj])) {
                    my $which = $grid[$ci][$cj];
                    if ($which eq "W") { next; }
                    if ($rchance <= 24) {
                        #If a citizen is in our radius of 2x3, don't shoot
                        #Doctors are fine though, who likes going to 
                        #the doctor's anyway, they're scary.
                        my $fail = 0;
                        my $inf  = 1;
                        for(my $k=$i-2; $k<$i+3; $k++) {
                            for(my $l=$j-3; $l<$j+4; $l++) {
                                my $which = $grid[$k][$l];
                                if (defined($which)) {
                                    if ($which eq "O") {
                                        $fail = 1;
                                    }
                                    if ($which eq "I") {
                                        $inf = 1;
                                    }
                                }
                            }
                        }
                        if ($fail) { next; }
                        if (!$inf) { next; }
                        if ($which eq "I") {
                            $grid[$ci][$cj] = "X";
                            $infected--; $dead++;
                            $count = 0;
                        } elsif ($which eq "O") {
                            if ($rchance >= 20) {
                                $grid[$ci][$cj] = "S";
                                $citizens--; $soldiers++;
                                $count = 0;
                            }
                        #Doctor or nurse is a victim of friendly 
                        #fire amidst the chaos
                        } elsif ($grid[$ci][$cj] eq "D" or $grid[$ci][$cj] eq "N") {
                            if ($rchance <= 1) {
                                $grid[$ci][$cj] = "X";
                                $dead++; $ff++;
                                if ($which eq "D") {
                                    $doctors--;
                                } elsif ($which eq "N") {
                                    $nurses--;
                                }
                                $count = 0;
                            }
                        #We train our soldiers to kill, then clean up that mess
                        } elsif ($grid[$ci][$cj] eq "X") {
                            $grid[$ci][$cj] = " ";
                        }
                    }
                }
            }
        }
    }
    &move;
    #If you only want the output to be displayed at the end, as
    #I know it can be pretty flickery, comment the printmap below.
    &printmap;
}

sub move {
    for(my $i=0; $i<50; $i++) {
        for(my $j=0; $j<100; $j++) {
            #Each unit excluding walls and bodies move in a random direction
            #after they've completed their action (N/W/S/E)
            #Except for that one time when I forgot to include bodies.
            #I bet that was horrific for citizens.
            if ($grid[$i][$j] =~ /[W|X|\s]/) { next; }
            my $dir = int(rand(4));
            my $ci = $i;
            my $cj = $j;
            if ($dir == 0) {
                $ci++;
            } elsif ($dir == 1) {
                $cj--;
            } elsif ($dir == 2) {
                $ci--;
            } elsif ($dir == 3) {
                $cj++;
            }
            #Politely switch spots with the open space
            if (defined($grid[$ci][$cj])) {
                if ($grid[$ci][$cj] eq " ") {
                    $grid[$ci][$cj] = $grid[$i][$j];
                    $grid[$i][$j] = " ";
                }
            }
        }
    }
}

#Uncomment the lines below for monochrome output
#and comment the bolded prints.
sub printmap {
    $disp++;
    if ($disp >= 10 or $count >= $timeout or !$infected) {
        $disp  = 0;
        system("clear");
        for(my $i=0; $i<50; $i++) {
           for(my $j=0; $j<100; $j++) {
                local $Term::ANSIColor::AUTORESET = 1;
                if ($grid[$i][$j] eq "O") {
                    print BOLD GREEN $grid[$i][$j];
#                    print $grid[$i][$j];
                } elsif ($grid[$i][$j] eq "I") {
                    print BOLD RED $grid[$i][$j];
#                    print $grid[$i][$j];
                } elsif ($grid[$i][$j] eq "D") {
                    print BOLD CYAN $grid[$i][$j];
#                    print $grid[$i][$j];
                } elsif ($grid[$i][$j] eq "S") {
                    print BOLD MAGENTA $grid[$i][$j];
#                    print $grid[$i][$j];
                } elsif ($grid[$i][$j] eq " ") {
                    print BOLD WHITE $grid[$i][$j];
#                    print $grid[$i][$j];
                } elsif ($grid[$i][$j] eq "N") {
                    print BOLD YELLOW $grid[$i][$j];
                } elsif ($grid[$i][$j] eq "W") {
                    print BOLD GREEN ON_GREEN $grid[$i][$j], RESET;
                } else {
                    print BOLD WHITE $grid[$i][$j];
#                    print $grid[$i][$j];
                }
            }
            print "\n", RESET;
        }
    }
}

sub win {
    &printmap;
    my $result;
    #Was the function told we won? How?
    if ($_[0] == 1) {
        if (!$infected) {
            $result = "for the infection to be eliminated\n";
        } else {
            $result = "for the infection to be contained\n";
        }
    } else {
        $result = "for the world to descend into chaos\n";
    }
    print "It only took " . $days . " days $result";
    print "Doctors: $doctors - Infected: $infected - Citizens: $citizens\n" .
          "Nurses: $nurses - Soldiers: $soldiers - Dead: $dead (Friendly Fire: " .
          " $ff) - Day: $days\n";
    die "Simulation ended";
}
