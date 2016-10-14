import java.util.*;

class AntennaElementHandler{
  
  public final Byte ACTIVE_STATE = (byte) 0x0010;
  
  //this is used for all medusa modules
  public final int PORT = 1337;
  public final String BROADCAST_ADDRESS = "192.168.1.255";
  
  private MedusaSQLHandler mSQL;
  private udpClient UDP;
  private MedusaMessageHandler mh;
  private PApplet app;
  //public ArrayList<AntennaElement> elements;
  public Hashtable<Integer,AntennaElement> elementHash;
  public Hashtable<Integer,trackingElement> trackingHash;
 
   public AntennaElementHandler(){
    app = null;
    UDP = null;
    mSQL = null;
    elementHash = new Hashtable<Integer,AntennaElement>();
    trackingHash = new Hashtable<Integer,trackingElement>();
   }
  
  public AntennaElementHandler(PApplet _app, udpClient _client){
    this.app = _app;
     this.mSQL = new MedusaSQLHandler(app);
     this.UDP = _client;
     this.mh = new MedusaMessageHandler(this);
     //elements = new ArrayList<AntennaElement>();
     elementHash = new Hashtable<Integer,AntennaElement>();
     trackingHash = new Hashtable<Integer,trackingElement>();
  }
 
  public void addAntenna(AntennaElement _el){
       mSQL.addElement(_el);
  }
  
  public void addElementRotation(AntennaElement _el){
      mSQL.addElementRotation(_el);
  }
  
  public void addTrackingElement(AntennaElement _el, int _hsv, neoColor _trackingColor, neoColor _filterHigh, neoColor _filterLow){
     mSQL.addTrackingElement(_el,_hsv,_trackingColor,_filterHigh,_filterLow); 
  }
  
  public void updatePhysicalLocation(AntennaElement _el){
     mSQL.addPhysicalElement(_el); 
  }
 
 public void discoverAll(){
   byte options = (byte) 0x00;
   this.clearElementTable();
   UDP.sendPacket(mh.getElementInformation(options), BROADCAST_ADDRESS, PORT );
 }
 
 public void discoverAllYawPitchRoll(){
  getElementYawPitchRoll(BROADCAST_ADDRESS);
 }
 
 public void updateAllElementInfo(){
   byte options = (byte) 0x00;
   UDP.sendPacket(mh.getElementInformation(options), BROADCAST_ADDRESS, PORT );
 }
 
 public void updateElementInfo(String _ip){
   byte options = (byte) 0x00;
   UDP.sendPacket(mh.getElementInformation(options), _ip, PORT );  
 }
 
 public void getElementMACAddress(String _ip){
   UDP.sendPacket(mh.getElementMACAddress(),_ip,PORT); 
 }
 
 public void getElementIPAddress(String _ip){
  UDP.sendPacket(mh.getElementIPAddress(),_ip,PORT); 
 }
 
 public void changeElementNumber(byte number,String _ip){
  UDP.sendPacket(mh.changeElementNumber((byte) number),_ip,PORT); 
 }
 
 public void getElementYawPitchRoll(String _ip){
   UDP.sendPacket(mh.getElementYawPitchRoll(),_ip,PORT); 
 }

 public void sendRGBW(){
   String ip = "192.168.1.255"; //broadcast address
   int port        = 1337;    // the destination port
   HashMap colorMap = new HashMap();
   neoColor redColor = new neoColor((byte) 0xFF, (byte) 0x00, (byte) 0x00);
   neoColor greenColor = new neoColor((byte) 0x00, (byte) 0xFF, (byte) 0x00);
   neoColor blueColor = new neoColor((byte) 0x00, (byte) 0x00, (byte) 0xFF);
   neoColor whiteColor = new neoColor((byte) 0xFF, (byte) 0xFF, (byte) 0xFF);
   colorMap.put(1,redColor);
   colorMap.put(2,greenColor);
   colorMap.put(3,blueColor);
   colorMap.put(4,whiteColor);
   UDP.sendPacket(mh.sendIndividualColorChange(colorMap), ip, port );   // the message to send 
 }
 
 public void send4Color(neoColor col1, neoColor col2, neoColor col3, neoColor col4, String _ip, int _port){
   HashMap colorMap = new HashMap();
   colorMap.put(1,col1);
   colorMap.put(2,col2);
   colorMap.put(3,col3);
   colorMap.put(4,col4);
   UDP.sendPacket(mh.sendIndividualColorChange(colorMap),_ip,_port);
 }

 public void sendColor(neoColor _color, String _ip, int _port){
    UDP.sendPacket(mh.sendColorChange((byte)_color.red,(byte)_color.green,(byte)_color.blue), _ip, _port );
 }

 public void sendSparkle(neoColor _color, String _ip, int _port){
    UDP.sendPacket(mh.sendSparkle((byte)_color.red,(byte)_color.green,(byte)_color.blue), _ip, _port );
 }
 
 public void showLeftRight(String _ip, int _port){
   //TODO: change order of color sides based on location and rotation
    neoColor gr = new neoColor((byte) 0x00, (byte) 0xFF, (byte) 0x00);
    neoColor bl = new neoColor((byte) 0x00, (byte) 0x00, (byte) 0xFF);
    send4Color(gr,gr,bl,bl,_ip,_port); 
 }

public void readPacket(byte data[]){
  mh.decipherPacket(data);
}

public void clearElementTable(){
  if(mSQL != null)
    mSQL.clearElementTable();
  
}


public void updateElementList(){
   //elements.clear(); //get a fresh list
  //elements = mSQL.getAllElements(); 
}

public void updateElementHash(){
   elementHash.clear();
   elementHash = mSQL.getElementHash();
    Set<Integer> keys = elementHash.keySet();
    for(Integer key: keys){
      mSQL.updateCachedElementPosition(elementHash.get(key));
      mSQL.updateCachedElementRotation(elementHash.get(key));
    }
}

public void updateTrackingHash(){
   trackingHash.clear();
   trackingHash = mSQL.getTrackingHash(); 
}

public void blackout(){
    neoColor newColor = new neoColor((byte) 0x00, (byte) 0x00, (byte) 0x00);
    sendColor(newColor,BROADCAST_ADDRESS,PORT); 
}


  
}
