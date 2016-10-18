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
* Since Java passes objects by reference, *Neopixels* and *rectangles* may be modified in any function called from here. 
* Calls AnalyzeBoxes()
* If AnalyzeBoxes() returns one, calls AnalyzeAntennaDimensions()

### AnalyzeBoxes()
* Boxes are drawn on the main window before this function is called
* Counts the number of Boxes in the ArrayList *rectangles* (*rectangles* is passed as a parameter to AnalyzeBoxes())
* Two primary cases will work: 
   1. 6 or more rectangles
      * AnalyzeBoxes() tries to find 2 big rectangles which each fully contain two little recangles and do not overlap 
   2. 5 rectangles
      * AnalyzeBoxes() looks for 4 small rectangles within 1 big rectangle.
* If either of the aforementioned cases is met, AnalyzeBoxes() returns 1 indicating success.
* Otherwise, analyze boxes returns 0, indicating failure.
* This function partially creates the limitations of the tracking system, as rotating the antenna leads the big boxes to overlap, causing a failure.

### AnalyzeAntennaDimensions()
* When AnalyzeBoxes() determines that an antenna has likely been found, AnalyzeAntennaDimensions() verifies that the antenna is the correct size (within a confidence limit), and then uses the location of the boxes to determine the location of a feedline
* First Generates a Hash Table containing the real xyz coordinates of the Neopixels. 
* Ensures that there are four Neopixels, and calculates vectors between each of the Neopixels to use to find the height and width of the antenna. 


