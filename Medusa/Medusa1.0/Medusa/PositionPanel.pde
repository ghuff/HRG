import g4p_controls.*;

public class PositionPanel {
  
  public GPanel elPanel;
  private PApplet app;
  private AntennaElementHandler ah;
  public GButton refresh,discover;
  public int x,y,w,h;
  private int marginLeft = 5;
  private int marginTop = 10;
 
 private ArrayList<GLabel> labels;
 
  public PositionPanel(){
    this.app = null;
    this.elPanel = null;
   }
  
  public PositionPanel(PApplet _app, AntennaElementHandler _ah,int _x, int _y, int _w, int _h){
    this.app = _app;
    this.ah = _ah;
    this.x = _x;
    this.y = _y;
    this.w = _w;
    this.h = _h;
    this.refresh = new GButton(app, marginLeft, marginTop+10, 80, 20, "Refresh");
    this.discover = new GButton(app, marginLeft+90, marginTop+10, 80, 20, "Discover");
    labels = new ArrayList<GLabel>();
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
    elPanel = new GPanel(app, x, y, w, h, "Positions List");
    elPanel.setCollapsed(true);
    elPanel.addControl(refresh);
    elPanel.addControl(discover);
  }
  
  int i = 0;
  Set<Integer> keys = ah.elementHash.keySet();
  //for(int i = 0; i < ah.elements.size(); ++i){
  PVector loc = new PVector();
  AntennaElement tempEl = new AntennaElement();
  
  for(Integer key: keys){
      GLabel temp = new GLabel(app, 5, marginTop+ 30 + (i*20), 640, 20);
      tempEl = ah.elementHash.get(key);
      loc = tempEl.getPhysicalLocation();
      String labelString = "NUM: "+tempEl.getAntennaNumber()+" | MAC: "+tempEl.getMacAsString()+" | X: "+ loc.x +" | Y: "+loc.y+"| Z: "+loc.z+" | YAW: "+tempEl.getYaw()+" | PITCH: "+tempEl.getPitch()+" | ROLL: "+tempEl.getRoll();
     temp.setText(labelString, GAlign.LEFT, GAlign.MIDDLE);
     temp.setOpaque(true);
     temp.setTextBold();
     labels.add(temp);
     elPanel.addControl(temp);
  }
 }
 
 public void destroyElementTableControls(){
   for(int i = 0; i < labels.size(); ++i){
          GLabel temp = labels.get(i);
          temp.dispose();
          temp = null; 
     }
     labels.clear();
 }
  
}
