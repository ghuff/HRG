from EmagDevices import *
from xlrd import open_workbook
from numpy.matlib import zeros

[oAnsys, oDesktop] = openHFSS()

# Create Project, Design, and Editor Objects to use as needed.
oProject = oDesktop.NewProject()
oDesktop.RestoreWindow()
oDesign = oProject.InsertDesign("HFSS", "HFSS_Script_Test", "DrivenModal", "")

# Patch Dimensions (All in mm)
patchL = 28.6
patchW = 38
subW = 71
subL = 60
subH = 1.5748
probeY = 0
probeX = .5 * patchL - 6

#Constants
c=3e8
f=2.45e9
wavelength = c/f

# read in coordinates and phases from excel sheet
wb = open_workbook('Medusa_Configuration.xlsx')
s = wb.sheet_by_index(0)
positions = zeros((s.nrows - 2, 3))
rotations = zeros((s.nrows - 2, 3))
phases = zeros((s.nrows - 2, 1))
amplitudes = zeros((s.nrows - 2, 1))


# #Limit to first two rows for For Debugging
# positions = zeros((2, 3))
# rotations = zeros((2, 3))
# phases = zeros((2, 1))
# amplitudes = zeros((2, 1))

#Read in antenna positions, orientations, tapering from excel file
for r in range(0,len(positions)):
	for c in range(0, 3):
		# Store positions cells
		positions[r, c] = s.cell_value(rowx=r + 2, colx=c + 1)
		# store rotation cells
		rotations[r, c] = s.cell_value(rowx=r + 2, colx=c + 4)
		phases[r] = phases[r] + s.cell_value(rowx=r + 2, colx=c + 7)
	amplitudes[r] = s.cell_value(rowx=r + 2, colx=9)

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
	rotatedCS(oDesign, positions[i, 0], positions[i, 1], positions[i, 2], rotations[i, 0], rotations[i, 1],
								rotations[i, 2]-90, "mm", csName)
	[temp_excitation, temp_object_names] = rectangular_patch(oDesign, patchL, patchW, probeX, probeY, subL, subW, subH,
								"FR4_epoxy", "mm", csName, name)
	excitations.append(temp_excitation)
	object_names += temp_object_names

modes = np.ones((1,len(positions)))
edit_sources(oDesign, excitations, modes, amplitudes, phases, "dBm", "deg")


max_r=0
for i in range(0,len(positions)):
	r = np.sqrt(positions[i, 0]**2 + positions[i, 1]**2 + positions[i, 2]**2)
	if r > max_r:
		max_r = r + subW


globalCS(oDesign)
drawSphere(oDesign, 0, 0, 0, max_r+wavelength/3, "mm", "vacuum", "Global", "radiation_boundary", .55)
binarySubtraction(oDesign, "radiation_boundary", object_names,True)
insertSetup(oDesign, 2.45e9,"Test_Setup")
LinearFrequencySweep(oDesign,2e9,4e9, .01e7, "Test_Setup", "Test_Sweep")
AssignRadiationBoundary(oDesign, "radiation_boundary", "radiation_boundary")

oProject.SaveAs("Y:\\joshruff\\HRG\\HFSS_Python\\Script_Test.hfss",True)
oDesign.AnalyzeAll()
