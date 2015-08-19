proc compare {pivot points a b} {
    lassign [dict get $points $pivot] xp yp
    lassign [dict get $points $a] xa ya
    lassign [dict get $points $b] xb yb
    if {$a == $pivot} {
        return -1
    } elseif {$b == $pivot} {
        return 1
    } else {
        expr {($xb - $xp) * ($ya - $yp) - ($xa - $xp) * ($yb - $yp)}
    }
}

proc convhull {} {
    global points w coords
    set count [dict size $points]
    $w.c delete hull pivot rect label angle error
    if {$count < 4} {
      # compute hull only if more than 4 points are present
      return 0
    }

    set h [winfo height $w.c]

    set slist [lsort -index 1 -decreasing -integer [dict values $points]]
    set pivot [lindex $slist 0]
    set ipivot [lindex $slist 0 2]

    set indexes [dict keys $points]

    set indexes [lsort -command [list compare $ipivot $points] $indexes]
    lassign [lindex $pivot] xp yp

    $w.c create circle $xp $yp -r 8 -stroke red -tags pivot

    for {set i 0} {$i < $count} {incr i} {
        lassign [dict get $points [lindex $indexes $i]] x y id
        $w.c create text [expr {$x + 8}] [expr {$y}]\
                -anchor w -tags label -text $id
        #$w.c create line $xp [expr {$yp}] $x [expr {$y}]\
                -fill blue -dash - -tags angle
    }

    set curIndex 4
    while {1} {
        lassign [dict get $points [lindex $indexes $curIndex-3]] x0 y0
        lassign [dict get $points [lindex $indexes $curIndex-2]] x1 y1
        lassign [dict get $points [lindex $indexes $curIndex-1]] x2 y2
        if {($x1 - $x0) * ($y2 - $y0) < ($y1 - $y0) * ($x2 - $x0)} {
            #$w.c create line $x0 [expr {$y0}] $x1 [expr { $y1}]\
                           $x2 [expr {$y2}] $x0 [expr { $y0}]\
                           -fill red -tags error
            set indexes [lreplace $indexes $curIndex-2 $curIndex-2]
            incr curIndex -1
        } elseif {$curIndex == [llength $indexes]} {
            break
        } else {
            incr curIndex
        }
    }

    set coords {}
    foreach index $indexes {
        lappend coords [lindex [dict get $points $index] 0]
        lappend coords [lindex [dict get $points $index] 1]
    }
    lappend coords [lindex [dict get $points $ipivot] 0]
    lappend coords [lindex [dict get $points $ipivot] 1]

    $w.c create polyline {*}$coords -stroke orange -tags hull

    $w.c lower hull
    $w.c lower angle
    $w.c lower error
}

#convhull
bind $w.c <Configure> {bind $w.c <Configure> {}; convhull}
bind $w <B1-Motion> +convhull
bind $w <1> +convhull
bind $w <ButtonRelease-3> +convhull
