package require vtk
package require vtkinteraction

# demonstrate use of point labeling and the selection window

# get the interactor ui

# Create the RenderWindow, Renderer and both Actors
#
vtkRenderer ren1
vtkRenderWindow renWin
    renWin AddRenderer ren1
vtkRenderWindowInteractor iren
    iren SetRenderWindow renWin

# Create a selection window
set xmin 200
set xLength 100
set xmax [expr $xmin + $xLength]
set ymin 200
set yLength 100
set ymax [expr $ymin + $yLength]

vtkPoints pts
    pts InsertPoint 0 $xmin $ymin 0
    pts InsertPoint 1 $xmax $ymin 0
    pts InsertPoint 2 $xmax $ymax 0
    pts InsertPoint 3 $xmin $ymax 0
vtkCellArray rect
    rect InsertNextCell 5
    rect InsertCellPoint 0
    rect InsertCellPoint 1
    rect InsertCellPoint 2
    rect InsertCellPoint 3
    rect InsertCellPoint 0
vtkPolyData selectRect
    selectRect SetPoints pts
    selectRect SetLines rect
vtkPolyDataMapper2D rectMapper
    rectMapper SetInput selectRect
vtkActor2D rectActor
    rectActor SetMapper rectMapper

# Create asphere
vtkSphereSource sphere
vtkPolyDataMapper   sphereMapper
    sphereMapper SetInput [sphere GetOutput]
    sphereMapper GlobalImmediateModeRenderingOn
vtkActor sphereActor
    sphereActor SetMapper sphereMapper

# Generate ids for labeling
vtkIdFilter ids
    ids SetInput [sphere GetOutput]
    ids PointIdsOn
    ids CellIdsOn
    ids FieldDataOn

# Create labels for points
vtkSelectVisiblePoints visPts
    visPts SetInput [ids GetOutput]
    visPts SetRenderer ren1
    visPts SelectionWindowOn
    visPts SetSelection $xmin [expr $xmin + $xLength] \
	    $ymin [expr $ymin + $yLength]
vtkLabeledDataMapper ldm
    ldm SetInput [visPts GetOutput]
    ldm SetLabelFormat "%g"
#    ldm SetLabelModeToLabelScalars
#    ldm SetLabelModeToLabelNormals
    ldm SetLabelModeToLabelFieldData
#    ldm SetLabeledComponent 0
vtkActor2D pointLabels
    pointLabels SetMapper ldm    

# Create labels for cells
vtkCellCenters cc
    cc SetInput [ids GetOutput]
vtkSelectVisiblePoints visCells
    visCells SetInput [cc GetOutput]
    visCells SetRenderer ren1
    visCells SelectionWindowOn
    visCells SetSelection $xmin [expr $xmin + $xLength] \
	    $ymin [expr $ymin + $yLength]
vtkLabeledDataMapper cellMapper
    cellMapper SetInput [visCells GetOutput]
    cellMapper SetLabelFormat "%g"
#    cellMapper SetLabelModeToLabelScalars
#    cellMapper SetLabelModeToLabelNormals
    cellMapper SetLabelModeToLabelFieldData
vtkActor2D cellLabels
    cellLabels SetMapper cellMapper    
    [cellLabels GetProperty] SetColor 0 1 0

# Add the actors to the renderer, set the background and size
#
ren1 AddActor sphereActor
ren1 AddActor2D rectActor
ren1 AddActor2D pointLabels
ren1 AddActor2D cellLabels

ren1 SetBackground 1 1 1
renWin SetSize 500 500
renWin Render


# render the image
#
iren SetUserMethod {wm deiconify .vtkInteract}

# prevent the tk window from showing up then start the event loop
wm withdraw .

proc MoveWindow {} {
    for {set y 100} {$y < 300} {incr y 25} {
	for {set x 100} {$x < 300} {incr x 25} {
	    PlaceWindow $x $y
	}
    }
}

proc PlaceWindow {xmin ymin} {
    global xLength yLength

    set xmax [expr $xmin + $xLength]
    set ymax [expr $ymin + $yLength]

    visPts SetSelection $xmin $xmax $ymin $ymax
    visCells SetSelection $xmin $xmax $ymin $ymax

    pts InsertPoint 0 $xmin $ymin 0
    pts InsertPoint 1 $xmax $ymin 0
    pts InsertPoint 2 $xmax $ymax 0
    pts InsertPoint 3 $xmin $ymax 0
    pts Modified;#because insertions don't modify object - performance reasons

    renWin Render
}

MoveWindow
PlaceWindow $xmin $ymin
