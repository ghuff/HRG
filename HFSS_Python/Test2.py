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


[excitation, patch_names]=rectangular_patch_antenna(oDesign,2.45e9, 50, 62, 2.2, "Rogers RT/duroid 5880 (tm)","mil", "Patch1")
#createRelativeCS(oDesign, 50,10,20,1,2,3,3,2,1,"mm","TestCS")
#Test drawing functions 
#rectangular_patch_antenna(oDesign, 2.2e9, 50, 62, 2.2, "mil", "Patch2")
# assignExcitation(oDesign, "Test Wave")
print('patch name list', patch_names)
drawSphere(oDesign, 0,0,0,100, "mm","vacuum", "radiation_boundary", .55)
binarySubtraction(oDesign, "radiation_boundary", patch_names,True)
#oProject.Save()



#oProject = oDesktop.SetActiveProject("HFSS_Tutorial")
#oDesign = oProject.SetActiveDesign("HFSSDesign1")



