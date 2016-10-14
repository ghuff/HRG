import peasy.*;

PeasyCam cam;
BufferedReader reader;
String line;

int globalPos = 0;
int loadedPos = 0;
int animationCount = 0;

boolean showText = false;
boolean animateNext = false;

boolean showDist1 = false;
boolean showDist2 = false;
boolean showDist3 = false;
boolean showDist4 = false;
boolean showWave = false;

ArrayList<morphingElement> els;



void setup() {
  size(800,800,P3D);
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(3000);
  
  els = new ArrayList<morphingElement>();
  
  //Slow Morphing Cluster
  //loadFile("E:\\PhD_Work\\Experiments\\Morphing_Cluster\\Element_Locations_1.csv",true); //only true for first position
  //loadFile("E:\\PhD_Work\\Experiments\\Morphing_Cluster\\Element_Locations_2.csv",false);
  //loadFile("E:\\PhD_Work\\Experiments\\Morphing_Cluster\\Element_Locations_3.csv",false);
  //loadFile("E:\\PhD_Work\\Experiments\\Morphing_Cluster\\Element_Locations_4.csv",false);
  
  //Fast Morphing Cluster
  //loadFile("E:\\PhD_Work\\Experiments\\Fast_morphing_cluster\\Element_Locations_1.csv",true); //only true for first position
  //loadFile("E:\\PhD_Work\\Experiments\\Fast_morphing_cluster\\Element_Locations_2.csv",false);
 // loadFile("E:\\PhD_Work\\Experiments\\Fast_morphing_cluster\\Element_Locations_3.csv",false);
  
  //Kinect Depth Test
  //loadFile("E:\\PhD_Work\\Experiments\\Kinect_Depth_Test\\Element_Locations_1.csv",true); //only true for first position
  //loadFile("E:\\PhD_Work\\Experiments\\Kinect_Depth_Test\\Element_Locations_2.csv",false);
  
  //One Element Move First Round
  /*loadFile("E:\\PhD_Work\\Experiments\\One_Element_Move\\Element_Locations_1.csv",true); //only true for first position
  loadFile("E:\\PhD_Work\\Experiments\\One_Element_Move\\Element_Locations_2.csv",false);
  loadFile("E:\\PhD_Work\\Experiments\\One_Element_Move\\Element_Locations_3.csv",false);*/
  
  //One Element Move Second Round
  //loadFile("E:\\PhD_Work\\Experiments\\One_Element_Move\\Element_Locations_1.csv",true); //only true for first position
  //loadFile("E:\\PhD_Work\\Experiments\\One_Element_Move\\Element_Locations_2.csv",false);
 // loadFile("E:\\PhD_Work\\Experiments\\One_Element_Move\\Element_Locations_3.csv",false);
  
  //Random Position Error
  /*loadFile("E:\\PhD_Work\\Experiments\\Random_Position_Error\\element_locations_volume1.csv",true); //only true for first position
  loadFile("E:\\PhD_Work\\Experiments\\Random_Position_Error\\element_locations_volume2_1rand.csv",false);
  loadFile("E:\\PhD_Work\\Experiments\\Random_Position_Error\\element_locations_volume2_2rand.csv",false);
  loadFile("E:\\PhD_Work\\Experiments\\Random_Position_Error\\element_locations_volume2_5rand.csv",false); //only true for first position
  loadFile("E:\\PhD_Work\\Experiments\\Random_Position_Error\\element_locations_volume2_8rand.csv",false);
  loadFile("E:\\PhD_Work\\Experiments\\Random_Position_Error\\element_locations_volume2_11rand.csv",false);
  loadFile("E:\\PhD_Work\\Experiments\\Random_Position_Error\\element_locations_volume2_15rand.csv",false); //only true for first position
  loadFile("E:\\PhD_Work\\Experiments\\Random_Position_Error\\element_locations_volume2_20rand.csv",false);
  loadFile("E:\\PhD_Work\\Experiments\\Random_Position_Error\\element_locations_volume2_30rand.csv",false);
  loadFile("E:\\PhD_Work\\Experiments\\Random_Position_Error\\element_locations_volume2_40rand.csv",false); //only true for first position
  loadFile("E:\\PhD_Work\\Experiments\\Random_Position_Error\\element_locations_volume2_55rand.csv",false);*/
  
  //Line Plane Volume
  loadFile("E:\\PhD_Work\\Experiments\\line_plane_vol\\Element_Locations_1.csv",true); //only true for first position
  loadFile("E:\\PhD_Work\\Experiments\\line_plane_vol\\Element_Locations_2.csv",false);
  loadFile("E:\\PhD_Work\\Experiments\\line_plane_vol\\Element_Locations_3.csv",false);
  loadFile("E:\\PhD_Work\\Experiments\\line_plane_vol\\Element_Locations_4.csv",false);
  
  //Single Medusa Tests
  //loadFile("E:\\PhD_Work\\Experiments\\Single_Medusa_Position_Tests\\Element_Locations_1.csv",true); //only true for first position
  //loadFile("E:\\PhD_Work\\Experiments\\Single_Medusa_Position_Tests\\Element_Locations_2.csv",true);
  //loadFile("E:\\PhD_Work\\Experiments\\Single_Medusa_Position_Tests\\Element_Locations_3.csv",false);
  //loadFile("E:\\PhD_Work\\Experiments\\Single_Medusa_Position_Tests\\Element_Locations_4.csv",false);
  //loadFile("E:\\PhD_Work\\Experiments\\Single_Medusa_Position_Tests\\Element_Locations_5.csv",false);
  
  globalPos = 0;

}


void draw() {
  background(255);
  
  if(animateNext)
    animateSpheres();
  else
    drawSpheres();


}

void keyPressed() {


 if(key == 't'){
      if(showText)
        showText = false;
      else
        showText = true;
 }
 
 if(key == '1'){
      if(showDist1)
        showDist1 = false;
      else
        showDist1 = true;
 }
 
 if(key == '2'){
      if(showDist2)
        showDist2 = false;
      else
        showDist2 = true;
 }
 
 if(key == '3'){
      if(showDist3)
        showDist3 = false;
      else
        showDist3 = true;
 }
 
 if(key == '4'){
      if(showDist4)
        showDist4 = false;
      else
        showDist4 = true;
 }
 
 if(key == 'w'){
      if(showWave)
        showWave = false;
      else
        showWave = true;
 }
 
 if(key == 'r'){
    globalPos = 0; 
 }
 
 if(key == 'b'){
    globalPos -= 1; 
 }

if( key == 'n'){
  
  if(globalPos < loadedPos){
    globalPos +=1;
     animateNext = true;
  }else
    println("no more files to animate");
   
}   
}

void drawSpheres(){
    for (int i=0; i < els.size(); i++) {
       morphingElement temp = els.get(i);
       if(temp.locations.get(globalPos) != null){
           
           noStroke();
           lights();
           PVector tempV = temp.locations.get(globalPos);
           temp.cachedPos.x = tempV.x;
           temp.cachedPos.y = tempV.y;
           temp.cachedPos.z = tempV.z;
           fill(0,0,255);
           textSize(32);
           if(showText)
           text(temp.antennaNum, tempV.x, tempV.y, tempV.z);
           for(int p = globalPos; p >= 0; --p){
             drawLines(p);
           }
           fill(100,100,100,80);
           translate(tempV.x,tempV.y,tempV.z);
           
           //sphere(28);
           box(30,30,5);
           translate(-tempV.x,-tempV.y,-tempV.z);
       }
        
    }
  
}

void drawLines(int fromPos){
  
  if(fromPos == 0)
    return;
    
  for (int j=0; j < els.size(); j++) {
    morphingElement temp = els.get(j);
       if(temp.locations.get(fromPos) != null){
         int prevPos = fromPos - 1;
         
         PVector tempV = temp.locations.get(fromPos);
         PVector prevV = temp.locations.get(prevPos);
         
         if(fromPos == 1){
           stroke(255,0,0);
           fill(255,0,0);
           if(showDist1){
             textSize(32);
             String distText = "";
             if(showWave)
             distText = "X: "+((tempV.x-prevV.x)/125.0)+" Y: "+((tempV.y-prevV.y)/125.0)+" Z: "+((tempV.z-prevV.z)/125.0);
             else
             distText = "X: "+((tempV.x-prevV.x))+" Y: "+((tempV.y-prevV.y))+" Z: "+((tempV.z-prevV.z));
             text(distText, (tempV.x - prevV.x)/2.0+prevV.x, (tempV.y-prevV.y)/2.0+prevV.y, (tempV.z-prevV.z)/2.0+prevV.z);
           }
         }
         if(fromPos == 2){
           stroke(0,0,255);
           fill(0,0,255);
           if(showDist2){
             textSize(32);
             String distText = "";
             if(showWave)
             distText = "X: "+((tempV.x-prevV.x)/125.0)+" Y: "+((tempV.y-prevV.y)/125.0)+" Z: "+((tempV.z-prevV.z)/125.0);
             else
             distText = "X: "+((tempV.x-prevV.x))+" Y: "+((tempV.y-prevV.y))+" Z: "+((tempV.z-prevV.z));
             text(distText, (tempV.x - prevV.x)/2.0+prevV.x, (tempV.y-prevV.y)/2.0+prevV.y, (tempV.z-prevV.z)/2.0+prevV.z);
             
           }
         }
         if(fromPos == 3){
           stroke(0,255,0);
           fill(0,255,0);
           if(showDist3){
             textSize(32);
             String distText = "";
             if(showWave)
             distText = "X: "+((tempV.x-prevV.x)/125.0)+" Y: "+((tempV.y-prevV.y)/125.0)+" Z: "+((tempV.z-prevV.z)/125.0);
             else
             distText = "X: "+((tempV.x-prevV.x))+" Y: "+((tempV.y-prevV.y))+" Z: "+((tempV.z-prevV.z));
             text(distText, (tempV.x - prevV.x)/2.0+prevV.x, (tempV.y-prevV.y)/2.0+prevV.y, (tempV.z-prevV.z)/2.0+prevV.z);
             
           }
         }
         
         if(fromPos == 4){
           stroke(70,0,130);
           fill(70,0,130);
           if(showDist3){
             textSize(32);
             String distText = "";
             if(showWave)
             distText = "X: "+((tempV.x-prevV.x)/125.0)+" Y: "+((tempV.y-prevV.y)/125.0)+" Z: "+((tempV.z-prevV.z)/125.0);
             else
             distText = "X: "+((tempV.x-prevV.x))+" Y: "+((tempV.y-prevV.y))+" Z: "+((tempV.z-prevV.z));
             text(distText, (tempV.x - prevV.x)/2.0+prevV.x, (tempV.y-prevV.y)/2.0+prevV.y, (tempV.z-prevV.z)/2.0+prevV.z);
             
           }
         }
           
           line(prevV.x,prevV.y,prevV.z,tempV.x,tempV.y,tempV.z);
           noStroke();
           translate(tempV.x,tempV.y,tempV.z);
           sphere(10);
           translate(-tempV.x,-tempV.y,-tempV.z);
           
           noStroke();
       }
  }
  
}


void animateSpheres(){
  //if we try to animate more than we have moves
  
  float animationNum = 150.0;
  
   if(globalPos > loadedPos){
     animateNext = false;
      return;
   }
  
   int prevLoc = globalPos - 1;
   

  
  for (int i=0; i < els.size(); i++) {
       morphingElement temp = els.get(i);
       if(temp.locations.get(globalPos) != null){
         //delay(50);  
           noStroke();
           lights();
           PVector tempV = temp.locations.get(globalPos);
           PVector prevV = temp.locations.get(prevLoc);
           float incX = (tempV.x - prevV.x)/animationNum;
           float incY = (tempV.y - prevV.y)/animationNum;
           float incZ = (tempV.z - prevV.z)/animationNum;
           
           float moveX = incX + temp.cachedPos.x;
           float moveY = incY + temp.cachedPos.y;
           float moveZ = incZ + temp.cachedPos.z;
           
           
           temp.cachedPos.x = moveX;
           temp.cachedPos.y = moveY;
           temp.cachedPos.z = moveZ;
           
           
           //println("NUM :"+temp.antennaNum+" X: "+incX+" Y: "+incY+" Z: "+incZ);
           
           fill(0,0,255);
           textSize(32);
           if(showText)
           text(temp.antennaNum, moveX, moveY, moveZ);
           for(int p = prevLoc; p >= 0; --p){
             drawLines(p);
           }
           if(globalPos == 1)
             stroke(255,0,0);
           if(globalPos == 2)
             stroke(0,0,255);
           if(globalPos == 3)
             stroke(0,255,0);
           if(globalPos == 4)
             stroke(70,0,130);
           line(prevV.x,prevV.y,prevV.z,moveX,moveY,moveZ);
           noStroke();
           fill(100,100,100,80);
           translate(moveX,moveY,moveZ);
           
           //sphere(28);
           box(30,30,5);
           translate(-moveX,-moveY,-moveZ);
       }
        
    }
    
    animationCount += 1;
    
    if(animationCount > int(animationNum)){
       animateNext = false;
        animationCount = 0; 
    }
   
  
}


void loadFile(String fileName, boolean firstPos){
   String lines[] = loadStrings(fileName);
   
   
   
  
   for (int i=0; i < lines.length; i++) {
     PVector location = new PVector(0,0,0);
     int antennaNum = 0;
      if(lines[i] != null){
          if(i != 0){
            String[] items = split(lines[i], ',');
            
            if(items[0] != null)
                antennaNum = int(items[0]);
                
            if(antennaNum == 18)
                continue;
                
            if(items[1] != null)
                location.x = int(items[1]);
                
            if(items[2] != null)
                location.y = int(items[2]);
                
            if(items[3] != null)
                location.z = int(items[3]);
            if(firstPos){   
              morphingElement el = new morphingElement(antennaNum);
              
              el.locations.add(location);
              els.add(el);
            }else{
                for (int j=0; j < els.size(); j++) {
                        if(els.get(j).antennaNum == antennaNum){
                           els.get(j).locations.add(location); 
                        }
                }
            }
          }
        
      }

    }
    if(firstPos)
    println("TOTAL ELEMENTS "+els.size());
    
    loadedPos += 1;
}
