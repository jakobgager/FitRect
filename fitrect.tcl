bind $w <h> {showcoords $coords}

package require math::linearalgebra
package require math::constants
package require math::geometry

proc showcoords {coords} {
  puts $coords
}

proc partitionlist {L {n 2}} {
    # from wiki
    set varlist {}
    set body {lappend res [list}
    for {} {$n>0} {incr n -1} {
        lappend varlist $n
        append body { $} $n
    }
    set res {}
    foreach $varlist $L [append body \]]
    return $res
}

proc rotmat {alpha} {
  math::constants::constants degtorad
  set ra [expr {$degtorad * $alpha}]
  return [list [list [expr {cos($ra)}] [expr {sin($ra)}]] [list [expr {-sin($ra)}] [expr {cos($ra)}]]]
}

proc rotpoly {coords alpha} {
    set pcoords [math::linearalgebra::transpose [partitionlist $coords]]
    #puts $pcoords
    set rcoords [math::linearalgebra::matmul [rotmat $alpha] $pcoords]
    set rcoords [math::linearalgebra::transpose $rcoords]
    #puts $rcoords
    #$w.c create polyline [concat {*}$rcoords] -stroke cyan -tags hull
    return $rcoords
}

proc bbox2rec {bbox} {
    lassign $bbox x1 y1 x2 y2
    set rec [list $x1 $y1 $x2 $y1 $x2 $y2 $x1 $y2 $x1 $y1] 
    return [list [expr {abs($x2-$x1) * abs($y2-$y1)}] $rec ]
}

proc fitrec {} {
    global w coords points
    set count [dict size $points]
    if {$count < 4} {
      # compute hull only if more than 4 points are present
      return 0
    }
    set minarea 100000000
    for {set i 0} {$i <= [expr {[llength $coords]-4} ]} {incr i 2} {
        set langle [math::geometry::angle [lrange $coords $i [expr {$i+3}]]]
        set lcoords [rotpoly $coords $langle]
        #$w.c create polyline [concat {*}$lcoords] -stroke cyan -tags hull
        set lbbox [math::geometry::bbox [concat {*}$lcoords]]
        lassign [bbox2rec $lbbox] larea lrec
        if {$larea < $minarea} {
            set minarea $larea
            set minrec [rotpoly $lrec [expr {-$langle}]]
            }
    }
    #puts $minarea
    $w.c create polyline [concat {*}$minrec] -stroke cyan -tags rect
    $w.c lower rect
    $w.c create text 5 8 -anchor w -tags label -text "Area: [format %g $minarea]"

}

bind $w <B1-Motion> +fitrec
bind $w <1> +fitrec
bind $w <ButtonRelease-3> +fitrec
