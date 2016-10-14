
class morphingElement{
 
 public int antennaNum;
 
 public ArrayList<PVector> locations;
 public PVector cachedPos;
 
 public morphingElement(int _antennaNum){
    antennaNum = _antennaNum;
    locations = new ArrayList<PVector>();
    cachedPos = new PVector(0.0,0.0,0.0); 
 }
 
  
}
