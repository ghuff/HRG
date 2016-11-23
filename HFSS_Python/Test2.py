# ----------------------------------------------
# Script Recorded by Ansoft HFSS Version 15.0.0
# 5:09:31 PM  Nov 09, 2016
# ----------------------------------------------
from HFSSLibrary import *
from EmagDevices import *


[oAnsys, oDesktop]=openHFSS()


#Create Project, Design, and Editor Objects to use as needed. 
oProject=oDesktop.NewProject()
oDesktop.RestoreWindow()
oDesign=oProject.InsertDesign("HFSS","HFSS_Script_Test", "DrivenModal", "")



#createRelativeCS(oDesign, 0,10,20,1,2,3,3,2,1,"mm","TestCS")
#Test drawing functions 
rectangular_patch_antenna(oDesign, 2.5e9, 50, 62, 4.2, "mil", "Test_Patch")

#binarySubtraction(oDesign,"Test_Cylinder","Test_Patch",False)


#drawCircle(oDesign, 0, 0, 0, 50, "mm", "Z", "Test_Cir", 0)


#oProject.Save()



#oProject = oDesktop.SetActiveProject("HFSS_Tutorial")
#oDesign = oProject.SetActiveDesign("HFSSDesign1")



