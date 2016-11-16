

from HFSSLibrary import *
import numpy as np


#Creates a box of the size of the substrate made of FR4 With Copper Ground Plane
def substrate(oDesign, length, width, height, units, material, name):
	drawBox(oDesign, -length/2, -width/2, -height/2, length, width, height,units, material, name,.8)

	GndName=name+"_GndPlane"
	drawRectangle(oDesign, -length/2, -width/2, -height/2, width, length, units, "Z", GndName,.5)
	assignBoundaryMaterial(oDesign, GndName, "Copper")

#This function designs a half wave patch antenna 
#Matches the antenna to a quarter wave coax feedline
#Can handle length units in mm or mills, other units will cause error
def patch_antenna(oDesign, operation_frequency, feedline_imedance, substrate_height, substrate_permittivity, units, name):
	print("Designing",name,"\n")
	
	#All equations taken from Balanis 3rd edition
	#Set Constants
	epsilon_0=8.85418782e-12 #s^4/(kg*m^3)
	mu_0=1.25663706e-6 #(m*kg)/(s*A)^2
	C=3e8*100 #mm/s
	substrate_clearance=10*substrate_height
	substrate_name=name+"_substrate"
	mm_to_mills=39.3700787


	#####Design Patch Antenna#####
	#Equation 14-6
	patch_width=C/(2*operation_frequency)*np.sqrt(2/(substrate_permittivity+1))
	if(units=="mil"):
		patch_width*=mm_to_mills

	#Equation 14-1
	effective_permittivity=(substrate_permittivity+1)/2+(substrate_permittivity-1)/2*pow((1+12*substrate_height/patch_width),-12)


	#Eq 14-2
	delta_L=substrate_height*.412*(effective_permittivity+.3)*(patch_width/substrate_height+.264)/((effective_permittivity-.258)*(patch_width/substrate_height+.8))

	wavelength=C/(operation_frequency*np.sqrt(substrate_permittivity))
	if(units=="mil"):
		wavelength*=mm_to_mills

	#Half Wave Patch
	L=wavelength/2
	patch_length=L-2*delta_L


	substrate_length=patch_length+substrate_clearance
	substrate_width=patch_width+substrate_clearance
	substrate(oDesign, substrate_length, substrate_width, substrate_height, units, "FR4_epoxy", substrate_name)

	#Draw Patch
	drawRectangle(oDesign, -patch_length/2, -patch_width/2, substrate_height/2, patch_width, patch_length, units, "Z", name,0)
	assignBoundaryMaterial(oDesign,name,"Copper")

	#####Locating Resonant Feedline#####

#Designs a copper coax with 
def coax(oDesign, inner_radius, outer_radius, dielectric_material):
	print('Designing',name,"\n")
