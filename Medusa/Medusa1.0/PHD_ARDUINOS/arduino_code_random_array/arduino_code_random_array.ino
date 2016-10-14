#include "MeetAndroid.h"
#include <math.h>


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
float coords_phi[antennaNumber];
float calcPhi;
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
  //Serial1.begin(115200); //for bluetooth module
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
  
  /****************
  Pre 6/11 Coords:
  ****************/
  // //board layer 1
  // coords_x[0] = 0.0; coords_y[0] = 0.0; coords_z[0] = 0.0; //1
  // coords_x[1] = -0.31091; coords_y[1] = -0.90674; coords_z[1] = 0.850503; //2
  // coords_x[2] = -0.42021; coords_y[2] = 1.53768; coords_z[2] = 1.261593; //3
  // coords_x[3] = -1.25923; coords_y[3] = 1.57854; coords_z[3] = 0.2317; //4
  // coords_x[4] = 0.987; coords_y[4] = -0.780; coords_z[4] = -0.6775; //5
  // coords_x[5] = -0.7205; coords_y[5] = -2.400; coords_z[5] = 0.97; //6
  // coords_x[6] = -1.586; coords_y[6] = -1.63112; coords_z[6] = -0.199; //7
  // coords_x[7] = -2.50266; coords_y[7] = 0.754877; coords_z[7] = -0.6202; //8
  
  // //board layer 2
  // coords_x[8] = -1.7165; coords_y[8] = -0.0445; coords_z[8] = 0.1329; //9
  // coords_x[9] = 0.3309; coords_y[9] = 0.3287; coords_z[9] = 2.529; //10
  // coords_x[10] = -1.995; coords_y[10] = 0.9757; coords_z[10] = 1.318; //11
  // coords_x[11] = 0.086; coords_y[11] = 0.5452; coords_z[11] = 1.9161; //12
  // coords_x[12] = 1.0707; coords_y[12] = -1.7958; coords_z[12] = -1.308; //13
  // coords_x[13] = -2.366; coords_y[13] = 0.272; coords_z[13] = 0.136341; //14
  // coords_x[14] = -0.992; coords_y[14] = 0.19829; coords_z[14] = -2.056; //15
  // coords_x[15] = 1.6251; coords_y[15] = -1.3179; coords_z[15] = 1.0944; //16
  
  // //board layer 3
  // coords_x[16] = -1.24; coords_y[16] = -0.64; coords_z[16] = 0.4714; //17
  // coords_x[17] = -0.8712; coords_y[17] = 1.0842; coords_z[17] = 1.4198; //18
  // coords_x[18] = 0.5503; coords_y[18] = 0.02559; coords_z[18] = 1.24; //19
  // coords_x[19] = 0.9448; coords_y[19] = 0.891; coords_z[19] = 2.1796; //20
  // coords_x[20] = 2.556; coords_y[20] = 0.4037; coords_z[20] = -0.476; //21
  // coords_x[21] = 0.424; coords_y[21] = -0.96; coords_z[21] = -2.385; //22
  // coords_x[22] = 1.617; coords_y[22] = -0.38375; coords_z[22] = 0.136; //23
  // coords_x[23] = -0.888; coords_y[23] = 1.8132; coords_z[23] = -1.4546; //24
  
  // //board layer 4
  // coords_x[24] = 0.4549; coords_y[24] = 1.361; coords_z[24] = -0.9742; //25
  // coords_x[25] = -0.9459; coords_y[25] = -1.436; coords_z[25] = -0.6393; //26
  // coords_x[26] = 0.7666; coords_y[26] = 0.4671; coords_z[26] = -1.231; //27
  // coords_x[27] = -1.116; coords_y[27] = 0.693; coords_z[27] = 0.7489; //28
  // coords_x[28] = 1.8265; coords_y[28] = 1.04089; coords_z[28] = 1.2041; //29
  // coords_x[29] = -0.03312; coords_y[29] = -2.395; coords_z[29] = 0.2082; //30
  // coords_x[30] = -0.00847; coords_y[30] = 2.0107; coords_z[30] = -0.688; //31
  // coords_x[31] = 1.4055; coords_y[31] = -1.096; coords_z[31] = 1.58566; //32
  
  
  /****************
  6/11 Remeasured X Coords:
  ****************/
//   //board layer 1
//  coords_x[0] = 0.0; coords_y[0] = 0.0; coords_z[0] = 0.0; //1
//  coords_x[1] = -0.3694; coords_y[1] = -1.0917; coords_z[1] = 0.9029; //2
//  coords_x[2] = -0.4268; coords_y[2] = 1.2969; coords_z[2] = 1.3461; //3
//  coords_x[3] = -1.2066; coords_y[3] = 1.4446; coords_z[3] = 0.2627; //4
//  coords_x[4] = 1.0178; coords_y[4] = -0.9029; coords_z[4] = -0.7223; //5
//  coords_x[5] = -0.7552; coords_y[5] = -2.4543; coords_z[5] = 1.0342; //6
//  coords_x[6] = -1.5842; coords_y[6] = -1.8386; coords_z[6] = -0.1395; //7
//  coords_x[7] = -2.3886; coords_y[7] = 0.6156; coords_z[7] = -0.5910; //8
//  
//  //board layer 2
//  coords_x[8] = -1.7730; coords_y[8] = -0.1970; coords_z[8] = 0.1477; //9
//  coords_x[9] = 0.2627; coords_y[9] = 0.2052; coords_z[9] = 2.643; //10
//  coords_x[10] = -1.8879; coords_y[10] = 0.7059; coords_z[10] = 1.379; //11
//  coords_x[11] = 0.1231; coords_y[11] = 0.4843; coords_z[11] = 1.9782; //12
//  coords_x[12] = 1.1081; coords_y[12] = -1.9371; coords_z[12] = -1.3544; //13
//  coords_x[13] = -2.3558; coords_y[13] = 0.1888; coords_z[13] = 0.156; //14
//  coords_x[14] = -0.9439; coords_y[14] = 0.0985; coords_z[14] = -2.167; //15
//  coords_x[15] = 1.6663; coords_y[15] = -1.379; coords_z[15] = 1.1409; //16
//  
//  //board layer 3
//  coords_x[16] = -1.2066; coords_y[16] = -0.8865; coords_z[16] = 0.5253; //17
//  coords_x[17] = -0.9193; coords_y[17] = 0.9604; coords_z[17] = 1.4857; //18
//  coords_x[18] = 0.4104; coords_y[18] = -0.0657; coords_z[18] = 2.1423; //19
//  coords_x[19] = 0.8947; coords_y[19] = 0.9686; coords_z[19] = 2.1916; //20
//  coords_x[20] = 2.6513; coords_y[20] = 0.3037; coords_z[20] = -0.4925; //21
//  coords_x[21] = 0.4679; coords_y[21] = -1.1245; coords_z[21] = -2.4296; //22
//  coords_x[22] = 1.6006; coords_y[22] = -0.5007; coords_z[22] = 0.1477; //23
//  coords_x[23] = -0.8783; coords_y[23] = 1.7566; coords_z[23] = -1.4939; //24
//  
//  //board layer 4
//  coords_x[24] = 0.5253; coords_y[24] = 1.3544; coords_z[24] = -1.0178; //25
//  coords_x[25] = -0.8947; coords_y[25] = -1.617; coords_z[25] = -0.5992; //26
//  coords_x[26] = 0.8372; coords_y[26] = 0.3694; coords_z[26] = -1.2969; //27
//  coords_x[27] = -1.1738; coords_y[27] = 0.6484; coords_z[27] = 0.7798; //28
//  coords_x[28] = 1.8058; coords_y[28] = 1.0014; coords_z[28] = 1.2312; //29
//  coords_x[29] = -0.0985; coords_y[29] = -2.5035; coords_z[29] = 0.238; //30
//  coords_x[30] = 0.0246; coords_y[30] = 1.9207; coords_z[30] = -0.7141; //31
//  coords_x[31] = 1.3708; coords_y[31] = -1.1984; coords_z[31] = 1.6581; //32
  
  
  /************
  Circular Planar Array Coordinates
  ************/
//   //board layer 1
//  coords_x[0] = 0.0; coords_z[0] = 2.2244; coords_y[0] = 0.0903; //1
//  coords_x[1] = 0.0; coords_z[1] = 1.7401; coords_y[1] = 0.9029; //2
//  coords_x[2] = 0.0; coords_z[2] = 1.0424; coords_y[2] = 1.9289; //3
//  coords_x[3] = 0.0; coords_z[3] = 0.4350; coords_y[3] = 1.4446; //4
//  coords_x[4] = 0.0; coords_z[4] = 1.7483; coords_y[4] = -1.1245; //5
//  coords_x[5] = 0.0; coords_z[5] = 1.4693; coords_y[5] = -1.7155; //6
//  coords_x[6] = 0.0; coords_z[6] = 0.7798; coords_y[6] = -1.9207; //7
//  coords_x[7] = 0.0; coords_z[7] = 0.1724; coords_y[7] = -2.2819; //8
//  
//  //board layer 2
//  coords_x[8] = 0.0; coords_z[8] = 1.4693; coords_y[8] = -0.3365; //9
//  coords_x[9] = 0.0; coords_z[9] = 0.8701; coords_y[9] = -0.5089; //10
//  coords_x[10] = 0.0; coords_z[10] = 0.7880; coords_y[10] = -1.0589; //11
//  coords_x[11] = 0.0; coords_z[11] = 0.2627; coords_y[11] = -0.3447; //12
//  coords_x[12] = 0.0; coords_z[12] = 1.5842; coords_y[12] = 0.3612; //13
//  coords_x[13] = 0.0; coords_z[13] = 1.0424; coords_y[13] = 0.5828; //14
//  coords_x[14] = 0.0; coords_z[14] = 0.5007; coords_y[14] = 0.1724; //15
//  coords_x[15] = 0.0; coords_z[15] = 0.4350; coords_y[15] = 0.6813; //16
//  
//  //board layer 3
//  coords_x[16] = 0.0; coords_z[16] = -0.3201; coords_y[16] = 1.2887; //17
//  coords_x[17] = 0.0; coords_z[17] = -0.3612; coords_y[17] = 0.8126; //18
//  coords_x[18] = 0.0; coords_z[18] = -0.3776; coords_y[18] = 0.1477; //19
//  coords_x[19] = 0.0; coords_z[19] = -0.9932; coords_y[19] = 0.2627; //20
//  coords_x[20] = 0.0; coords_z[20] = 0.0821; coords_y[20] = -1.2230; //21
//  coords_x[21] = 0.0; coords_z[21] = -0.8537; coords_y[21] = -0.9686; //22
//  coords_x[22] = 0.0; coords_z[22] = -0.4104; coords_y[22] = -0.4186; //23
//  coords_x[23] = 0.0; coords_z[23] = -0.9193; coords_y[23] = -0.3037; //24
//  
//  //board layer 4
//  coords_x[24] = 0.0; coords_z[24] = -0.2462; coords_y[24] = 1.9371; //25
//  coords_x[25] = 0.0; coords_z[25] = -0.9275; coords_y[25] = 1.5514; //26
//  coords_x[26] = 0.0; coords_z[26] = -1.1327; coords_y[26] = 0.9686; //27
//  coords_x[27] = 0.0; coords_z[27] = -1.7812; coords_y[27] = 0.6813; //28
//  coords_x[28] = 0.0; coords_z[28] = -0.7223; coords_y[28] = -1.6581; //29
//  coords_x[29] = 0.0; coords_z[29] = -1.6581; coords_y[29] = -1.0507; //30
//  coords_x[30] = 0.0; coords_z[30] = -1.4529; coords_y[30] = -0.3447; //31
//  coords_x[31] = 0.0; coords_z[31] = -2.1423; coords_y[31] = 0.0082; //32


///************
//  Monopole Random Array Coordinates
//  ************/
//   //board layer 1
//  coords_x[0] = -1.5431; coords_z[0] = 1.0096; coords_y[0] = -1.3461; //1
//  coords_x[1] = -1.2230; coords_z[1] = -0.8783; coords_y[1] = 1.4939; //2
//  coords_x[2] = 0.8044; coords_z[2] = -1.7976; coords_y[2] = 0.0410; //3
//  coords_x[3] = -1.4857; coords_z[3] = 1.4611; coords_y[3] = 0.3940; //4
//  coords_x[4] = -0.5992; coords_z[4] = 0.2298; coords_y[4] = -1.6581; //5
//  coords_x[5] = -2.5281; coords_z[5] = -0.0328; coords_y[5] = -0.7716; //6
//  coords_x[6] = -0.1642; coords_z[6] = 1.4611; coords_y[6] = 2.2408; //7
//  coords_x[7] = 1.6252; coords_z[7] = -0.9029; coords_y[7] = 1.7483; //8
//  
//  //board layer 2
//  coords_x[8] = -1.1245; coords_z[8] = 0.5089; coords_y[8] = 0.0410; //9
//  coords_x[9] = -1.5103; coords_z[9] = 1.9289; coords_y[9] = -0.2216; //10
//  coords_x[10] = 1.4200; coords_z[10] = 1.1163; coords_y[10] = -0.1149; //11
//  coords_x[11] = -0.6567; coords_z[11] = -2.3640; coords_y[11] = -0.1149; //12
//  coords_x[12] = -0.4761; coords_z[12] = -1.3297; coords_y[12] = 1.4364; //13
//  coords_x[13] = -1.3544; coords_z[13] = -0.2873; coords_y[13] = -2.1177; //14
//  coords_x[14] = -0.5910; coords_z[14] = -1.0507; coords_y[14] = 0.5007; //15
//  coords_x[15] = 2.0274; coords_z[15] = 0.0164; coords_y[15] = 0.7634; //16
//  
//  //board layer 3
//  coords_x[16] = 0.4104; coords_z[16] = 2.6759; coords_y[16] = -0.3530; //17
//  coords_x[17] = 1.6663; coords_z[17] = -1.5185; coords_y[17] = -1.1327; //18
//  coords_x[18] = 2.1998; coords_z[18] = 0.6567; coords_y[18] = 0.1231; //19
//  coords_x[19] = 0.2873; coords_z[19] = -0.9029; coords_y[19] = 1.5924; //20
//  coords_x[20] = -2.0110; coords_z[20] = 0.6320; coords_y[20] = -0.7469; //21
//  coords_x[21] = -1.3379; coords_z[21] = -0.3776; coords_y[21] = 2.2901; //22
//  coords_x[22] = -0.1395; coords_z[22] = -2.6595; coords_y[22] = 0.8044; //23
//  coords_x[23] = 2.1916; coords_z[23] = -0.0575; coords_y[23] = -0.2873; //24
//  
//  //board layer 4
//  coords_x[24] = 0.4679; coords_z[24] = -0.5910; coords_y[24] = 0.8947; //25
//  coords_x[25] = -2.2244; coords_z[25] = 0.0903; coords_y[25] = 1.0014; //26
//  coords_x[26] = 1.4857; coords_z[26] = 1.8551; coords_y[26] = 0.9850; //27
//  coords_x[27] = -0.788; coords_z[27] = -0.1806; coords_y[27] = -0.8947; //28
//  coords_x[28] = 0.7798; coords_z[28] = -0.6567; coords_y[28] = -0.9932; //29
//  coords_x[29] = 0.3694; coords_z[29] = -0.0492; coords_y[29] = -1.4939; //30
//  coords_x[30] = -0.0739; coords_z[30] = 0.9522; coords_y[30] = -1.8140; //31
//  coords_x[31] = 1.2805; coords_z[31] = -1.0753; coords_y[31] = -0.6156; //32

/************
  UCA Monopole Coordinates 12/8/2014
  ************/
//   //board layer 1
//  coords_x[12] = 2.8044; coords_z[0] = 0.0; coords_y[12] = 0.0; //1
//  coords_x[13] = 2.6353; coords_z[1] = 0.0; coords_y[13] = 0.9592; //2
//  coords_x[14] = 2.1483; coords_z[2] = 0.0; coords_y[14] = 1.8026; //3
//  coords_x[15] = 1.4022; coords_z[3] = 0.0; coords_y[15] = 2.4287; //4
//  coords_x[16] = 0.4870; coords_z[4] = 0.0; coords_y[16] = 2.7618; //5
//  coords_x[17] = -0.4870; coords_z[5] = 0.0; coords_y[17] = 2.7618; //6
//  coords_x[0] = -1.4022; coords_z[6] = 0.0; coords_y[0] = 2.4287; //7
//  coords_x[1] = -2.1483; coords_z[7] = 0.0; coords_y[1] = 1.8026; //8
//  
//  //board layer 2
//  coords_x[2] = -2.6353; coords_z[8] = 0.0; coords_y[2] = 0.9592; //9
//  coords_x[3] = -2.8044; coords_z[9] = 0.0; coords_y[3] = 0.0; //10
//  coords_x[4] = -2.6353; coords_z[10] = 0.0; coords_y[4] = -0.9592; //11
//  coords_x[5] = -2.1483; coords_z[11] = 0.0; coords_y[5] = -1.8026; //12
//  coords_x[6] = -1.4022; coords_z[12] = 0.0; coords_y[6] = -2.4287; //13
//  coords_x[7] = -0.4870; coords_z[13] = 0.0; coords_y[7] = -2.7618; //14
//  coords_x[8] = 0.4870; coords_z[14] = 0.0; coords_y[8] = -2.7618; //15
//  coords_x[9] = 1.4022; coords_z[15] = 0.0; coords_y[9] = -2.4287; //16
//  
//  //board layer 3
//  coords_x[10] = 2.1483; coords_z[16] = 0.0; coords_y[10] = -1.8026; //17
//  coords_x[11] = 2.6353; coords_z[17] = 0.0; coords_y[11] = -0.9592; //18
  
  /************
  Linear Monopole Coordinates 12/9/2014
  ************/
   //board layer 1
  coords_x[0] = 0.0; coords_z[0] = 0.0; coords_y[0] = 0.0; //1
  coords_x[1] = 0.0; coords_z[1] = 0.0; coords_y[1] = 0.0; //2
  coords_x[2] = 0.0; coords_z[2] = 0.0; coords_y[2] = 0.0; //3
  coords_x[3] = 0.0; coords_z[3] = 0.0; coords_y[3] = 0.0; //4
  coords_x[4] = 0.0; coords_z[4] = 0.0; coords_y[4] = 0.0; //5
  coords_x[5] = 0.0; coords_z[5] = 0.0; coords_y[5] = 0.0; //6
  coords_x[6] = 0.0; coords_z[6] = 0.0; coords_y[6] = 0.0; //7
 
  
 for(int i =0; i < antennaNumber; ++i){
  coords_phi[i] = (float) 180/PI*atan2(coords_y[i],coords_x[i]); 
  //Serial.print("PHI: ");Serial.println(coords_phi[i]);
 }
  
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

void printCoords(){
for(int i = 0; i<antennaNumber;++i){
      Serial.print("ANT: ");Serial.print(i+1);Serial.print(" X: ");Serial.print(coords_x[i]);Serial.print(" Y: ");Serial.print(coords_y[i]);Serial.print(" Z: ");Serial.print(coords_z[i]);Serial.print(" Ph: ");Serial.println(phases[i]);
    }
}

void printCurrentPhaseOffsets(){
   Serial.print("Kx: ");Serial.print(float_x);Serial.print(" Ky: ");Serial.print(float_y);Serial.print(" Kz: ");Serial.println(float_z); 
}

void testEvent(byte flag, byte numOfValues){
  
  //if (Serial1.available() > 0) {
    // read the oldest byte in the serial buffer:
   // float data[numOfValues];
   //  meetAndroid.getFloatValues(data);
   incomingByte = meetAndroid.getInt();
    //float data[numOfValues];
   //meetAndroid.getFloatValues(data);
   //Serial.print(count);Serial.println(",");
     //incomingByte = Serial1.read();
     
     //Serial.println(incomingByte);
    if((incomingByte == 255) && (count == 0)){ // Look for startbyte
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
                   Serial.println("ARDUINO: Working dynamic coords");
                   init_values();
                   return;
                }
                if(frametype == 98){
                   dynamic_coords = false;
                   clear_coords();
                   init_values();
                   return;
                }
                if(frametype == 97){
                   printCoords();
                   init_values();
                   return;
                }
                if(frametype == 96){
                  printCurrentPhaseOffsets();
                  init_values();
                  return;
                }
                if((frametype >= 201) && (frametype <= 232)){
                  //Serial.println("ARDUINO MADE IT");
                    int ref = frametype - 201;
                    coords_x[ref] = (float)payload[0]/100;
                    coords_y[ref] = (float)payload[1]/100;
                    coords_z[ref] = (float)payload[2]/100;
                    //Serial.print((int)ref);Serial.print(",");Serial.print((int)coords_y[ref]);Serial.print("\n");
                    init_values();
                    return;
                }else{
                  incomingByte=payload[0]; //reuse memory variables
                  y=payload[1];
                  z = payload[2];
               
                  // if(y >=128){		// What is going on here?!?
                    // y = y-256;
                  // }
                  // if(z >= 128){
                    // z -= 256;
                  // }
                  // if(incomingByte>=128){
                    // incomingByte = incomingByte-256;
                  // }
                }
			// fl_x = -180/pi * pi * sin(theta) * cos(phi)
			// fl_y = -180/pi * pi * sin(theta) * sin(phi)
			// fl_z = -180/pi * pi * cos(theta)
          float_x=(float)incomingByte*-1;  //we are going to have no negative phase shifts in time...
          float_y=(float)y*-1;
          float_z=(float)z*-1;
          Serial.print("X: ");Serial.print(float_x);Serial.print("  ");Serial.print("Y: ");Serial.print(float_y);Serial.print("  ");Serial.print("Z: ");Serial.print(float_z);Serial.print("\n");
          int total;
 
  // This runs (we don't have dynamic coordinates)
  // Calculates space phase shifts relative to 0,0,0 (negative phase = further away from target antenna, positive phase =  closer)
  if((!dynamic_coords) && (frametype==200)){
    
    for(int i = 0; i<antennaNumber;++i){
      float temp44 = 2.0*coords_z[i]*float_z;
      //Serial.print("PHASE ");Serial.print(i); Serial.print(" ");Serial.println(temp44);      
     phases[i] = 2.0*coords_x[i]*float_x + 2.0*coords_y[i]*float_y + 2.0*coords_z[i]*float_z; 
    }
  }
  
  //Calculate the steering angle, calcPhi, assuming theta=90
  calcPhi = 180/PI*atan(float_y/float_x);
  
  // float phaseOffsets[32] = {-80.85,-68.14,-88.92,-113.49,-62.38,-75.16,-96.27,-79.78,-104.54,-76.97,-81.77,-88.16,-81.52,-86.25,-72.42,-90.13,-143.47,0,-68.71,-103.18,-80.15,-52.72,-58.9,-17.16,-61.64,-55.39,-89.77,-76.46,-104.46,-147.11,-28.89,-108.19};
  
  // Power splitter & cabling phase offsets (measured 6/10/14-6/11/14)
  float phaseOffsets[32] = {-80.445,-68.64,-89.46,-113.965,-63.195,-75.025,-96.655,-78.85,-103.74,-77.09,-81.38,-88.495,-80.955,-86.005,-72.89,-90.735,-144.59,0,-70.145,-102.45,-79.79,-52.685,-59.135,-17.73,-62.305,-55.835,-89.78,-77.11,-104.62,-97.525,-31.26,-107.945};
  
  
  
  // DOESN'T RUN (not dynamic coords)
  if((dynamic_coords) && (frametype == 200)){
    Serial.println("Dynamic coords written");
       for(int i=0; i<antennaNumber; ++i){
        phases[i] = (float_x*coords_x[i])*2 + (float_y*coords_y[i])*2 + 2.0*coords_z[i]*float_z;
       }
  }
  
  // Calculate total phase offset (space phase + splitter network phase)
  for(int i = 0; i<antennaNumber;++i){
	phases[i] += phaseOffsets[i];
  }
 
//   amin = phases[0];
//   int minPhaseElement;
//   for(int i=0;i<antennaNumber;++i){
//     if(phases[i] < amin){
//         amin = phases[i];
//         minPhaseElement = i;
//     }
//   }
//   Serial.print("amin: "); Serial.print(amin);Serial.print("Element: "); Serial.print(minPhaseElement);Serial.print("\n");
   //amin*=-1;
  
  // Find most positive phase (electrically closest element to front)
  float amax = phases[0];
  for(int i=0;i<antennaNumber;++i){
    if(phases[i] > amax){
        amax = phases[i];
    }
  }
  
  for(int i=0;i<antennaNumber;++i){
	// Normalize total phase shifts to closest element (furthest forward/most positive phase shift)
	// Gives us phase offsets in: phase offsets + phase shifter phase = 0
    phases[i]-=amax;
    //phases[i]+=amin;
	
	// phase shifter phase = -phase offset
	phases[i] *= -1.0;
	
	  /*************
	  SUM/DIFFERENCE HERE
	  *************/
        //Uncomment for Simple Difference Pattern
       
        /*if(coords_z[i] <= 13.6){   //Split at y = -0.1167 for 16/16 split
          phases[i] += 180.0;
        }*/
        
        //Uncomment for Advanced Difference Pattern
        /*
        if( fmod(coords_phi[i]+360,360)>fmod(calcPhi+360,180) && fmod(coords_phi[i]+360,360)<fmod(calcPhi+360,180)+180 ){
          phases[i] += 180;
        }
        */
	
        // Modulo 360 degrees
	phases[i] = fmod(phases[i],360.0);
	
	// Common offset to ensure phase shifters run in +90 - +450 degree range (1.22V and up)
	// HMC928LP5E are more linear above 1.22V
	phases[i] += 90.0;
  }
  
  

  
  
  /*************
  HARDCODED PHASE SHIFTS BELOW
  *************/
  // Current as of 6/10, 14:20:
  //float newphases[32] = {302.42,201.13,78.35,125.48,30.89,131.61,45,131.49,337.73,42,223.5,324.11,42.75,146.02,34.85,202.64,102.8,110.27,116.56,198.09,184.12,239.55,200.37,115.61,135.13,35.88,221.5,263.81,171.81,236.66,308.88,74.08};

  // Sum Pattern - Current as of 6/11, 18:20:
  // float newphases[32] = {331.0780309,86.14140982,126.696491,419.0347354,324.2351645,225.0333834,171.4124116,69.8985479,243.3412497,237.505517,260.451412,296.8385713,310.9828941,65.77635867,287.7422215,129.0506771,89.65973537,206.3943295,179.8131654,405.7796242,139.79,142.6180843,120.0050556,210.027843,132.5030031,253.7714376,412.8447054,370.9025461,95.00762286,381.9895986,273.435139,247.7553802};

  // Difference Pattern -  Current as of 6/11, 19:40:
  // float newphases[32] = {331.0780309,266.1414098,126.696491,419.0347354,144.2351645,405.0333834,351.4124116,69.8985479,63.34124971,237.505517,260.451412,296.8385713,130.9828941,65.77635867,287.7422215,309.0506771,269.6597354,206.3943295,179.8131654,405.7796242,139.79,322.6180843,300.0050556,210.027843,132.5030031,73.77143761,412.8447054,370.9025461,95.00762286,201.9895986,273.435139,67.75538025};

 for(int i = 0; i<antennaNumber;++i){
    //Serial.print("Phase ");Serial.print(i);Serial.print(": ");Serial.println(phases[i]); 
    Serial.print("PHASE ");Serial.print(i);Serial.print(" ");Serial.println(phases[i]);
    
    
    //int volt = getvoltage((int) newphases[i],i);  // For hardcoded phases in a newphases[]
    int volt = getvoltage((int) phases[i],i);	// For calculated phases in phases[] from above

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

/************************************
 MANUAL VOLTAGE OVERRIDE:
 ************************************/
 //temp = 1.2;

 // temp /= 2.5; //gain associated on board
 // temp /= 0.001; //how many millivolts
 // temp /= 4980.0; //supply voltage
 // temp *= intMax;  //normailze to 16 bit i.e. 65535
 
    temp *=  5300.0; // DAC Word / Voltage (LSB/volt) from Nick
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
