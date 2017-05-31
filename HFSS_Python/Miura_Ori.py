from HFSSLibrary import *
from EmagDevices import rectangular_patch
import DualQuaternion as dq
import numpy as np

[oAnsys, oDesktop]=openHFSS()


#Create Project, Design, and Editor Objects to use as needed.
oProject=oDesktop.NewProject()
oDesktop.RestoreWindow()
oDesign=oProject.InsertDesign("HFSS","HFSS_Script_Test", "DrivenModal", "")

#variables
b1 = 20
alpha = 60*np.pi/180
beta = 0*np.pi/180
a1 = 20
theta = np.arctan(np.tan(alpha)*np.cos(beta))
gamma = (np.pi/2)-(2*theta)
airboxhalflength = 20

########################################################################################################
######################### DRAW FOUR QUADRANTS AND UNITE  ###############################################
########################################################################################################

##NEED TO FIGURE OUT HOW TO IMPORT THESE POINTS AS STRINGS FOR PARAMETRIZATION
#   Quadrant 1
start_1 = [0, 0, 0]
point1_1 = [(b1 * np.cos(alpha)) , b1 * np.sin(alpha) * np.cos(beta) , b1 * np.sin(beta) * np.sin(alpha)]
point2_1 = [b1 * np.cos(alpha) + a1 * np.sin(gamma) , b1 * np.sin(alpha) * np.cos(beta) + a1 * np.cos(gamma) , b1 * np.sin(beta) * np.sin(alpha)]
point3_1 = [a1 * np.sin(gamma) , a1 * np.cos(gamma) , 0]

#start_1 = [0, 0, 0]
#point1_1 = ["(b1*cos(alpha))", "b1*sin(alpha)*cos(beta)", "b1*sin(beta)*sin(alpha)"]
#point2_1 = ["b1*cos(alpha)+a1*sin(gamma)", "b1*sin(alpha)*cos(beta)+a1*cos(gamma)", "b1*sin(beta)*sin(alpha)"]
#point3_1 = ["a1*sin(gamma)", "a1*cos(gamma)" , 0]

coords1 = [start_1, point1_1, point2_1, point3_1]

drawPolygon(oDesign,coords1,"mm","Quadrant_1",0)
sweep_along_vector(oDesign,[0,0,-1],0,"Round","mm","Quadrant_1")
#
#   Quadrant 2
start_2 = [0,0,0]
point1_2 = [-1*(b1*np.cos(alpha)) ,-1*(b1*np.sin(alpha)*(1-(np.sin(beta)*np.tan(beta/2)))) ,b1*np.sin(beta)*np.sin(alpha)]
point2_2 = [-1*(b1*np.cos(alpha))+a1 ,-1*(b1*np.sin(alpha)*(1-(np.sin(beta)*np.tan(beta/2)))) ,b1*np.sin(beta)*np.sin(alpha)]
point3_2 = [a1 ,0 ,0]

#start_2 = [0,0,0]
#point1_2 = ["-b1*cos(alpha)", "-b1*sin(alpha)*(1-(sin(beta)*tan(beta/2))))", "b1*sin(beta)*sin(alpha)"]
#point2_2 = ["-(b1*cos(alpha))+a1" ,"-(b1*sin(alpha)*(1-(sin(beta)*tan(beta/2))))" ,"b1*sin(beta)*sin(alpha)"]
#point3_2 = ["a1" ,0 ,0]

coords2 = [start_2, point1_2, point2_2, point3_2]

drawPolygon(oDesign,coords2,"mm","Quadrant_2",0)
sweep_along_vector(oDesign,[0,0,-1],0,"Round","mm","Quadrant_2")

#   Quadrant 3
start_3 = [0, 0, 0]
point1_3 = [(b1 * np.cos(alpha)) , b1 * np.sin(alpha) * np.cos(beta) , b1 * np.sin(beta) * np.sin(alpha)]
point2_3 = [b1 * np.cos(alpha) + a1 , b1 * np.sin(alpha) * np.cos(beta) , b1 * np.sin(beta) * np.sin(alpha)]
point3_3 = [a1 , 0 , 0]

# start_3 = [0, 0, 0]
# point1_3 = ["(b1*cos(alpha))" , "b1*sin(alpha)*cos(beta)" , "b1*sin(beta)*sin(alpha)"]
# point2_3 = ["b1*cos(alpha)+a1" , "b1*sin(alpha)*cos(beta)" , "b1*sin(beta)*sin(alpha)"]
# point3_3 = ["a1" , 0 , 0]

coords3 = [start_3, point1_3, point2_3, point3_3]

drawPolygon(oDesign,coords3,"mm","Quadrant_3",0)
sweep_along_vector(oDesign,[0,0,-1],0,"Round","mm","Quadrant_3")

#   Quadrant 4
start_4 = [0,0,0]
point1_4 = [(-b1*np.cos(alpha)) ,-b1*np.sin(alpha)*np.cos(beta) ,b1*np.sin(beta)*np.sin(alpha)]
point2_4 = [-b1*np.cos(alpha)+a1*np.sin(gamma) ,-b1*np.sin(alpha)*np.cos(beta) +a1*np.cos(gamma) ,b1*np.sin(beta)*np.sin(alpha)]
point3_4 = [a1*np.sin(gamma) ,a1*np.cos(gamma) ,0]

# start_4 = [0,0,0]
# point1_4 = ["(-b1*cos(alpha))" ,"-b1*sin(alpha)*cos(beta)" ,"b1*sin(beta)*sin(alpha)"]
# point2_4 = ["-b1*cos(alpha)+a1*sin(gamma)" ,"-b1*sin(alpha)*cos(beta)+a1*cos(gamma)" ,"b1*sin(beta)*sin(alpha)"]
# point3_4 = ["a1*sin(gamma)" ,"a1*cos(gamma)" ,0]

coords4 = [start_4, point1_4, point2_4, point3_4]

drawPolygon(oDesign,coords4,"mm","Quadrant_4",0)
sweep_along_vector(oDesign,[0,0,-1],0,"Round","mm","Quadrant_4")

quadrant_unite = "Quadrant_1", "Quadrant_2", "Quadrant_3", "Quadrant_4"
unite(oDesign, quadrant_unite)

########################################################################################################
########################################  AIRBOX  ######################################################
########################################################################################################

# Airbox top

air_1 = [0, 0, 0]
air1_1 = [-(b1*np.cos(alpha)) ,-b1*np.sin(alpha)*(1-(np.sin(beta)*np.tan(beta/2))) ,0]
air2_1 = [-b1*np.cos(alpha)+a1 ,-b1*np.sin(alpha)*(1-(np.sin(beta)*np.tan(beta/2))) ,0]
air3_1 = [a1 ,0 ,0]

air_2 = [0, 0, 0]
air1_2 = [(b1*np.cos(alpha)) ,b1*np.sin(alpha)*np.cos(beta) ,0]
air2_2 = [b1*np.cos(alpha)+a1 ,b1*np.sin(alpha)*np.cos(beta) ,0]
air3_2 = [a1 ,0 ,0]

air_3 = [0, 0, 0]
air1_3 = [(b1*np.cos(alpha)) ,b1*np.sin(alpha)*np.cos(beta) ,0]
air2_3 = [b1*np.cos(alpha)+a1*np.sin(gamma) ,b1*np.sin(alpha)*np.cos(beta) +a1*np.cos(gamma) ,0]
air3_3 = [a1*np.sin(gamma) ,a1*np.cos(gamma) ,0]

air_4 = [0, 0, 0]
air1_4 = [(-b1*np.cos(alpha)) ,-b1*np.sin(alpha)*np.cos(beta) ,0]
air2_4 = [-b1*np.cos(alpha)+a1*np.sin(gamma) ,-b1*np.sin(alpha)*np.cos(beta) +a1*np.cos(gamma) ,0]
air3_4 = [a1*np.sin(gamma) ,a1*np.cos(gamma) ,0]

# air_1 = [0, 0, 0]
# air1_1 = ["-(b1*cos(alpha))" ,"-b1*sin(alpha)*(1-(sin(beta)*tan(beta/2)))" ,0]
# air2_1 = ["-b1*cos(alpha)+a1" ,"-b1*sin(alpha)*(1-(sin(beta)*tan(beta/2)))" ,0]
# air3_1 = ["a1" ,0 ,0]
#
# air_2 = [0, 0, 0]
# air1_2 = ["(b1*cos(alpha))" ,"b1*sin(alpha)*cos(beta)" ,0]
# air2_2 = ["b1*cos(alpha)+a1" ,"b1*sin(alpha)*cos(beta)" ,0]
# air3_2 = ["a1" ,0 ,0]
#
# air_3 = [0, 0, 0]
# air1_3 = ["(b1*cos(alpha))" ,"b1*sin(alpha)*cos(beta)" ,0]
# air2_3 = ["b1*cos(alpha)+a1*sin(gamma)" ,"b1*sin(alpha)*cos(beta)+a1*cos(gamma)" ,0]
# air3_3 = ["a1*sin(gamma)" ,"a1*cos(gamma)" ,0]
#
# air_4 = [0, 0, 0]
# air1_4 = ["(-b1*cos(alpha))" ,"-b1*sin(alpha)*cos(beta)" ,0]
# air2_4 = ["-b1*cos(alpha)+a1*sin(gamma)" ,"-b1*sin(alpha)*cos(beta)+a1*cos(gamma)" ,0]
# air3_4 = ["a1*sin(gamma)" ,"a1*cos(gamma)" ,0]

air_coords1 = [air_1, air1_1, air2_1, air3_1]
air_coords2 = [air_2, air1_2, air2_2, air3_2]
air_coords3 = [air_3, air1_3, air2_3, air3_3]
air_coords4 = [air_4, air1_4, air2_4, air3_4]

#80% transparency for the airbox
drawPolygon(oDesign,air_coords1,"mm","airbox_1",.8)
drawPolygon(oDesign,air_coords2,"mm","airbox_2",.8)
drawPolygon(oDesign,air_coords3,"mm","airbox_3",.8)
drawPolygon(oDesign,air_coords4,"mm","airbox_4",.8)

#move top, sweep to size, and unite airbox
airbox_unite = "airbox_1", "airbox_2", "airbox_3", "airbox_4"
airbox_sweep = [0,0,2*airboxhalflength]
sweep_along_vector(oDesign, airbox_sweep, 0, "Round", "mm", "airbox_1")
sweep_along_vector(oDesign, airbox_sweep, 0, "Round", "mm", "airbox_2")
sweep_along_vector(oDesign, airbox_sweep, 0, "Round", "mm", "airbox_3")
sweep_along_vector(oDesign, airbox_sweep, 0, "Round", "mm", "airbox_4")
move(oDesign, [0,0,-airboxhalflength + 3], "mm", airbox_unite)
unite(oDesign, airbox_unite)

#########################################################################################################
##################### ROTATE BOX AND SUBSTRATE TO ALIGN TO THE Y-AXIS ###################################
#########################################################################################################

#convert theta back to degrees for rotation
#theta_rotate = theta*180/np.pi

theta_rotate = 90-theta*180/np.pi

rotate(oDesign,"Z", theta_rotate,"deg","Quadrant_1")
rotate(oDesign, "Z", theta_rotate, "deg","airbox_1")

#########################################################################################################
###################### EXPANDING THE AIRBOX AND NUMBER OF MIURA-ORI UNIT CELLS ##########################
#########################################################################################################

#shift in vertical is 2x the XY component of the quadrant_1 point_2
vertical_move = [2*a1*np.cos(alpha) ,0 ,0]

# vertical_move = ["2*b1*cos(alpha)" ,0 ,0]

horizontal_move = [0, 2*a1*np.cos(gamma), 0]

#horizontal_move = [0, "2*a1", 0]

# duplicate_along_line(oDesign, vertical_move, "mm", "Quadrant_1,airbox_1",2)

# duplicate_along_line(oDesign, horizontal_move, "mm", "Quadrant_1,airbox_1",2)
##need to unite the unit cells and the respective airboxes
##GENERATE A LIST OF THE GENERATED AIRBOXES AND UNIT CELLS SO YOU CAN UNITE THEM

##FIGURE OUT WHY THIS ISN'T WORKING, YOU GOON
##this needs to be a 90 degree turn from the vector on the vertical component,
## but you need to work out how this is affected by the rotation on the a1 side
# horizontal_move = [2*(a1 * np.sin(gamma)) , 2*(a1 * np.cos(gamma)) , 0]
# duplicate_along_line(oDesign,horizontal_move,"mm","Quadrant_1",2)


##need to unite the unit cells and the respective airboxes

#MAKE THESE LISTS WHEN YOU COPY THEM SO YOU CAN IMPORT DIRECTLY
# unite(oDesign,("airbox_1","airbox_1_1"))
# unite(oDesign,("Quadrant_1","Quadrant_1_1"))


######################################################################################################
##################################### DRAW SINGLE SPIRAL #############################################
######################################################################################################

#Edit > Scale
yes = input("Type yes once the spiral has been copied into the file at point 0,0,0 and named 'Spiral' be sure to scale size by 0.6 in all directions")

