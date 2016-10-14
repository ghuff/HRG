import g4p_controls.*;
import java.util.Set;

public class elementPanel{
   public GPanel elPanel;
   public GButton refresh,discover;
   private PApplet app;
   private AntennaElementHandler ah;
   int x,y,w,h;
   

  public ArrayList<elementRow> elementRows;
  
   public elementPanel(){
    this.app = null;
    this.elPanel = null;
   }
  
  public elementPanel(PApplet _app, AntennaElementHandler _ah,int _x, int _y, int _w, int _h){
    this.app = _app;
    this.ah = _ah;
    this.x = _x;
    this.y = _y;
    this.w = _w;
    this.h = _h;
    this.elementRows = new ArrayList<elementRow> ();
    this.refresh = new GButton(app, x, y+10, 80, 20, "Refresh");
    this.discover = new GButton(app, x+90, y+10, 80, 20, "Discover");
    updateRows();
  } 
  
  public void updateRows(){
   //must be called to get the latest elements
   //ah.updateElementList();
     ah.updateElementHash();
   
   if(elPanel != null){
     destroyElementTableControls();
     //elementRows.clear();
      //elPanel.dispose();
      //elPanel = null; 
   }
   
    // (this, tab title, x, y, width, height)
  if(elPanel == null){
    elPanel = new GPanel(app, x, y, w, h, "Element List");
    elPanel.setCollapsed(false);
    elPanel.addControl(refresh);
    elPanel.addControl(discover);
  }
  
  int i = 0;
  Set<Integer> keys = ah.elementHash.keySet();
  //for(int i = 0; i < ah.elements.size(); ++i){
  for(Integer key: keys){
      //elementRow temp = new elementRow(app,0,(20+40*i),ah.elements.get(i));
      println(key);
      elementRow temp = new elementRow(app,0,(20+40*i),ah.elementHash.get(key));
      elementRows.add(temp);
      elPanel.addControl(temp.macLabel);
      elPanel.addControl(temp.ipLabel);
      elPanel.addControl(temp.chkPix1);
      elPanel.addControl(temp.chkPix2);
      elPanel.addControl(temp.chkPix3);
      elPanel.addControl(temp.chkPix4);
      elPanel.addControl(temp.chkAll);
      elPanel.addControl(temp.filter);
      elPanel.addControl(temp.track);
      elPanel.addControl(temp.coords);
      elPanel.addControl(temp.pad1);
      elPanel.addControl(temp.pad2);
      elPanel.addControl(temp.pad3);
      elPanel.addControl(temp.pad4);
      ++i;
  }
 }
 
 public void destroyElementTableControls(){
     for(int i = 0; i < elementRows.size(); ++i){
          elementRows.get(i).destroyRow(); 
     }
     elementRows.clear();
 }
 
 public void newColorAnalyzePanel(int newColor){
   
   if(elementRows != null){
     println(elementRows.size());
     
     for(int i = 0; i<elementRows.size(); ++i){
       elementRow elRow = elementRows.get(i);
       
       if(elRow.chkAll.isSelected()){
           neoColor cl = new neoColor(newColor);
           ah.sendColor(cl,elRow.el.getIPAsString(),ah.PORT);
       }else{
         checkSelected(elRow,newColor);
       }
       
       //ah.updateElementInfo(elRow.el.getIPAsString());
     }
   }else{
    println("element rows in element panel not initialized, exiting routine");
    return; 
   }
   
   //ah.updateAllElementInfo();
 }
 
 public void applyNewFilters(int _hsv,int pixelNum, neoColor _filterHigh, neoColor _filterLow){
     if(elementRows != null){
     //println(elementRows.size());
     
     for(int i = 0; i<elementRows.size(); ++i){
       elementRow elRow = elementRows.get(i);
       
       
       
       if(elRow.filter.isSelected()){
         if( (pixelNum < 1) || (pixelNum > 4))
             pixelNum = 1;
           println("COLOR "+hex(elRow.el.getPixel(pixelNum)));
           neoColor _trackColor = new neoColor(elRow.el.getPixel(pixelNum));
           ah.addTrackingElement(elRow.el,_hsv,_trackColor,_filterHigh,_filterLow);
       }
     }
   }else{
    println("element rows in element panel not initialized, exiting routine");
    return; 
   }
 }
 
 public trackingElement getFilterCheckedElement(){
   if(elementRows != null){
     
     for(int i = 0; i<elementRows.size(); ++i){
       
       elementRow elRow = elementRows.get(i);
       
       if(elRow.filter.isSelected()){
         ah.updateTrackingHash();
         trackingElement temp = ah.trackingHash.get(elRow.el.getID());
         if(temp != null){ 
           return temp;
         }
       }
     }
     return null;
   }else{
    println("element rows in element panel not initialized, exiting routine");
    return null; 
   }
 }
 
 public trackingElement getTrackCheckedElement(){
   if(elementRows != null){
     
     for(int i = 0; i<elementRows.size(); ++i){
       
       elementRow elRow = elementRows.get(i);
       
       if(elRow.track.isSelected()){
         ah.updateTrackingHash();
         trackingElement temp = ah.trackingHash.get(elRow.el.getID());
         if(temp != null){ 
           return temp;
         }
       }
     }
     return null;
   }else{
    println("element rows in element panel not initialized, exiting routine");
    return null; 
   }
 }
 
public void addRandomOneMMError(){
  PVector physicalLocation = new PVector(0.0,0.0,0.0);
  
  
   if(elementRows != null){
     
     for(int i = 0; i<elementRows.size(); ++i){
       
       elementRow elRow = elementRows.get(i);
       
       Random r = new Random();
       double randomValueX = 0.0 + (1.0 - 0.0) * r.nextDouble();
       double randomValueY = 0.0 + (1.0 - 0.0) * r.nextDouble();
       double randomValueZ = 0.0 + (1.0 - 0.0) * r.nextDouble();
       
       println("X: "+randomValueX+" Y: "+randomValueY+" Z: "+randomValueZ);
       
         ah.updateTrackingHash();
         elRow.el.getPhysicalLocation().x += randomValueX;
         elRow.el.getPhysicalLocation().y += randomValueY;
         elRow.el.getPhysicalLocation().z += randomValueZ;
         
         println("NUM: "+elRow.el.getAntennaNumber()+" X: "+elRow.el.getPhysicalLocation().x+" Y: "+elRow.el.getPhysicalLocation().y+" Z: "+elRow.el.getPhysicalLocation().z);
         ah.updatePhysicalLocation(elRow.el);
         //physicalLocation = elRow.el.getPhysicalLocation();
         //trackingElement temp = ah.trackingHash.get(elRow.el.getID());
         
     }
   }else{
    println("element rows in element panel not initialized, exiting routine");
   }
 }
 
 public AntennaElement getCoordsCheckedElement(){
   if(elementRows != null){
     
     for(int i = 0; i<elementRows.size(); ++i){
       
       elementRow elRow = elementRows.get(i);
       
       if(elRow.coords.isSelected()){
         if(elRow.el != null){
            return elRow.el; 
         }
       }
     }
     return null;
   }else{
    println("element rows in element panel not initialized, exiting routine");
    return null; 
   }
 }
 
 public void printActiveElementLocations(float WLmm){
   if(elementRows != null){
     
     for(int i = 0; i<elementRows.size(); ++i){
       
       elementRow elRow = elementRows.get(i);
       
         if(elRow.el != null){
            PVector pos = elRow.el.getPhysicalLocation();
            int antNum = elRow.el.getAntennaNumber();
            println("MEDUSA -- num: "+antNum+" x: "+pos.x/WLmm+" y: "+pos.y/WLmm+" z: "+pos.z/WLmm); 
         }
   
     }
   }else{
    println("element rows in element panel not initialized, exiting routine");
   }
 }
 
 private void checkSelected(elementRow elRow, int newColor){
         int code = 0;
         
         //1
         if(elRow.chkPix1.isSelected()){
            code = 1; 
         }
         //2
         if(elRow.chkPix2.isSelected()){
            code = 2; 
         }
         //3
         if(elRow.chkPix3.isSelected()){
            code = 3; 
         }
         //4
         if(elRow.chkPix4.isSelected()){
            code = 4; 
         }
         //12
         if((elRow.chkPix1.isSelected()) && (elRow.chkPix2.isSelected())){
            code = 12; 
         }
         //13
         if((elRow.chkPix1.isSelected()) && (elRow.chkPix3.isSelected())){
            code = 13; 
         }
         //14
         if((elRow.chkPix1.isSelected()) && (elRow.chkPix4.isSelected())){
            code = 14; 
         }
         //23
         if((elRow.chkPix2.isSelected()) && (elRow.chkPix3.isSelected())){
            code = 23; 
         }
         //24
         if((elRow.chkPix2.isSelected()) && (elRow.chkPix4.isSelected())){
            code = 24; 
         }
         //34
         if((elRow.chkPix3.isSelected()) && (elRow.chkPix4.isSelected())){
            code = 34; 
         }
         //123
         if((elRow.chkPix1.isSelected()) && (elRow.chkPix2.isSelected()) && (elRow.chkPix3.isSelected())){
            code = 123; 
         }
         //124
         if((elRow.chkPix1.isSelected()) && (elRow.chkPix2.isSelected()) && (elRow.chkPix4.isSelected())){
            code = 124; 
         }
         //134
         if((elRow.chkPix1.isSelected()) && (elRow.chkPix3.isSelected()) && (elRow.chkPix4.isSelected())){
            code = 134; 
         }
         //234
         if((elRow.chkPix2.isSelected()) && (elRow.chkPix3.isSelected()) && (elRow.chkPix4.isSelected())){
            code = 234; 
         }
         
         sendIndividualColor(elRow,code,newColor);
 }
 
 private void sendIndividualColor(elementRow elRow, int code, int newColor){
   neoColor col1,col2,col3,col4;
   
     switch(code){
        case 1:
         col1 = new neoColor(newColor);
         col2 = new neoColor(elRow.el.pixel2);
         col3 = new neoColor(elRow.el.pixel3);
         col4 = new neoColor(elRow.el.pixel4);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;
      
      case 2:
         col1 = new neoColor(elRow.el.pixel1);
         col2 = new neoColor(newColor);
         col3 = new neoColor(elRow.el.pixel3);
         col4 = new neoColor(elRow.el.pixel4);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;
      
      case 3:
         col1 = new neoColor(elRow.el.pixel1);
         col2 = new neoColor(elRow.el.pixel2);
         col3 = new neoColor(newColor);
         col4 = new neoColor(elRow.el.pixel4);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;
      
      case 4:
         col1 = new neoColor(elRow.el.pixel1);
         col2 = new neoColor(elRow.el.pixel2);
         col3 = new neoColor(elRow.el.pixel3);
         col4 = new neoColor(newColor);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;
      
      case 12:
         col1 = new neoColor(newColor);
         col2 = new neoColor(newColor);
         col3 = new neoColor(elRow.el.pixel3);
         col4 = new neoColor(elRow.el.pixel4);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;
      
      case 13:
         col1 = new neoColor(newColor);
         col2 = new neoColor(elRow.el.pixel2);
         col3 = new neoColor(newColor);
         col4 = new neoColor(elRow.el.pixel4);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;
      
      case 14:
         col1 = new neoColor(newColor);
         col2 = new neoColor(elRow.el.pixel2);
         col3 = new neoColor(elRow.el.pixel3);
         col4 = new neoColor(newColor);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;
      
      case 23:
         col1 = new neoColor(elRow.el.pixel1);
         col2 = new neoColor(newColor);
         col3 = new neoColor(newColor);
         col4 = new neoColor(elRow.el.pixel4);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;
     
     case 24:
         col1 = new neoColor(elRow.el.pixel1);
         col2 = new neoColor(newColor);
         col3 = new neoColor(elRow.el.pixel3);
         col4 = new neoColor(newColor);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;
    
    case 34:
         col1 = new neoColor(elRow.el.pixel1);
         col2 = new neoColor(elRow.el.pixel2);
         col3 = new neoColor(newColor);
         col4 = new neoColor(newColor);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;
     
     case 123:
         col1 = new neoColor(newColor);
         col2 = new neoColor(newColor);
         col3 = new neoColor(newColor);
         col4 = new neoColor(elRow.el.pixel4);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;
     
     case 134:
         col1 = new neoColor(newColor);
         col2 = new neoColor(elRow.el.pixel2);
         col3 = new neoColor(newColor);
         col4 = new neoColor(newColor);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;
     
     case 124:
         col1 = new neoColor(newColor);
         col2 = new neoColor(newColor);
         col3 = new neoColor(elRow.el.pixel3);
         col4 = new neoColor(newColor);
         ah.send4Color(col1,col2,col3,col4,elRow.el.getIPAsString(),ah.PORT);
       break;  
       
     }
   
 }
  
}
