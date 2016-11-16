import win32com.client

def openHFSS():

	oAnsys=win32com.client.Dispatch('AnsoftHFSS.HfssScriptInterface')
	oDesktop=oAnsys.GetAppDesktop()
	print('Successfully Opened Desktop App\n')
	return [oAnsys, oDesktop]


def assignBoundaryMaterial(oDesign, Object_Name, material):
	
	Boundary_Name="Name: Bound_"+Object_Name
	print("Assigning Boundary to: " ,Object_Name+"\n")
	oModule = oDesign.GetModule("BoundarySetup")
	oModule.AssignFiniteCond(
	[
		Boundary_Name,
		"Objects:="		, [Object_Name],
		"UseMaterial:="		, True,
		"Material:="		, material,
		"UseThickness:="	, False,
		"Roughness:="		, "0um",
		"InfGroundPlane:="	, False
	])


#oEditor [object], start_coords,length,width [floats], axis, material, name [strings]   
def drawRectangle(oDesign, start_x, start_y, start_z, height, width, units, axis, name, Transparency):
	print("Creating " ,name)
	oEditor = oDesign.SetActiveEditor("3D Modeler")
	#HFSS Takes most arguments as strings: <value>+<"units"> e.g "42mil"
	xStr = '%f' %(start_x) + units
	yStr = '%f' %(start_y) + units
	zStr = '%f' %(start_z) + units
	wStr = '%f' %(width)   + units
	hStr = '%f' %(height)  + units

	#Use strings for HFSS Script CreateRectangle()
	oEditor.CreateRectangle(
		[
			"NAME:RectangleParameters", 
			"XStart:=", xStr, 
			"YStart:=", yStr, 
			"ZStart:=", zStr, 
			"Width:=", wStr, 
			"Height:=", hStr,
			"WhichAxis:=", axis
		],
		
		[
			"NAME:Attributes",
			"Name:="		, 	name,
			"Flags:="		, "",
			"Color:="		, "(132 132 193)",
			"Transparency:="	, Transparency,
			"PartCoordinateSystem:=", "Global",
			"UDMId:="		, "",
			"SolveInside:="		, True
		])

	#oEditor [object], start_coords,dimensions [floats], units, material, name [strings]   
def drawBox(oDesign, start_x, start_y, start_z, Xsize, Ysize, Zsize, units, material, name, Transparency):
	print("Creating " ,name)
	oEditor = oDesign.SetActiveEditor("3D Modeler")

	#HFSS Takes most arguments as strings: value is concatenated with units e.g "42mil"
	xStr     = '%f' %(start_x) + units
	yStr     = '%f' %(start_y) + units
	zStr     = '%f' %(start_z) + units
	XSizeStr = '%f' %(Xsize)   + units
	YSizeStr = '%f' %(Ysize)   + units
	ZSizeStr = '%f' %(Zsize)   + units
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
			"Color:="		, "(132 132 193)",
			"Transparency:="	, Transparency,
			"PartCoordinateSystem:=", "Global",
			"UDMId:="		, "",
			"MaterialValue:="	, material,
			"SolveInside:="		, True
		])

def drawCylinder(oDesign, center_x, center_y, center_z, radius, length, units, axis, material, name, Transparency):
	print("Creating " ,name)
	oEditor  = oDesign.SetActiveEditor("3D Modeler")
	xStr     = '%f' %(center_x) + units
	yStr     = '%f' %(center_y) + units
	zStr     = '%f' %(center_z) + units
	radStr	 = '%f' %(radius)  + units
	lengthStr= '%f' %(length)  + units
	material ="\""+material+"\""
	
	oEditor.CreateCylinder(
	[
		"NAME:CylinderParameters",
		"XCenter:="		, xStr,
		"YCenter:="		, yStr,
		"ZCenter:="		, zStr,
		"Radius:="		, radStr,
		"Height:="		, lengthStr,
		"WhichAxis:="		, axis,
		"NumSides:="		, "0"
	], 
	[
		"NAME:Attributes",
		"Name:="		, name,
		"Flags:="		, "",
		"Color:="		, "(132 132 193)",
		"Transparency:="	, Transparency,
		"PartCoordinateSystem:=", "Global",
		"UDMId:="		, "",
		"MaterialValue:="	, material,
		"SolveInside:="		, True
	])

def drawCircle(oDesign,  center_x, center_y, center_z, radius, units, axis, name, Transparency):
	print("Creating " ,name)
	oEditor  = oDesign.SetActiveEditor("3D Modeler")
	xStr     = '%f' %(center_x) + units
	yStr     = '%f' %(center_y) + units
	zStr     = '%f' %(center_z) + units
	radStr	 = '%f' %(radius)  + units
	
	oEditor.CreateCircle(
	[
		"NAME:CircleParameters",
		"XCenter:="		, xStr,
		"YCenter:="		, yStr,
		"ZCenter:="		, zStr,
		"Radius:="		, radStr,
		"WhichAxis:="		, axis,
	], 
	[
		"NAME:Attributes",
		"Name:="		, name,
		"Flags:="		, "",
		"Color:="		, "(132 132 193)",
		"Transparency:="	, Transparency,
		"PartCoordinateSystem:=", "Global",
		"UDMId:="		, "",
		"SolveInside:="		, True
	])

def binarySubtraction(oDesign, blank_parts, tool_parts, KeepOriginals):
	oEditor  = oDesign.SetActiveEditor("3D Modeler")
	oEditor.Subtract(
	[
		"NAME:Selections",
		"Blank Parts:="		, blank_parts,
		"Tool Parts:="		, tool_parts
	], 
	[
		"NAME:SubtractParameters",
		"KeepOriginals:="	, KeepOriginals
	])

def quaternionCS(oDesign,):
	print('Quaternion')




def createRelativeCS(oDesign,originX, OriginX, OriginY, OriginZ, XaxisXvec, XaxisYvec, XaxisXvec ):
	print('relativeCS')