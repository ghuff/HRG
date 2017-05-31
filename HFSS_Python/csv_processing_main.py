from EmagDevices import *
import pandas as pd
import numpy as np


[oAnsys, oDesktop] = openHFSS()

# Create Project, Design, and Editor Objects to use as needed.
oProject = oDesktop.NewProject()
oDesktop.RestoreWindow()
oDesign = oProject.InsertDesign("HFSS", "HFSS_Script_Demo", "DrivenModal", "")

# Patch Dimensions (All in mm)
patchL = 28.6
patchW = 38

subW = 71
subL = 60
subH = 1.5748
sub_diagonal=np.sqrt(subW**2+subH**2)

rotation_min=-45
rotation_max=45

probeY = 0
probeX = .5 * patchL - 6

#Constants
c=3e8
f=2.45e9#Hz
wavelength = c/f
wavelength=wavelength*1e3
print('wavelength [mm]',wavelength)
# read in coordinates and phases from excel sheet
coordinates_df=pd.read_csv('volumetric_array_monopole_coords.csv')
x_list=coordinates_df['x'].values
y_list=coordinates_df['y'].values
z_list=coordinates_df['z'].values
positions=np.column_stack((x_list,y_list,z_list))
x_rotations=(0)*np.random.random_sample(positions.shape[0])#+rotation_min
y_rotations=(0)*np.random.random_sample(positions.shape[0])#+rotation_min
z_rotations=(rotation_max-rotation_min)*np.random.random_sample(positions.shape[0])+rotation_min
rotations=np.column_stack((x_rotations,y_rotations,z_rotations))
phases=np.zeros(x_list.shape)
amplitudes=np.zeros(x_list.shape)


#Print Data to debug excel loop
print('positions\n', positions)
print('\nrotations\n', rotations)
print('\nphases\n', phases)
print('\namplitudes\n', amplitudes)

excitations = []
object_names = []
i = 1
for i in range(0, len(positions)):
	globalCS(oDesign)  # Ensures that all relative CS are created based off global CS's
	name = "Patch%d" % (i + 1)
	csName = name + "_CS"
	#-90deg z rotation accounts for steven's starting position being 90degrees offset from my own
	rotatedCS(oDesign, positions[i,0], positions[i,1], positions[i,2], rotations[i,0], rotations[i,1],
								rotations[i,2]-90, "mm", csName)
	[temp_excitation, temp_object_names] = rectangular_patch(oDesign, patchL, patchW, probeX, probeY, subL, subW, subH,
								"FR4_epoxy", "mm", csName, name)
	excitations.append(temp_excitation)
	object_names += temp_object_names

modes = np.ones((1,len(positions)))
edit_sources(oDesign, excitations, modes, amplitudes, phases, "dBm", "deg")


max_r = sub_diagonal
for i in range(0,len(positions)):
	r = np.sqrt(positions[i,0]**2 + positions[i,1]**2 + positions[i,2]**2)
	if r > max_r:
		max_r = r + sub_diagonal

globalCS(oDesign)
drawSphere(oDesign, 0, 0, 0, max_r+wavelength/3, "mm", "vacuum", "Global", "radiation_boundary_sphere", .55)
AssignRadiationBoundary(oDesign, "radiation_boundary_sphere", "radiation_boundary")
binarySubtraction(oDesign, "radiation_boundary_sphere", object_names,True)
insertSetup(oDesign, f,10,2,20,10,"Test_Setup")
# LinearFrequencySweep(oDesign,2e9,4e9, .01e7, "Test_Setup", "Test_Sweep")


oProject.SaveAs("Y:\\joshruff\\HRG\\HFSS_Python\\Script_Test_Demo.hfss",True)
# oDesign.AnalyzeAll()
