import de.bezier.data.sql.*;


class MedusaSQLHandler{

    //access
    private String user     = "root";
    private String pass     = "T3xasaggies10!";
    private String database = "medusa";
    private String host = "localhost";
    
    //Tables
    private final String ELEMENTS_TABLE = "elements";
    private final String ELEMENTPOSITIONS = "elementpositions";
    private final String ELEMENTROTATIONS = "elementrotations";
    private final String ELEMENTTRACKING = "elementtracking";
    
    
    //Columns - must match column names in the elements SQL table
    public final String ELEMENT_ID = "ELEMENT_ID";
    public final String MAC_ADDRESS = "MAC_ADDRESS";
    public final String IP_ADDRESS = "IP_ADDRESS";
    public final String NETMASK = "NETMASK";
    public final String PIXEL1_COLOR = "PIXEL1_COLOR";
    public final String PIXEL2_COLOR = "PIXEL2_COLOR";
    public final String PIXEL3_COLOR = "PIXEL3_COLOR";
    public final String PIXEL4_COLOR = "PIXEL4_COLOR";
    public final String CURRENT_STATE = "CURRENT_STATE";
    public final String ANTENNA_NUM = "ANTENNA_NUM";
    
    //Elementpositions columnames
    public final String ANTENNA_X = "ANTENNA_X";
    public final String ANTENNA_Y = "ANTENNA_Y";
    public final String ANTENNA_Z = "ANTENNA_Z";
    public final String PIXEL1_X = "PIXEL1_X";
    public final String PIXEL1_Y = "PIXEL1_Y";
    public final String PIXEL1_Z = "PIXEL1_Z";
    public final String PIXEL2_X = "PIXEL2_X";
    public final String PIXEL2_Y = "PIXEL2_Y";
    public final String PIXEL2_Z = "PIXEL2_Z";
    public final String PIXEL3_X = "PIXEL3_X";
    public final String PIXEL3_Y = "PIXEL3_Y";
    public final String PIXEL3_Z = "PIXEL3_Z";
    public final String PIXEL4_X = "PIXEL4_X";
    public final String PIXEL4_Y = "PIXEL4_Y";
    public final String PIXEL4_Z = "PIXEL4_Z";
    public final String CONFIDENCE = "CONFIDENCE";
    
    //Elementrotations columnames
    public final String YAW = "YAW";
    public final String PITCH = "PITCH";
    public final String ROLL = "ROLL";
    
    //Elementtracking columnames
    public final String USE_HSV = "USE_HSV";
    public final String TRACK_COLOR = "TRACK_COLOR";
    public final String FILTER_COLOR_HIGH = "FILTER_COLOR_HIGH";
    public final String FILTER_COLOR_LOW = "FILTER_COLOR_LOW";
    
    
    
    private MySQL msql;
    private PApplet parent;
    
    private boolean isConnected = false;
    
    //a blocking variable for updating the UI while not trying to read/write at the same time
    private boolean busy;
    
    public MedusaSQLHandler(){
     this.user = "root";
     this.pass = "T3xasaggies10!";
     this.database = "medusa";
     this.host = "localhost";
     this.isConnected = false;
     this.busy = false;
     connect(); 
    }
    
    public MedusaSQLHandler(PApplet _parent){
     this.user = "root";
     this.pass = "T3xasaggies10!";
     this.database = "medusa";
     this.host = "localhost";
     this.isConnected = false;
     this.busy = false;
     this.parent = _parent;
     connect(); 
    }
    
    public MedusaSQLHandler(String _user, String _pass, String _database, String _host){
        this.user = _user;
        this.pass = _pass;
        this.database = _database;
        this.host = _host;
        this.isConnected = false;
        this.busy = false;
        connect();
    }
    
    public boolean connect(){
       msql = new MySQL( parent, "localhost", database, user, pass );
    
        if ( msql.connect() )
        {
            //msql.query( "SELECT COUNT(*) FROM elements" );
            //msql.next();
            isConnected = true;
            println( "Database "+database+ " connected!" );
            return true;
        }
        else
        {
            println( "Could not connect to "+database);
            return false;
        }
    }
    
    //getters
    public String getUser(){
       return this.user; 
    }
    
    public boolean isBusy(){
     return busy; 
    }
    
    public String getPass(){
       return this.pass; 
    }
    
    public String getDatabase(){
       return this.database; 
    }
    
    public String getHost(){
       return this.host; 
    }
    
    public boolean isConnected(){
       return isConnected; 
    }
    
    //setters
    public void setUser(String _user){
       this.user = _user;     
    }
    
    public void setPass(String _pass){
       this.pass = _pass; 
    }
    
    public void setHost(String _hostname){
       this.host = _hostname; 
    }
    
    public void setDatabase(String _database){
       this.database = _database; 
    }
    
    //Antenna Functions
    public void addElement(AntennaElement _el){
      busy = true;
      if(isConnected){
        
        if(!elementExists(_el.getID())){
        String insert = "INSERT INTO "+ELEMENTS_TABLE+"(MAC_ADDRESS,IP_ADDRESS,NETMASK,ELEMENT_ID,CURRENT_STATE,PIXEL1_COLOR,PIXEL2_COLOR," +
          "PIXEL3_COLOR,PIXEL4_COLOR,ANTENNA_NUM)values(\""+_el.getMacAsString()+"\",\""+_el.getIPAsString()+"\",\""+_el.getNetmaskAsString()
          + "\",\""+_el.getID()+"\","+_el.getCurrentState()+","+_el.getPixel(1)+","+_el.getPixel(2)+","+_el.getPixel(3)+","+_el.getPixel(4)+","+_el.getAntennaNumber()+")";
          msql.execute(insert);
        }else{
           updateElement(_el); 
        }
      }
      busy = false;  
    }
    
    public void addElementRotation(AntennaElement _el){
      busy = true;
      if(isConnected){
        
        if(!elementRotationExists(_el.getID())){
        String insert = "INSERT INTO "+ELEMENTROTATIONS+"("+ANTENNA_NUM+","+MAC_ADDRESS+","+YAW+","+PITCH+","+ROLL+","+ELEMENT_ID+")"+
          "values("+_el.getAntennaNumber()+",\""+_el.getMacAsString()+"\","+_el.getYaw()
          + ","+_el.getPitch()+","+_el.getRoll()+",\""+_el.getID()+"\")";
          msql.execute(insert);
        }else{
           updateElementRotation(_el); 
        }
      }
      busy = false;
    }
    
    public void addTrackingElement(AntennaElement _el,int _hsv, neoColor _trackColor, neoColor _filterHigh, neoColor _filterLow){
     busy = true;
    
      if(isConnected){
         
        if(!elementTrackingExists(_el.getID())){
           String insert = "INSERT INTO "+ELEMENTTRACKING+"("+
                    ELEMENT_ID + "," +
                    USE_HSV + "," +
                    TRACK_COLOR + "," + 
                    FILTER_COLOR_HIGH + "," +
                    FILTER_COLOR_LOW + ")values('" +
                    _el.getID() +"',"+
                    _hsv +","+
                    _trackColor.getColorAsInt() +","+
                    _filterHigh.getColorAsInt() +","+
                    _filterLow.getColorAsInt() +")";
            msql.execute(insert);
        }else{
          println("SQL ELEMENTTRACKING Made it");
         updateTrackingElement(_el,_hsv,_trackColor,_filterHigh,_filterLow); 
        }            
      } 
    }
    
    
    
    public void addPhysicalElement(AntennaElement _el){
      busy = true;
      if(isConnected){
        
        if(!physicalElementExists(_el.getID())){
        String insert = "INSERT INTO "+ELEMENTPOSITIONS+"(ELEMENT_ID,ANTENNA_NUM,ANTENNA_X,ANTENNA_Y,ANTENNA_Z,PIXEL1_X,PIXEL1_y,PIXEL1_Z,PIXEL2_X,PIXEL2_Y,PIXEL2_Z,PIXEL3_X,PIXEL3_Y,PIXEL3_Z,PIXEL4_X,PIXEL4_Y,PIXEL4_Z,CONFIDENCE" +
                ")values(\""+_el.getID()+"\","+_el.getAntennaNumber()+","
                +_el.getPhysicalLocation().x+","
                +_el.getPhysicalLocation().y+","
                +_el.getPhysicalLocation().z+","
                +_el.getPixelPhysicalLocation(1).x+","
                +_el.getPixelPhysicalLocation(1).y+","
                +_el.getPixelPhysicalLocation(1).z+","
                +_el.getPixelPhysicalLocation(2).x+","
                +_el.getPixelPhysicalLocation(2).y+","
                +_el.getPixelPhysicalLocation(2).z+","
                +_el.getPixelPhysicalLocation(3).x+","
                +_el.getPixelPhysicalLocation(3).y+","
                +_el.getPixelPhysicalLocation(3).z+","
                +_el.getPixelPhysicalLocation(4).x+","
                +_el.getPixelPhysicalLocation(4).y+","
                +_el.getPixelPhysicalLocation(4).z+","
                +_el.getConfidence()+")";
          msql.execute(insert);
        }else{
           updatePhysicalElement(_el); 
        }
      }
      busy = false;
    }
    
    public void updatePhysicalElement(AntennaElement _el){
      
      if(isConnected){
        
        if(physicalElementExists(_el.getID())){
          
        String update = "UPDATE "+ELEMENTPOSITIONS+" SET "+
                ANTENNA_NUM +" = "+_el.getAntennaNumber()+","+
                ANTENNA_X +" = "+_el.getPhysicalLocation().x+","+
                ANTENNA_Y +" = "+_el.getPhysicalLocation().y+","+
                ANTENNA_Z +" = "+_el.getPhysicalLocation().z+","+
                PIXEL1_X +" = "+_el.getPixelPhysicalLocation(1).x+","+
                PIXEL1_Y +" = "+_el.getPixelPhysicalLocation(1).y+","+
                PIXEL1_Z +" = "+_el.getPixelPhysicalLocation(1).z+","+
                PIXEL2_X +" = "+_el.getPixelPhysicalLocation(2).x+","+
                PIXEL2_Y +" = "+_el.getPixelPhysicalLocation(2).y+","+
                PIXEL2_Z +" = "+_el.getPixelPhysicalLocation(2).z+","+
                PIXEL3_X +" = "+_el.getPixelPhysicalLocation(3).x+","+
                PIXEL3_Y +" = "+_el.getPixelPhysicalLocation(3).y+","+
                PIXEL3_Z +" = "+_el.getPixelPhysicalLocation(3).z+","+
                PIXEL4_X +" = "+_el.getPixelPhysicalLocation(4).x+","+
                PIXEL4_Y +" = "+_el.getPixelPhysicalLocation(4).y+","+
                PIXEL4_Z +" = "+_el.getPixelPhysicalLocation(4).z+","+
                CONFIDENCE +" = "+_el.getConfidence()+","+
                ELEMENT_ID +" = "+_el.getID()+""+
                " WHERE "+ELEMENT_ID+" = \""+_el.getID()+"\""; 
          msql.execute(update);
        }else{
           println("SQLHANDLER: COULD NOT FIND ELEMENT "+_el.getID()+" DURING PHYSICAL UPDATE");
        }
      }
      
    }
    
    public void updateTrackingElement(AntennaElement _el,int _hsv, neoColor _trackColor, neoColor _filterHigh, neoColor _filterLow){
      
      if(isConnected){
        
        if(elementTrackingExists(_el.getID())){
          
        String update = "UPDATE "+ELEMENTTRACKING+" SET "+
                ELEMENT_ID +" = '"+_el.getID()+"',"+
                USE_HSV +" = "+_hsv+","+
                TRACK_COLOR +" = "+_trackColor.getColorAsInt()+","+
                FILTER_COLOR_HIGH +" = "+_filterHigh.getColorAsInt()+","+
                FILTER_COLOR_LOW +" = "+_filterLow.getColorAsInt()+""+
                " WHERE "+ELEMENT_ID+" = \""+_el.getID()+"\""; 
          msql.execute(update);
        }else{
           println("SQLHANDLER: COULD NOT FIND ELEMENT "+_el.getID()+" DURING TRACKING UPDATE");
        }
      }
      
    }
    
    public void updateElement(AntennaElement _el){
      
        if(isConnected){
        
        if(elementExists(_el.getID())){
        String update = "UPDATE "+ELEMENTS_TABLE+
                        " SET "+MAC_ADDRESS+" = \""+_el.getMacAsString()+"\", "+
                        "  "+IP_ADDRESS+" = \""+_el.getIPAsString()+"\", "+
                        "  "+NETMASK+" = \""+_el.getNetmaskAsString()+"\", "+
                        "  "+ELEMENT_ID+" = \""+_el.getID()+"\", "+
                        "  "+CURRENT_STATE+" = "+_el.getCurrentState()+", "+
                        "  "+PIXEL1_COLOR+" = "+_el.getPixel(1)+", "+
                        "  "+PIXEL2_COLOR+" = "+_el.getPixel(2)+", "+
                        "  "+PIXEL3_COLOR+" = "+_el.getPixel(3)+", "+
                        "  "+PIXEL4_COLOR+" = "+_el.getPixel(4)+", "+
                        "  "+ANTENNA_NUM+"  = "+_el.getAntennaNumber()+
                        " WHERE "+ELEMENT_ID+" = \""+_el.getID()+"\"";
          msql.execute(update);
        }else{
           println("MYSQL_ERROR: Could not find element "+_el.getID()+" in table "+ELEMENTS_TABLE);
        }
      }
        
    }
    
    public void updateElementRotation(AntennaElement _el){
      
        if(isConnected){
        
        if(elementRotationExists(_el.getID())){
        String update = "UPDATE "+ELEMENTROTATIONS+
                        " SET "+MAC_ADDRESS+" = \""+_el.getMacAsString()+"\", "+
                        "  "+ELEMENT_ID+" = \""+_el.getID()+"\", "+
                        "  "+YAW+" = "+_el.getYaw()+", "+
                        "  "+PITCH+" = "+_el.getPitch()+", "+
                        "  "+ROLL+" = "+_el.getRoll()+", "+
                        "  "+ANTENNA_NUM+"  = "+_el.getAntennaNumber()+
                        " WHERE "+ELEMENT_ID+" = \""+_el.getID()+"\"";
          msql.execute(update);
        }else{
           println("MYSQL_ERROR: Could not find element "+_el.getID()+" in table "+ELEMENTS_TABLE);
        }
      }
        
    }
    
    public boolean elementExists(int _id){
      if(isConnected){
        String exists = "SELECT COUNT(1) FROM "+ELEMENTS_TABLE+" WHERE "+ELEMENT_ID+" = \""+_id+"\"";
        msql.query(exists);
        msql.next();
        if(msql.getInt(1) == 0)
          return false;
        else
          return true;
          
      }else{
         return false; 
      }
    }
    
    public boolean elementRotationExists(int _id){
      if(isConnected){
        String exists = "SELECT COUNT(1) FROM "+ELEMENTROTATIONS+" WHERE "+ELEMENT_ID+" = \""+_id+"\"";
        msql.query(exists);
        msql.next();
        if(msql.getInt(1) == 0)
          return false;
        else
          return true;
          
      }else{
         return false; 
      }
    }
    
    public boolean elementTrackingExists(int _id){
      if(isConnected){
        String exists = "SELECT COUNT(1) FROM "+ELEMENTTRACKING+" WHERE "+ELEMENT_ID+" = \""+_id+"\"";
        msql.query(exists);
        msql.next();
        if(msql.getInt(1) == 0)
          return false;
        else
          return true;
          
      }else{
         return false; 
      }
    }
    
    public boolean physicalElementExists(int _id){
      if(isConnected){
        String exists = "SELECT COUNT(1) FROM "+ELEMENTPOSITIONS+" WHERE "+ELEMENT_ID+" = \""+_id+"\"";
        msql.query(exists);
        msql.next();
        if(msql.getInt(1) == 0)
          return false;
        else
          return true;
          
      }else{
         return false; 
      }
    }
    
    public void clearElementTable(){
      busy = true;
      if(isConnected){
         String clearTable = "DELETE FROM "+ELEMENTS_TABLE;
         msql.execute(clearTable); 
      }
      busy = false;
    }
    
    public void deleteElementFromDatabase(AntennaElement _el){
      busy = true;
       if(isConnected){
          String delete = "DELETE FROM "+ELEMENTS_TABLE+" WHERE "+ELEMENT_ID+" = \""+_el.getID()+"\"";
          msql.execute(delete);
       }
      busy = false; 
    }
    
    public AntennaElement getElement(int id){
      busy = true;
      AntennaElement el = null;
         if(isConnected){
            String element = "SELECT * FROM "+ELEMENTS_TABLE+" WHERE "+ELEMENT_ID+" = \""+id+"\"";
            msql.query(element);
            
            while(msql.next()){
               el = new AntennaElement(msql.getString(MAC_ADDRESS),msql.getString(IP_ADDRESS),msql.getString(NETMASK),msql.getInt(PIXEL1_COLOR),msql.getInt(PIXEL2_COLOR),msql.getInt(PIXEL3_COLOR),msql.getInt(PIXEL4_COLOR),(byte)msql.getInt(ANTENNA_NUM));
            }
            busy = false;
            return el;
         }else{
            el = new AntennaElement();
            busy = false;
           return el; 
         }
        
         
    }
    
    public ArrayList<AntennaElement> getAllElements(){
      busy = true;
      ArrayList<AntennaElement> els = new ArrayList<AntennaElement>();
        if(isConnected){
            String element = "SELECT * FROM "+ELEMENTS_TABLE;
            msql.query(element);
            
            while(msql.next()){
               //println("PIX1COLOR :"+hex(msql.getInt(PIXEL1_COLOR)));
               AntennaElement el = new AntennaElement(msql.getString(MAC_ADDRESS),msql.getString(IP_ADDRESS),msql.getString(NETMASK),msql.getInt(PIXEL1_COLOR),msql.getInt(PIXEL2_COLOR),msql.getInt(PIXEL3_COLOR),msql.getInt(PIXEL4_COLOR),(byte)msql.getInt(ANTENNA_NUM));
               els.add(el);
            }
            busy = false;
            return els;
         }else{
           busy = false;
            return els;
         }
         
    }
    
    public Hashtable<Integer,AntennaElement> getElementHash(){
      busy = true;
      Hashtable<Integer,AntennaElement> els = new Hashtable<Integer,AntennaElement>();
        if(isConnected){
            String element = "SELECT * FROM "+ELEMENTS_TABLE;
            msql.query(element);
            while(msql.next()){
              //for(int i = 0; i<rows; ++i){
               // msql.next();
               //println("PIX1COLOR :"+hex(msql.getInt(PIXEL1_COLOR)));
               AntennaElement el = new AntennaElement(msql.getString(MAC_ADDRESS),msql.getString(IP_ADDRESS),msql.getString(NETMASK),msql.getInt(PIXEL1_COLOR),msql.getInt(PIXEL2_COLOR),msql.getInt(PIXEL3_COLOR),msql.getInt(PIXEL4_COLOR),(byte)msql.getInt(ANTENNA_NUM));
               //updateCachedElementPosition(el);
               //el = updateCachedElementRotation(el);
               els.put(el.getID(),el);
            }
            busy = false;
            return els;
         }else{
           busy = false;
            return els;
         }
         
    }
    
    public Hashtable<Integer,trackingElement> getTrackingHash(){
      busy = true;
      Hashtable<Integer,trackingElement> els = new Hashtable<Integer,trackingElement>();
        if(isConnected){
            String element = "SELECT * FROM "+ELEMENTTRACKING;
            msql.query(element);
            while(msql.next()){
              int id = msql.getInt(ELEMENT_ID);
               trackingElement el = new trackingElement(id,msql.getInt(USE_HSV),msql.getInt(TRACK_COLOR),msql.getInt(FILTER_COLOR_HIGH),msql.getInt(FILTER_COLOR_LOW));
               els.put(id,el);
            }
            busy = false;
            return els;
         }else{
           busy = false;
            return els;
         }
         
    }
    
   public void updateCachedElementPosition(AntennaElement el){
     if(isConnected){
      if(physicalElementExists(el.getID())){
         String element = "SELECT * FROM "+ELEMENTPOSITIONS+" WHERE "+ELEMENT_ID+" = \""+el.getID()+"\"";
            msql.query(element);
            
            while(msql.next()){
               //println("PHYS Ant: "+el.getAntennaNumber()+" x: "+msql.getFloat(ANTENNA_X));
               el.setPhysicalLocation(new PVector(msql.getFloat(ANTENNA_X),msql.getFloat(ANTENNA_Y),msql.getFloat(ANTENNA_Z)));
               el.setPixelPhysicalLocation(1,new PVector(msql.getFloat(PIXEL1_X),msql.getFloat(PIXEL1_Y),msql.getFloat(PIXEL1_Z)));
               el.setPixelPhysicalLocation(2,new PVector(msql.getFloat(PIXEL2_X),msql.getFloat(PIXEL2_Y),msql.getFloat(PIXEL2_Z)));
               el.setPixelPhysicalLocation(3,new PVector(msql.getFloat(PIXEL3_X),msql.getFloat(PIXEL3_Y),msql.getFloat(PIXEL3_Z)));
               el.setPixelPhysicalLocation(4,new PVector(msql.getFloat(PIXEL4_X),msql.getFloat(PIXEL4_Y),msql.getFloat(PIXEL4_Z)));
               //TODO: Add Confidence once algorithm complete
            }
      }
     }
    //return el; 
   }
   
   public void updateCachedElementRotation(AntennaElement el){
     if(isConnected){
      if(elementRotationExists(el.getID())){
         String element = "SELECT * FROM "+ELEMENTROTATIONS;
            msql.query(element);
            while(msql.next()){
               el.setYaw((short)msql.getInt(YAW));
               el.setPitch((short)msql.getInt(PITCH));
               el.setRoll((short)msql.getInt(ROLL));
            }
      }
     }
     
     //return el;
   }
    
    
    
}
