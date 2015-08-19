set auto_path [linsert $auto_path 0 D:/gager/Temp/tkpath032]
package require tkpath
set w .test
toplevel $w
pack [scrollbar $w.y -command "$w.c yview"] -side right -fill y
pack [::tkp::canvas $w.c -width 400 -height 400 -yscrollc "$w.y set" -background white] -side right -fill both -expand 1

# points handling
set points [dict create]
proc add_point {w x y} {
    global points
    # add point to dict
    if {[dict size $points] > 0} {
        set newpt [expr {[lindex [dict keys $points] end] + 1}] 
    } else {
        set newpt 1
    }
    dict set points $newpt [list $x $y $newpt]
    # add point to canvas
    dict lappend points $newpt [$w.c create circle $x $y -r 5 -tag circ -fill green]
    set cid [lindex [dict get $points $newpt] 3]
    $w.c addtag circ$cid withtag $cid 
    $w.c bind circ$cid <B1-Motion> [list move_point $cid $newpt $w %x %y ] 
    puts $points
}

proc find_point {w x y} {
    global points
    set dist 4
    foreach i [dict keys $points] {
        lassign [dict get $points $i] px py id cid
        if { [expr {abs($px-$x)}] < $dist && [expr {abs($py-$y)}] < $dist} {
            return [list $i $cid]
            }
    }

}

proc remove_point {w x y} {
    global points
    lassign [find_point $w $x $y] i cid
    puts "Removed point $i"
    $w.c delete $cid
    dict unset points $i
}

proc move_point {cid id w x y} {
    global points
    set position [list $x $y]
    $w.c coords circ$cid $position
    dict set points $id [lreplace [dict get $points $id] 0 1 {*}$position]
}

proc identify {w x y} {
    global points
    lassign [find_point $w $x $y] i cid
    puts [dict get $points $i] 
}

proc listpoints {} {
    global points
    puts $points
    set slist [lsort -index 1 -decreasing -integer [dict values $points]] 
    puts [lindex $slist 0 2]
}

# Bindings
bind $w.c <Shift-Button-1> [list add_point $w %x %y]
$w.c bind circ <3> [list remove_point $w %x %y ] 
$w.c bind circ <2> [list identify $w %x %y ] 
bind $w <p> listpoints
