#include <MeetAndroid.h>


const int ledPin = 13; // the pin that the LED is attached to
int incomingByte;      // a variable to read incoming serial data into
const int _sck = 4;
const int _sdi = 5;
const int ctl = 10; //board layer 1 activate, each other layer must have a jumper from the pin to pin 10 to create multi layered board
const int ldac = 9;
const int counter = 2;
const int ctl4 = 11; //board layer 4 activate
const int clearpin = 8;
const int ctl2 = 7; //board layer 2 activate
const int ctl3 = 6; //board layer 3 activate
const unsigned int intMax = 0xFFFF;

int startbyte,length,frameid,frametype;
int *payload = (int *)calloc(2,sizeof(int));
int *frame = (int *)calloc(6,sizeof(int));
const int antennaNumber = 32; //may need to change for different configurations, for now, just support max value
float float_y,float_x,float_z,bright1,bright2,bright3,bright4,bright5,bright6,bright7,bright8;
float phases[antennaNumber];
float coords_x[antennaNumber];
float coords_y[antennaNumber];
float coords_z[antennaNumber];
int y,z;
int count = 0;
int checksum = 0;
int payloadcount = 0;
float amin;
boolean dynamic_coords = false;

MeetAndroid meetAndroid;

int comm1 = 0x03F0;
  int comm2 = 0x0000;

void init_values(){
    startbyte = 0;
     length = 0;
     frameid = 0;
     frametype = 0;
     count = 0;
     payloadcount = 0;
     checksum = 0;
    
}

void clear_coords(){
    for(int i=0;i<antennaNumber;++i){
        coords_x[i] = 0;
        coords_y[i] = 0;
        coords_z[i] = 0;
        phases[i] = 0;  
     }
}

void setup() {
  // initialize serial communication:
  Serial.begin(9600); //for computer
  Serial1.begin(115200); //for bluetooth module
  // initialize the LED pin as an output:
  pinMode(ctl, OUTPUT);
  pinMode(_sck, OUTPUT);
  pinMode(_sdi, OUTPUT);
  pinMode(ldac,OUTPUT);

  pinMode(clearpin, OUTPUT);
  pinMode(ctl2, OUTPUT);
  digitalWrite(ctl3, OUTPUT);
  digitalWrite(ctl4, OUTPUT);
  
  digitalWrite(clearpin, HIGH);
  
   init_values();
  clear_coords();
  
  /*for(int i = 0; i < antennaNumber; ++i){
    if((i >= 0) && (i <=3)){
   coords_x[i] = 0.5*0; //phased array for now
   coords_y[i] = 0.5*0;
   coords_z[i] = 0.5*0; 
    }else if((i >= 4) && (i <=7)){
   coords_x[i] = 0.5*1; //phased array for now
   coords_y[i] = 0.5*1; 
   coords_z[i] = 0.5*1; 
    }else if((i >= 8) && (i <=11)){
   coords_x[i] = 0.5*2; //phased array for now
   coords_y[i] = 0.5*2; 
   coords_z[i] = 0.5*2; 
    }else if((i >= 12) && (i <=15)){
   coords_x[i] = 0.5*3; //phased array for now
   coords_y[i] = 0.5*3; 
   coords_z[i] = 0.5*3; 
    }else{
   coords_x[i] = 0.5*i; //phased array for now
   coords_y[i] = 0.5*i;
   coords_z[i] = 0.5*i;  
    }
  }*/
  
  //board layer 1
  coords_x[0] = 0.0; coords_y[0] = 0.0; coords_z[0] = 0.0; //1
  coords_x[1] = -0.31091; coords_y[1] = -0.90674; coords_z[1] = 0.850503; //2
  coords_x[2] = -0.42021; coords_y[2] = 1.53768; coords_z[2] = 1.261593; //3
  coords_x[3] = -1.25923; coords_y[3] = 1.57854; coords_z[3] = 0.2317; //4
  coords_x[4] = 0.987; coords_y[4] = -0.780; coords_z[4] = -0.6775; //5
  coords_x[5] = -0.7205; coords_y[5] = -2.400; coords_z[5] = 0.97; //6
  coords_x[6] = -1.586; coords_y[6] = -1.63112; coords_z[6] = -0.199; //7
  coords_x[7] = -2.50266; coords_y[7] = 0.754877; coords_z[7] = -0.6202; //8
  
  //board layer 2
  coords_x[8] = -1.7165; coords_y[8] = -0.0445; coords_z[8] = 0.1329; //9
  coords_x[9] = 0.3309; coords_y[9] = 0.3287; coords_z[9] = 2.529; //10
  coords_x[10] = -1.995; coords_y[10] = 0.9757; coords_z[10] = 1.318; //11
  coords_x[11] = 0.086; coords_y[11] = 0.5452; coords_z[11] = 1.9161; //12
  coords_x[12] = 1.0707; coords_y[12] = -1.7958; coords_z[12] = -1.308; //13
  coords_x[13] = -2.366; coords_y[13] = 0.272; coords_z[13] = 0.136341; //14
  coords_x[14] = -0.992; coords_y[14] = 0.19829; coords_z[14] = -2.056; //15
  coords_x[15] = 1.6251; coords_y[15] = -1.3179; coords_z[15] = 1.0944; //16
  
  //board layer 3
  coords_x[16] = -1.24; coords_y[16] = -0.64; coords_z[16] = 0.4714; //17
  coords_x[17] = -0.8712; coords_y[17] = 1.0842; coords_z[17] = 1.4198; //18
  coords_x[18] = 0.5503; coords_y[18] = 0.02559; coords_z[18] = 1.24; //19
  coords_x[19] = 0.9448; coords_y[19] = 0.891; coords_z[19] = 2.1796; //20
  coords_x[20] = 2.556; coords_y[20] = 0.4037; coords_z[20] = -0.476; //21
  coords_x[21] = 0.424; coords_y[21] = -0.96; coords_z[21] = -2.385; //22
  coords_x[22] = 1.617; coords_y[22] = -0.38375; coords_z[22] = 0.136; //23
  coords_x[23] = -0.888; coords_y[23] = 1.8132; coords_z[23] = -1.4546; //24
  
  //board layer 4
  coords_x[24] = 0.4549; coords_y[24] = 1.361; coords_z[24] = -0.9742; //25
  coords_x[25] = -0.9459; coords_y[25] = -1.436; coords_z[25] = -0.6393; //26
  coords_x[26] = 0.7666; coords_y[26] = 0.4671; coords_z[26] = -1.231; //27
  coords_x[27] = -1.116; coords_y[27] = 0.693; coords_z[27] = 0.7489; //28
  coords_x[28] = 1.8265; coords_y[28] = 1.04089; coords_z[28] = 1.2041; //29
  coords_x[29] = -0.03312; coords_y[29] = -2.395; coords_z[29] = 0.2082; //30
  coords_x[30] = -0.00847; coords_y[30] = 2.0107; coords_z[30] = -0.688; //31
  coords_x[31] = 1.4055; coords_y[31] = -1.096; coords_z[31] = 1.58566; //32
  
 
  
  digitalWrite(ctl,HIGH);
  digitalWrite(ctl2,HIGH);
  digitalWrite(ctl3, HIGH);
  digitalWrite(ctl4, HIGH);
 // SPI.setBitOrder(MSBFIRST);
  //SPI.setDataMode(SPI_MODE0);
  
  digitalWrite(_sck,HIGH);
  digitalWrite(ldac,HIGH);
 // SPI.begin();
  meetAndroid.registerFunction(testEvent, 'B');
  
}

void loop() {
  // see if there's incoming serial data:
  meetAndroid.receive();
}

void testEvent(byte flag, byte numOfValues){
  
  //if (Serial1.available() > 0) {
    // read the oldest byte in the serial buffer:
   // float data[numOfValues];
   //  meetAndroid.getFloatValues(data);
   incomingByte = meetAndroid.getInt();
    //float data[numOfValues];
   //meetAndroid.getFloatValues(data);
   //Serial.println(incomingByte);
     //incomingByte = Serial1.read();
     Serial.println(incomingByte);
    if(incomingByte == 255){ // Look for startbyte
        init_values();
        startbyte = incomingByte;
        checksum+=startbyte;
        count++;
    }else if(count == 1){ //only add to frame if you have received a startbyte
        length = incomingByte;
        checksum+=length;
        payload = (int *)realloc(payload,length);
        count++;
    }else if(count == 2){
      frametype = incomingByte;
     // frametype-=256;
      //Serial.print("\n");Serial.print("Frametype");Serial.print(frametype);Serial.print("\n");
      checksum+=frametype;
        count++;
    }else if(count == 3){
      frameid = incomingByte;
      //Serial.print(frameid);Serial.print("\n");
      checksum+=frameid;
      count++;
    }else if(count > 3){
        if(payloadcount < length){
          //Serial.println(incomingByte);
          payload[payloadcount] = incomingByte; //store payload as array
          checksum+=incomingByte;
          payloadcount++;
          count++;
        }else{
            checksum = checksum % 256;
            if(incomingByte == checksum){
                if(frametype == 99){
                   dynamic_coords = true;
                }
                if(frametype == 98){
                   dynamic_coords = false;
                   clear_coords();
                }
                if((frametype >= 201) && (frametype <= 216)){
                    int ref = frametype - 201;
                    coords_x[ref] = (float)payload[0]/100;
                    coords_y[ref] = (float)payload[1]/100;
                    //Serial.print((int)coords_incomingByte[ref]);Serial.print(",");Serial.print((int)coords_y[ref]);Serial.print("\n");
                }else{
                  incomingByte=payload[0]; //reuse memory variables
                  y=payload[1];
                  z = payload[2];
               
                  if(y >=128){
                    y = y-256;
                  }
                  if(z >= 128){
                    z -= 256;
                  }
                  if(incomingByte>=128){
                    incomingByte = incomingByte-256;
                  }
                }
          float_x=(float)incomingByte*-1;  //we are going to have no negative phase shifts in time...
          float_y=(float)y*-1;
          float_z=(float)z*-1;
          int total;
 

  if((!dynamic_coords) && (frametype==200)){
    for(int i = 0; i<antennaNumber;++i){
      float temp44 = 2.0*coords_z[i]*float_z;
      //Serial.print("PHASE ");Serial.print(i); Serial.print(" ");Serial.println(temp44);      
     phases[i] = 2.0*coords_x[i]*float_x + 2.0*coords_y[i]*float_y + 2.0*coords_z[i]*float_z; 
    }
  }
   
  if((dynamic_coords) && (frametype == 200)){
       for(int i=0; i<antennaNumber; ++i){
        phases[i] = (float_x*coords_x[i])*2 + (float_y*coords_y[i])*2 + 2.0*coords_z[i]*float_z;
       }
  }
 
  amin = phases[0];
  for(int i=0;i<antennaNumber;++i){
    if(phases[i] < amin){
        amin = phases[i];
    }
  }
  amin*=-1;
  
  for(int i=0;i<antennaNumber;++i){
      phases[i]+=amin;
      phases[i] += 90.0;
      
      //if ( (i == 28) || (i==18) || (i==21) || (i==30) || (i==27) || (i==31) || (i==29) || (i==24) || (i==25) || (i==8) || (i==7) || (i==6) || (i==1) || (i==0) || (i==11)){
       //phases[i] +=  180; 
      //}
      phases[i]-=(float)360*((int)phases[i]/360);
  }
  
  float newphases[32] = {1.914618546,138.0611255,59.36053699,175.2671617,352.5590004,203.1564342,299.4974107,0,206.0119426,240.2319371,5.453535484,64.46970579,52.8546846,97.77893497,7.051835607,92.04133855,189.1146185,94.61018814,38.17962376,322.2200145,42.38499897,307.1946185,86.1565837,82.23162518,329.505521,40.80420451,193.890056,277.8609543,236.9960512,338.0698955,355.8152947,293.9330303};


 for(int i = 0; i<antennaNumber;++i){
    //Serial.print("Phase ");Serial.print(i);Serial.print(": ");Serial.println(phases[i]); 
    Serial.print("PHASE ");Serial.print(i);Serial.print(" ");Serial.println(phases[i]);
    
    
    int volt = getvoltage((int) newphases[i],i);
     //Serial.print("Volt ");Serial.print(i);Serial.print(": ");Serial.println(volt); 
 }
            init_values();
            }else{
                Serial.print(incomingByte);Serial.print(",");Serial.print(checksum);Serial.print("\n");
             }
    }
    }  

    }
    

void writeLayer(int layer,int high, int low){
  digitalWrite(layer,LOW);
      shiftOut(_sdi, _sck, MSBFIRST, (high>>8));
      shiftOut(_sdi, _sck, MSBFIRST, high);
      shiftOut(_sdi, _sck, MSBFIRST, (low>>8));
      shiftOut(_sdi, _sck, MSBFIRST, low);
    // SPI.transfer(0x03);
     //SPI.transfer(0xFF);
     //SPI.transfer(0xFF);
     //SPI.transfer(0xF0);
     //SPI.transfer(0x03);
     //SPI.transfer(0xFF);
     //SPI.transfer(0xFF);
     //SPI.transfer(0xF0);
      digitalWrite(layer,HIGH);
      digitalWrite(ldac,LOW);
      digitalWrite(ldac,HIGH);
}
//  }


int getvoltage(int phasediff, int antennaNum){
  int returnval;
  //phasediff += 90;
  
 float temp = (.000000002*phasediff*phasediff*phasediff)+(.00003*phasediff*phasediff)+(.0118*phasediff)+.0216;
 if(0 <= temp <= 1.8){
    temp -= 0.12; 
 }
 
 if(temp >= 2.5){
  temp += .105; 
 }
unsigned int highword = 0;
unsigned int lowword = 0;
unsigned int converted = 0;
 temp /= 2.5; //gain associated on board
 temp /= 0.001; //how many millivolts
 temp /= 5011.0; //supply voltage
 temp *= intMax;  //normailze to 16 bit i.e. 65535
 converted = (int) temp;
 highword = converted >> 12; //the command bytes require that the LSB of the highword have value
 
 lowword = converted << 4; //rest of value to be written to register...
 
 
 if( (0 <= antennaNum) && (antennaNum <= 7)){
   highword += 0x0300 + antennaNum*16;
   Serial.println("C1");
     writeLayer(ctl,highword,lowword);
 }else if( (8 <= antennaNum) && (antennaNum <= 15)){
    Serial.println("C2");
    antennaNum -= 8;
   highword += 0x0300 + antennaNum*16;
     writeLayer(ctl2,highword,lowword);
 }else if( (16 <= antennaNum) && (antennaNum <= 23)){
    Serial.println("C3");
   antennaNum -= 16;
   highword += 0x0300 + antennaNum*16;
     writeLayer(ctl3,highword,lowword);
 }else if( (24 <= antennaNum) && (antennaNum <= 31)){
    Serial.println("C4");
   antennaNum -= 24;
   highword += 0x0300 + antennaNum*16;
     writeLayer(ctl4,highword,lowword);
 }
 Serial.print(temp);Serial.print("\t");Serial.print(highword,HEX);Serial.print("\t");Serial.println(lowword,HEX);
        /*temp = temp/.12;
        //Serial.println(temp);
       int lowval = (int) temp;
      float checklow = temp-.5;
      int check = (int) checklow;
           if(checklow < lowval){
               returnval = lowval;
           }else{
               //Serial.print("Made It");
               float rounding =  temp+.5;
               returnval = (int) rounding;
           }
           returnval=129-returnval;
          // Serial.println(returnval);
           //Serial.print("Return Value: ");Serial.print(returnval);Serial.print("\n");*/
           return (int) temp;
              
 
 
}

