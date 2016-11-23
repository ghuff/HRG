

from HFSSLibrary import *
import numpy as np

#Set Constants
epsilon_0=8.85418782e-12 #s^4/(kg*m^3)
mu_0=1.25663706e-6 #(m*kg)/(s*A)^2
C=3e8 #m/s
mm_to_mils=39.3700787
mils_to_mm=1/mm_to_mils


#Creates a box of the size of the substrate made of FR4 With Copper Ground Plane
def substrate(oDesign, length, width, height, units, material, name):
	drawBox(oDesign, -length/2, -width/2, -height/2, length, width, height,units, material, name,.8)

	GndName=name+"_GndPlane"
	drawRectangle(oDesign, -length/2, -width/2, -height/2, width, length, units, "Z", GndName,.5)
	assignBoundaryMaterial(oDesign, GndName, "Copper")

#Draws a length of 50 Ohm Coax  
#Dimensions are Hardcoded for now
def coax_50_Ohm(oDesign, center_x, center_y, length, substrate_height, name):
	print("Drawing ",name,"\n")

	units="mm"
	
	probe_inner_radius=.615
	probe_inner_name=name+"_inner"
	probe_outer_name=name+"_outer"
	probe_outer_radius=2.05
	pec_name=name+"_PEC_Cap"
	dielectric_material="Teflon (tm)"


	#Draw Probe_Inner
	drawCylinder(oDesign, center_x, center_y, substrate_height/2, probe_inner_radius, -length-substrate_height, units, "Z", "Copper",probe_inner_name,0)

	#Draw Probe_Outer
	drawCylinder(oDesign, center_x, center_y, -substrate_height/2, probe_outer_radius, -length, units, "Z", dielectric_material,probe_outer_name,.75)
	
	#Draw PEC Cap
	drawCylinder(oDesign, center_x, center_y, -substrate_height/2-length, probe_outer_radius, -1, units, "Z", "pec",pec_name,0 )
	binarySubtraction(oDesign, probe_outer_name, probe_inner_name, True)



#This function designs a half wave patch antenna 
#Matches the antenna to a quarter wave coax feedline
#Can only handle 50 Ohm Feedline Impedance
#Can handle length units in mm or mills, other units will cause error
def rectangular_patch_antenna(oDesign, operation_frequency, feedline_imedance, substrate_height, substrate_permittivity, units, name):
	print("Designing",name,"\n")
	
	if(units is "mil"):
		print('converting mil to mm 1')
		substrate_height=substrate_height*mils_to_mm
		units="mm"

	#All equations taken from Balanis 3rd edition
	substrate_clearance=10*substrate_height
	substrate_name=name+"_substrate"


	#####Design Patch Antenna#####
	#Equation 14-6
	patch_width=C/(2*operation_frequency)*np.sqrt(2/(substrate_permittivity+1))
	patch_width=patch_width*1000 #m to mm


	print('patch width ', patch_width, units)
	# if(units is "mil"):
	# 	print('converting mil to mm 2')
	# 	patch_width*=mm_to_mils

	#Equation 14-1
	effective_permittivity=(substrate_permittivity+1)/2+(substrate_permittivity-1)/2*pow((1+12*substrate_height/patch_width),-12)


	#Eq 14-2
	delta_L=substrate_height*.412*(effective_permittivity+.3)*(patch_width/substrate_height+.264)/((effective_permittivity-.258)*(patch_width/substrate_height+.8))

	wavelength=C/(operation_frequency*np.sqrt(substrate_permittivity))*1000 #m to mm
	# if(units is "mil"):
	# 	print('converting mil to mm 3')
	# 	wavelength*=mm_to_mils

	#Half Wave Patch
	L=wavelength/2
	print('wavelength ', wavelength,' ',units)
	patch_length=L-2*delta_L
	print('PatchLength', patch_length,' ',units)

	substrate_length=patch_length+substrate_clearance
	substrate_width=patch_width+substrate_clearance
	substrate(oDesign, substrate_length, substrate_width, substrate_height, units, "FR4_epoxy", substrate_name)

	#Draw Patch
	drawRectangle(oDesign, -patch_length/2, -patch_width/2, substrate_height/2, patch_width, patch_length, units, "Z", name,0)
	assignBoundaryMaterial(oDesign,name,"Copper")

	#####Locating Resonant Feedline#####

	# substrate_height=substrate_height*mils_to_mm





	coax_name=name+"_feedline"
	coax_50_Ohm(oDesign, 0,0,10,substrate_height,coax_name)
	#Subtract probe from Substrate, Ground plane, and antenna
	binarySubtraction(oDesign, substrate_name, coax_name+"_inner",True)
	binarySubtraction(oDesign, substrate_name+"_GndPlane", coax_name+"_inner",True)
	binarySubtraction(oDesign, substrate_name+"_GndPlane", coax_name+"_outer",True)
	binarySubtraction(oDesign, name, coax_name+"_inner",True)
