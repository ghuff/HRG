import win32com.client
import numpy as np
from DualQuaternion import *

def openHFSS():

	oAnsys=win32com.client.Dispatch('AnsoftHFSS.HfssScriptInterface')
	oDesktop=oAnsys.GetAppDesktop()
	print('Successfully Opened Desktop App\n')
	return [oAnsys, oDesktop]


#oEditor [object], start_coords,length,width [floats], axis, material, name [strings]
#startpos=[start_x, start_y, start_z]
def drawRectangle(oDesign, start_x, start_y, start_z, width, height, units, axis, cs, names, Transparency):
	#print("Creating " ,name)
	oEditor = oDesign.SetActiveEditor("3D Modeler")

	[xStr, yStr, zStr, wStr, hStr, name] = name_handler(oDesign,[start_x, start_y, start_z, width, height],units,names)

	#Use strings for HFSS Script CreateRectangle()
	oEditor.CreateRectangle(
		[
			"NAME:RectangleParameters",
			"XStart:="   , xStr,
			"YStart:="   , yStr,
			"ZStart:="   , zStr,
			"Width:="    , wStr,
			"Height:="   , hStr,
			"WhichAxis:=", axis
		],

		[
			"NAME:Attributes",
			"Name:=", 				   name,
			"Flags:=", 				   "",
			"Color:=", 				   "(132 132 193)",
			"Transparency:=", 		   Transparency,
			"PartCoordinateSystem:=",  cs,
			"UDMId:=", 				   "",
			"SolveInside:=", 		   True
		])
	return name

	#oEditor [object], start_coords,dimensions [floats], units, material, name [strings]
def drawBox(oDesign, start_x, start_y, start_z, Xsize, Ysize, Zsize, units, material, cs, names, Transparency):
	#print("Creating " ,name)
	oEditor = oDesign.SetActiveEditor("3D Modeler")

	SolveInside=True
	#PEC is the only case I can think of where this would need to be false; Add other cases if needed
	if(material == "pec"):
		SolveInside=False
	[xStr, yStr, zStr, XSizeStr, YSizeStr, ZSizeStr,name] = name_handler(oDesign, [start_x, start_y, start_z, Xsize, Ysize, Zsize], units,
														names)
	material = "\""+material+"\""

	oEditor.CreateBox(
		[
			"NAME:BoxParameters",
			"XPosition:=", xStr,
			"YPosition:=", yStr,
			"ZPosition:=", zStr,
			"XSize:=", XSizeStr,
			"YSize:=", YSizeStr,
			"Zsize:=", ZSizeStr
		],

		[
			"NAME:Attributes",
			"Name:="		, 	name,
			"Flags:="		, "",
			"Color:="		,   "(132 132 193)",
			"Transparency:="	, Transparency,
			"PartCoordinateSystem:=", cs,
			"UDMId:="		, "",
			"MaterialValue:="	, material,
			"SolveInside:="		, SolveInside
		])
	return name

def drawCylinder(oDesign, center_x, center_y, center_z, radius, length, units, axis, material, cs, names, Transparency):
	#print("Creating " ,name)
	oEditor  = oDesign.SetActiveEditor("3D Modeler")

	SolveInside=True
	#PEC is the only case I can think of where this would need to be false; Add other cases if needed
	if(material == "pec"):
		SolveInside=False

	[xStr, yStr, zStr, radStr, lengthStr, name] = name_handler(oDesign,[center_x,center_y,center_z,radius,length],units,names)


	material = "\"" +material   + "\""

	oEditor.CreateCylinder(
	[
		"NAME:CylinderParameters",
		"XCenter:="		, xStr,
		"YCenter:="		, yStr,
		"ZCenter:="		, zStr,
		"Radius:="		, radStr,
		"Height:="		, lengthStr,
		"WhichAxis:="	, axis,
		"NumSides:="	, "0"
	],
	[
		"NAME:Attributes",
		"Name:="		, name,
		"Flags:="		, "",
		"Color:="		, "(132 132 193)",
		"Transparency:="	, Transparency,
		"PartCoordinateSystem:=", cs,
		"UDMId:="		, "",
		"MaterialValue:="	, material,
		"SolveInside:="		, SolveInside
	])
	return name

def drawCircle(oDesign,  center_x, center_y, center_z, radius, units, axis,cs, names,  Transparency):
	#print("Creating " ,name)
	oEditor  = oDesign.SetActiveEditor("3D Modeler")

	[xStr, yStr, zStr, radStr, name] = name_handler(oDesign, [center_x, center_y, center_z, radius],
															   units, names)
	oEditor.CreateCircle(
	[
		"NAME:CircleParameters",
		"XCenter:="		, xStr,
		"YCenter:="		, yStr,
		"ZCenter:="		, zStr,
		"Radius:="		, radStr,
		"WhichAxis:="	, axis,
	],
	[
		"NAME:Attributes",
		"Name:="	 	        , name,
		"Flags:="		        , "",
		"Color:="		        , "(132 132 193)",
		"Transparency:="	    , Transparency,
		"PartCoordinateSystem:=",cs,
		"UDMId:="		        , "",
		"SolveInside:="		    , True
	])
	return name


def drawSphere(oDesign, center_x, center_y, center_z, radius, units, material, cs, names, Transparency):
	#print("Creating " ,name)
	oEditor  = oDesign.SetActiveEditor("3D Modeler")

	SolveInside=True
	#PEC is the only case I can think of where this would need to be false; Add other cases if needed
	if(material == "pec"):
		SolveInside=False

	[xStr, yStr, zStr, radStr, name] = name_handler(oDesign, [center_x, center_y, center_z, radius],
															   units, names)
	material = "\"" +material   + "\""

	oEditor.CreateSphere(
	[
		"NAME:SphereParameters",
		"XCenter:="		, xStr,
		"YCenter:="		, yStr,
		"ZCenter:="		, zStr,
		"Radius:="		, radStr,
	],
	[
		"NAME:Attributes",
		"Name:="		, name,
		"Flags:="		, "",
		"Color:="		, "(132 132 193)",
		"Transparency:="	, Transparency,
		"PartCoordinateSystem:=", cs,
		"UDMId:="		, "",
		"MaterialValue:="	, material,
		"SolveInside:="		, SolveInside
	])
	return name


def binarySubtraction(oDesign, blank_parts, tool_parts, KeepOriginals):
	#Formats string for arrays of blank_parts and tool parts
	if isinstance(blank_parts,str):
		blank_string=blank_parts
	elif all(isinstance(element,str) for element in blank_parts):
		blank_string=""
		for element in blank_parts:
			blank_string=blank_string+element+","
		blank_string=blank_string[:-1]	#Remove last comma
	else:
		raise TypeError('parameter <blank_parts> must be string or array of strings')
	if isinstance(tool_parts,str):
		tool_string=tool_parts
	elif all(isinstance(element,str) for element in tool_parts):
		tool_string=""
		for element in tool_parts:
			tool_string=tool_string+element+","
		tool_string=tool_string[:-1]	#Remove Last Comma
	else:
		raise TypeError('parameter <tool_parts> must be string or array of strings')

	oEditor  = oDesign.SetActiveEditor("3D Modeler")
	oEditor.Subtract(
	[
		"NAME:Selections",
		"Blank Parts:="		,blank_string,
		"Tool Parts:="		,tool_string
	],
	[
		"NAME:SubtractParameters",
		"KeepOriginals:="	, KeepOriginals
	])

#This function will map a quaternion vector into cartesian space so it can be modeled in HFSS
#Results in a Quaternion Coordinate System.
def dualQuaternionCS(oDesign,dq,units,name):
	#Create DualQuaternion Object
	# dq=DualQuaternion(rotation,translation)
	print('dq\n',dq)


	full_translation_matrix=dq.dualQuat2Matrix()
	print('4by4:\n',full_translation_matrix)

	total_rotation=full_translation_matrix[:-1,:-1]
	print('total rotation\n',total_rotation)

	translation=full_translation_matrix[:-1,3]
	print('translation\n',translation)

	x_axis = np.array([[1], [0], [0]])
	y_axis = np.array([[0], [1], [0]])
	x_axis = np.matmul(total_rotation,x_axis)
	y_axis = np.matmul(total_rotation,y_axis)

	[x, y, z] = translation[:]
	print('x',x,'y',y,'z',z)
	createRelativeCS(oDesign,x,y,z,x_axis,y_axis,units,name)

def createRelativeCS(oDesign, OriginX, OriginY, OriginZ, x_axis, y_axis, units, name):
	XaxisXvec = x_axis[0]
	XaxisZvec = x_axis[2]
	XaxisYvec = x_axis[1]

	YaxisXvec = y_axis[0]
	YaxisZvec = y_axis[2]
	YaxisYvec = y_axis[1]

	oEditor = oDesign.SetActiveEditor("3D Modeler")
	OriginXstr  = '%f' %(OriginX)   + units
	OriginYstr  = '%f' %(OriginY)   + units
	OriginZstr  = '%f' %(OriginZ)   + units

	XaxisXvecstr= '%f' %(XaxisXvec) + units
	XaxisYvecstr= '%f' %(XaxisYvec) + units
	XaxisZvecstr= '%f' %(XaxisZvec) + units

	YaxisXvecstr= '%f' %(YaxisXvec) + units
	YaxisYvecstr= '%f' %(YaxisYvec) + units
	YaxisZvecstr= '%f' %(YaxisZvec) + units


	oEditor.CreateRelativeCS(
	[
		"NAME:RelativeCSParameters",
		"OriginX:=", OriginXstr,
		"OriginY:=", OriginYstr,
		"OriginZ:=", OriginZstr,

		"XAxisXvec:=", XaxisXvecstr,
		"XAxisYvec:=", XaxisYvecstr,
		"XAxisZvec:=", XaxisZvecstr,

		"YAxisXvec:=", YaxisXvecstr,
		"YAxisYvec:=", YaxisYvecstr,
		"YAxisZvec:=", YaxisZvecstr,
	],
	[
		"NAME:Attributes",
		"Name:=", name
	])

#Specify rotations in Degrees
def rotatedCS(oDesign, X, Y, Z, theta_x, theta_y, theta_z, units, name):

	theta_x = np.radians(theta_x)
	theta_y = np.radians(theta_y)
	theta_z = np.radians(theta_z)

	x_rotation = np.array(
		[[1, 0, 0], [0, np.cos(theta_x), -1 * np.sin(theta_x)], [0, np.sin(theta_x), np.cos(theta_x)]])

	y_rotation = np.array(
		[[np.cos(theta_y), 0, 1*np.sin(theta_y)], [0, 1, 0], [-1*np.sin(theta_y), 0, np.cos(theta_y)]])

	z_rotation = np.array(
		[[np.cos(theta_z), -1* np.sin(theta_z), 0], [np.sin(theta_z), np.cos(theta_z), 0], [0, 0, 1]])

	total_rotation = np.matmul(z_rotation,y_rotation)
	total_rotation = np.matmul(total_rotation, x_rotation)

	print('rotation matrix',total_rotation)

	x_axis = np.array([[1], [0], [0]])
	y_axis = np.array([[0], [1], [0]])
	x_axis = np.matmul(total_rotation,x_axis)
	y_axis = np.matmul(total_rotation,y_axis)

	createRelativeCS(oDesign, X, Y, Z, x_axis, y_axis, units, name)

# string name, int numModes, Boolean: Renormalize, Alignment, Deembed,
		#Default:  1, True, False, False
#Modes>1 will need to be implemented with a for loop probably. Not sure how to do
#Use integration line for multiple modes
def assignExcitation(oDesign, name, NumModes, Renormalize, Alignment, Deembed):
	oModule = oDesign.GetModule("BoundarySetup")
	oModule.AssignWavePort(
	[
		"NAME:"+name,
		"Objects:="		, [name],
		"NumModes:="		, NumModes,
		"RenormalizeAllTerminals:=", Renormalize,
		"UseLineModeAlignment:=", Alignment,
		"DoDeembed:="		, Deembed,
		[
			"NAME:Modes",
			[
				"NAME:Mode1",
				"ModeNum:="		, 1,
				"UseIntLine:="		, False
			]
		],
		"ShowReporterFilter:="	, False,
		"ReporterFilter:="	, [True],
		"UseAnalyticAlignment:=", False
	])

def assignBoundaryMaterial(oDesign, Object_Name, material):

	Boundary_Name="Name: Bound_"+Object_Name
	#print("Assigning Boundary to: " ,Object_Name+"\n")
	oModule = oDesign.GetModule("BoundarySetup")
	oModule.AssignFiniteCond(
	[
		Boundary_Name,
		"Objects:="		    , [Object_Name],
		"UseMaterial:="		, True,
		"Material:="		, material,
		"UseThickness:="	, False,
		"Roughness:="		, "0um",
		"InfGroundPlane:="	, False
	])

def assignFaceBoundaryMaterial(oDesign, Object_Name, FaceNo, material):

	Boundary_Name="Name: Bound_"+Object_Name

	oModule = oDesign.GetModule("BoundarySetup")
	oModule.AssignFiniteCond(
	[
		Boundary_Name,
		"Faces:="		    , [FaceNo],
		"UseMaterial:="		, True,
		"Material:="		, material,
		"UseThickness:="	, False,
		"Roughness:="		, "0um",
		"InfGroundPlane:="	, False
	])

def insertSetup(oDesign, frequency,name):
	oModule = oDesign.GetModule("AnalysisSetup")
	oModule.InsertSetup("HfssDriven",
		[
			"NAME:"+name,
			"Frequency:="		, frequency,
			"PortsOnly:="		, False,
			"MaxDeltaS:="		, 0.01,
			"UseMatrixConv:="	, False,
			"MaximumPasses:="	, 20,
			"MinimumPasses:="	, 1,
			"MinimumConvergedPasses:=", 1,
			"PercentRefinement:="	, 30,
			"IsEnabled:="		, True,
			"BasisOrder:="		, 1,
			"UseIterativeSolver:="	, False,
			"DoLambdaRefine:="	, True,
			"DoMaterialLambda:="	, True,
			"SetLambdaTarget:="	, False,
			"Target:="		, 0.3333,
			"UseMaxTetIncrease:="	, False,
			"PortAccuracy:="	, 2,
			"UseABCOnPort:="	, False,
			"SetPortMinMaxTri:="	, False,
			"EnableSolverDomains:="	, False,
			"SaveRadFieldsOnly:="	, False,
			"SaveAnyFields:="	, True,
			"NoAdditionalRefinementOnImport:=", False
		])
def LinearFrequencySweep(oDesign, startF, stopF, stepF,setup_name,names):
	[startFstr,stepFstr,stopFstr, name] = name_handler(oDesign,[startF,stepF,stopF],"Hz",names)

	oModule = oDesign.GetModule("AnalysisSetup")
	oModule.InsertFrequencySweep(setup_name,
		[
			"NAME:"+name,
			"IsEnabled:="		, True,
			"SetupType:="		, "LinearStep",
			"StartValue:="		, startFstr,
			"StopValue:="		, stopFstr,
			"StepSize:="		, stepFstr,
			"Type:="		, "Interpolating",
			"SaveFields:="		, False,
			"SaveRadFields:="	, False,
			"InterpTolerance:="	, 0.5,
			"InterpMaxSolns:="	, 250,
			"InterpMinSolns:="	, 0,
			"InterpMinSubranges:="	, 1,
			"ExtrapToDC:="		, False,
			"InterpUseS:="		, True,
			"InterpUsePortImped:="	, False,
			"InterpUsePropConst:="	, True,
			"UseDerivativeConvergence:=", False,
			"InterpDerivTolerance:=", 0.2,
			"UseFullBasis:="	, True,
			"EnforcePassivity:="	, False
		])


#Boundary Object should be a sphere
#Assigns Radiation boudnary to outer surface of sphere
def AssignRadiationBoundary(oDesign, boundary_object,name):
	faces=getFaceIDs(oDesign, boundary_object)
	oModule=oDesign.GetModule("BoundarySetup")
	oModule.AssignRadiation(
		[
			"NAME:"+name,
			"Faces:="		, [int(faces[0])],
			"IsIncidentField:="	, False,
			"IsEnforcedField:="	, False,
			"IsFssReference:="	, False,
			"IsForPML:="		, False,
			"UseAdaptiveIE:="	, False,
			"IncludeInPostproc:="	, True
		])

def getFaceIDs(oDesign,  name):
	oEditor = oDesign.SetActiveEditor("3D Modeler")
	return oEditor.getFaceIDs(name)

##Names the value prop name if prop name is not an empty string
#Updates the property value with a new value if the property already exists
def localVar(oDesign, prop_name, value):
	if not isinstance(prop_name,str):
		raise TypeError('parameter <prop_name> must be string')

	#Check that prop name is not equal to value
	if (not prop_name)or(prop_name == value): #Empty prop name just retruns value
		return value

	#Get a list of all props from HFSS
	props_list=getProperties(oDesign)

	#IF prop already exists, replace value, else create prop
	for element in props_list:
		if(element == prop_name):
			changeProperty(oDesign, prop_name, value)
			return prop_name
	newProperty(oDesign, prop_name, value)
	return prop_name


#Stores a new property variable in HFSS
def newProperty(oDesign, prop_name, value):
	oDesign.ChangeProperty(
	[
		"NAME:AllTabs",
		[
			"NAME:LocalVariableTab",
			[
				"NAME:PropServers",
				"LocalVariables"
			],
			[
				"NAME:NewProps",
				[
					"NAME:"+prop_name,
					"PropType:="		, "VariableProp",
					"UserDef:="		, True,
					"Value:="		, value
				]
			]
		]
	])
	return prop_name
#Updates the value of an existing property variable in hfss
def changeProperty(oDesign, prop_name, value):
	oDesign.ChangeProperty(
	[
		"NAME:AllTabs",
		[
			"NAME:LocalVariableTab",
			[
				"NAME:PropServers",
				"LocalVariables"
			],
			[
				"NAME:ChangedProps",
				[
					"NAME:"+prop_name,
					"PropType:="		, "VariableProp",
					"UserDef:="		, True,
					"Value:="		, value
				]
			]
		]
	])
	return prop_name


def getProperties(oDesign):
	all_props=oDesign.GetVariables()
	return all_props


def globalCS(oDesign):
	oEditor = oDesign.SetActiveEditor("3D Modeler")
	oEditor.SetWCS(
		[
			"NAME:SetWCS Parameter",
			"Working Coordinate System:=", "Global"
		])


def edit_sources(oDesign,source_list,modes_list,amplitudes_list, phase_list, amplitude_units, phase_units):
	amplitude_str_list = []
	phase_str_list = []
	modes_str_list = []
	for i in range(0, len(source_list)):
		amplitude_str_list +=['%f' %(amplitudes_list[i, 0]) + amplitude_units]
		phase_str_list +=['%f' %(phase_list[i, 0]) +phase_units]
		modes_str_list +=['%d' %(modes_list[0,i])]

	print("Amplitudes\n", amplitude_str_list, "\n\nPhases\n", phase_str_list,"\n\nModes\n", modes_str_list)
	oModule = oDesign.GetModule("Solutions")
	oModule.EditSources("TotalFields",
						["NAME:Names"]+source_list,
						["NAME:Modes"]+modes_str_list,
						["NAME:Magnitudes"]+amplitude_str_list,
						["NAME:Phases"]+phase_str_list,
						["NAME:Terminated"],
						["NAME:Impedances"], False, False)

# Stores values in variables_list in corresponding variable name from names
# Can also handle expressions passed to variables list.
# Will sort variable storage so that variables defined in names can be used in expressions
def name_handler(oDesign, variables_list, units ,names):
	variable_strings = []
	print('variables_list',variables_list)
	indices = variable_ordering(variables_list,names)+[len(variables_list)]
	print(indices)
	for variable in variables_list:
		# If variable is an int or float, simply assign units to it
		if isinstance(variable,int) or isinstance(variable,float):
			variable_str = 	'%f' %(variable)   + units
		# If variable is a string expression, pass directly to HFSS
		elif isinstance(variable,str):
			variable_str = variable
			# Check expression for variable defined in names before
			# assignment
			# for name in names:
			# 	if (name in variable_str):
		else:
			raise(ValueError)
		variable_strings.append(variable_str)
	# If name is a list of strings, this segment of code will stor
	# The values passed to this function in HFSS as local variables
	# with the variable names specified
	if not isinstance(names, str):
		values = variable_strings+[names[len(names) - 1]]
		if all(isinstance(element, str) for element in names):
			if not (len(values) == len(names)):
				raise ValueError('Names array must be of size %d' % (len(values)))
			for i in indices:
				print(i)
				values[i] = localVar(oDesign, names[i], values[i])
		else:
			raise TypeError('<names> must be string or array of strings')

	else:
		values = variable_strings + [names]
	return values

# Takes in variables list and names list, returns index order for storing
# in HFSS to resolve any dependencies
def variable_ordering(variables_list,names):
	numerical_indices = []
	independent_str_indices = []
	dependent_str_indices = []
	dependencies = []

	for variable in variables_list:
		index = variables_list.index(variable)
		if isinstance(variable,int) or isinstance(variable,float):
			numerical_indices.append(index)
		elif isinstance(variable,str):
			latest_dependency = -1

			#Need to sort dependent strings by latest dependency
			for name in names:
				if name in variable:
					latest_dependency = names.index(name)
			if latest_dependency >= 0:
				dependent_str_indices.append(index)
				dependencies.append(latest_dependency)
			else:
				independent_str_indices.append(index)

	print('dependend string index', dependent_str_indices)
	print('dependencies', dependencies)

	if len(dependencies)>1:
		#Add weighting for sort to account for latest dependency
		for i in range(len(dependencies)):
			if dependencies[i] in dependent_str_indices:
				dependencies[i] += dependencies[dependent_str_indices.index(dependencies[i])]

		# Sort index list by latest dependency
		dependencies , dependent_str_indices = (list(t) for t in zip(*sorted(zip(dependencies, dependent_str_indices))))

	#Return index list in order of variable processing in HFSS
	return numerical_indices + independent_str_indices + dependent_str_indices