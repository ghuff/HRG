#Medusa Processing Code
This folder contains Jeff's original Medusa code in all its glory.
## AntennaTracker.pde
AntennaTracker.pde is a class that contains the bulk of the functions used to locate an Antenna Feedline with the Kinect. MedusaMain.pde Acesses the functions in this class by creating an Antenna tracker object, which can then call any function within this class. 
### findAntennaLocation()
findAntennaLocation is called from MedusaMain.pde. This function: 
* Sets the color thresholds for the filter used on the raw kinect image. 
* Calls functions needed to display the red tracking boxes
* Calls AnalyzeBoxes()
* Creates two ArrayLists of Rectangles
    *Neopixels
    *rectangles
### AnalyzeAntennaDimensions()
### AnalyzeBoxes()
