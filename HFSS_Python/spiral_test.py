from HFSSLibrary import *
from EmagDevices import rectangular_patch
import DualQuaternion as dq
import numpy as np

[oAnsys, oDesktop]=openHFSS()


#Create Project, Design, and Editor Objects to use as needed.
oProject=oDesktop.NewProject()
oDesktop.RestoreWindow()
oDesign=oProject.InsertDesign("HFSS","HFSS_Script_Test", "DrivenModal", "")


#variables for spiral
starting_angle = 0
t_start = 0
rot = 0
NoT = 1.03
h = 0     #mil
a = 0     #mm
b = 0.642 #mm
arm_width = 0.6 #mm
a_1 = a+arm_width   #mm
mil_bit = 0.3 #mm
r2y = (a+(a_1+mil_bit))*np.sin((a_1+mil_bit)/b-np.pi/2)
r2x = (a+(a_1+mil_bit))*np.cos((a_1+mil_bit)/b-np.pi/2)
rmax = a_1+b*NoT*2*np.pi
rmin = a+b*NoT*2*np.pi
copper_h = 35 #um


eq1x = "cos(_t+rot)*(a+_t*b)"
eq1y = "sin(_t+rot)*(a+_t*b)"
eq1z = "h"
eq1start = "t_start"
eq1end = "2*pi*NoT"
eq1numpoints = 0
createEquationCurve(oDesign, eq1x, eq1y, eq1z, eq1start, eq1end, eq1numpoints, "mm")