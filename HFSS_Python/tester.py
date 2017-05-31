from HFSSLibrary import *
from EmagDevices import rectangular_patch
import DualQuaternion as dq

[oAnsys, oDesktop]=openHFSS()


#Create Project, Design, and Editor Objects to use as needed.
oProject=oDesktop.NewProject()
oDesktop.RestoreWindow()
oDesign=oProject.InsertDesign("HFSS","HFSS_Script_Test", "DrivenModal", "")

# Patch Dimensions (All in mm)
start = [0,0,0]
point1 = [0,1,0]
point2 = [1,1,0]
point3 = [1,0,0]

coords = [start, point1, point2, point3]

drawPolygon(oDesign,coords,"mm","TestSquare",0)
sweep_along_vector(oDesign,[0,0,-1],0,"Round","mm","TestSquare")

move_vector = [1, 1, 0]

num_copies=4
duplicate_along_line(oDesign,move_vector, "mm", "TestSquare", num_copies)

object_selections = ["TestSquare"]

for i in range(1,num_copies):
    object_selections.append("TestSquare_%d"%(i))

print(object_selections)

unite(oDesign,object_selections)