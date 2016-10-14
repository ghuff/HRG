import g4p_controls.*;

public class elementRow{
  
  public GLabel macLabel, ipLabel;
  public GCheckbox chkPix1,chkPix2,chkPix3,chkPix4,chkAll,filter,track,coords;
  public GSketchPad pad1,pad2,pad3,pad4;
  public PGraphics pg1,pg2,pg3,pg4;
  
  public AntennaElement el;
  
  private PApplet app;
  
  int x,y;
  
  int marginTop,marginLeft;

  
  public elementRow(){
     this.macLabel = null;
     this.ipLabel = null;
     this.chkPix1 = null;
     this.chkPix2 = null;
     this.chkPix3 = null;
     this.chkPix4 = null;
     this.chkAll = null;
     this.filter = null;
     this.track = null;
     this.coords = null;
     this.pad1 = null;
     this.pad2 = null;
     this.pad3 = null;
     this.pad4 = null; 
  }
  
  
  public elementRow(PApplet _app, int _x, int _y, AntennaElement _el){
     this.app = _app;
     this.x = _x;
     this.y = _y;
     this.el = _el;
     marginTop = 20;
     marginLeft = 300;
     
     initLabels();
     initCheckboxes();
     initColorBoxes();
  }
  
  private void initLabels(){
    this.macLabel = new GLabel(app, x+100, y+marginTop, 200, 20);
     macLabel.setText("| NUM: "+el.getAntennaNumber()+" | MAC: "+el.getMacAsString(), GAlign.LEFT, GAlign.MIDDLE);
     macLabel.setOpaque(true);
     macLabel.setTextBold();
     
     this.ipLabel = new GLabel(app, x, y+marginTop, 100, 20);
     ipLabel.setText("IP: "+el.getIPAsString(), GAlign.LEFT, GAlign.MIDDLE);
     ipLabel.setOpaque(true);
     ipLabel.setTextBold();
  }
  
  private void initCheckboxes(){
     this.chkPix1 = new GCheckbox(app, x+20+marginLeft, y+marginTop, 40, 20, "1");
     chkPix1.setSelected(false);

     chkPix2 = new GCheckbox(app, x+70+marginLeft, y+marginTop, 40, 20, "2");
     chkPix2.setSelected(false);
     
     chkPix3 = new GCheckbox(app, x+120+marginLeft, y+marginTop, 40, 20, "3");
     chkPix3.setSelected(false);
     
     chkPix4 = new GCheckbox(app, x+170+marginLeft, y+marginTop, 40,20, "4");
     chkPix4.setSelected(false);
     
     chkAll = new GCheckbox(app, x+220+marginLeft, y+marginTop, 40, 20, "All");
     chkAll.setSelected(false);
     
     filter = new GCheckbox(app, x+270+marginLeft, y+marginTop, 80, 20, "Filter");
     filter.setSelected(false);
     
     track = new GCheckbox(app, x+350+marginLeft, y+marginTop, 80, 20, "Track");
     track.setSelected(false);
     
     coords = new GCheckbox(app, x+430+marginLeft, y+marginTop, 80, 20, "Coords");
     coords.setSelected(false);
  }
  
  private void initColorBoxes(){
      pg1 = createGraphics(20, 20, JAVA2D);
     pg1.beginDraw();
     pg1.background(el.getPixel(1));
     pg1.endDraw();
     pad1 = new GSketchPad(app, x+20+marginLeft, y+marginTop*2, pg1.width, pg1.height);
     pad1.setGraphic(pg1);
     
     pg2 = createGraphics(20, 20, JAVA2D);
     pg2.beginDraw();
     pg2.background(el.getPixel(2));
     pg2.endDraw();
     pad2 = new GSketchPad(app, x+70+marginLeft, y+marginTop*2, pg2.width, pg2.height);
     pad2.setGraphic(pg2);
     
     pg3 = createGraphics(20, 20, JAVA2D);
     pg3.beginDraw();
     pg3.background(el.getPixel(3));
     pg3.endDraw();
     pad3 = new GSketchPad(app, x+120+marginLeft,y+marginTop*2, pg3.width, pg3.height);
     pad3.setGraphic(pg3);
     
     pg4 = createGraphics(20, 20, JAVA2D);
     pg4.beginDraw();
     pg4.background(el.getPixel(4));
     pg4.endDraw();
     pad4 = new GSketchPad(app, x+170+marginLeft, y+marginTop*2, pg4.width, pg4.height);
     pad4.setGraphic(pg4);
  }
  
  public void destroyRow(){
     macLabel.dispose();
     macLabel = null;
     ipLabel.dispose();
     ipLabel = null;
     chkPix1.dispose();
     chkPix1 = null;
     chkPix2.dispose();
     chkPix2 = null;
     chkPix3.dispose();
     chkPix3 = null;
     chkPix4.dispose();
     chkPix4 = null;
     chkAll.dispose();
     chkAll = null;
     filter.dispose();
     filter = null;
     track.dispose();
     track = null;
     coords.dispose();
     coords = null; 
     pg1 = null;
     pg2 = null;
     pg3 = null;
     pg4 = null;
     pad1.dispose();
     pad1 = null;
     pad2.dispose();
     pad2 = null;
     pad3.dispose();
     pad3 = null;
     pad4.dispose();
     pad4 = null;
  }
  
  
  
  
  
}

