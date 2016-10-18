#Medusa Processing Code
This folder contains Jeff's original Medusa code in all its glory.
## AntennaTracker.pde
AntennaTracker.pde is a class that contains the bulk of the functions used to locate an Antenna Feedline with the Kinect. MedusaMain.pde Acesses the functions in this class by creating an Antenna tracker object, which can then call any function within this class. 
### findAntennaLocation()
findAntennaLocation is called from MedusaMain.pde. This function: 
* Takes the color thresholds set by the user in the main window and uses these to process the kinect image.   
* Mp3toPImage() and opencv functions are used to process the contours. 
* Calls displayContoursBoundingBoxes() to draw the red tracking boxes on the main screen. 
* Creates two ArrayLists of Rectangles which are used to pass tracking information between the Kinect, the MainWindow display, and the AnalyzeBoxes() function. 
    * Neopixels
    * rectangles
* Since JAVA passes objects by reference, *Neopixels* and *rectangles* may be modified in any function called from here. 
* Calls AnalyzeBoxes()
### AnalyzeAntennaDimensions()

### AnalyzeBoxes()
