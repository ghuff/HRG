from HFSSLibrary import *
import qmathcore as qmath
import DualQuaternion as dq

[oAnsys, oDesktop]=openHFSS()


#Create Project, Design, and Editor Objects to use as needed.
oProject=oDesktop.NewProject()
oDesktop.RestoreWindow()
oDesign=oProject.InsertDesign("HFSS","HFSS_Script_Test", "DrivenModal", "")


x = -516.94
y = -347.28
z = -62.25

x_rotation = -10.8657
y_rotation = 0
z_rotation = -84.654

rotation_matrix = np.array([[ 0.09316998, 0.97779994,  0.18768759, x],[-0.99565022, 0.0914996,   0.01756325, y], [ 0.,-0.18850756,  0.98207174, z], [0, 0, 0, 1]])
dq_object = dq.mat2DualQuat(rotation_matrix)

dualQuaternionCS(oDesign,dq_object,'mm','DuqlQuaternionCS')
globalCS(oDesign)
rotatedCS(oDesign,x,y,z,x_rotation,y_rotation,z_rotation,'mm','test_rotated_cs')