#include <SdFat.h>

#define MAX_FILE_LEN 13
#define MAX_FILES 100

SdFat sd;
File fs;
char filename[MAX_FILE_LEN];

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

  if(!sd.begin(10)){
    while(1);
  }

  int i = 0;
  while (i < MAX_FILES) { // iterate until we find a file that still hasn't been written
    char tryfilename[MAX_FILE_LEN];
    char num[4];
    itoa(i, num, 10); // convert the file number to a C string/char array
    strcpy(tryfilename, "flight");
    strcat(tryfilename, num);
    strcat(tryfilename, ".txt"); // punch in flightXX.aiu via C string  operations
    if (!sd.exists(tryfilename)) { // if the file is available...
      strcpy(filename, tryfilename); // make it official
      break; // we're done here
    }
    i++;
  }
  pinMode(A0, OUTPUT);
  digitalWrite(A0, LOW);
//  fs =  sd.open(filename, FILE_WRITE);
}

void loop() {
  // put your main code here, to run repeatedly:
  //int a = 1;
  //writeBytes(a);
  //Serial.write(a);
  //while(true);
  //delay(500);
  
  while(!Serial.available());
  
  digitalWrite(A0, HIGH);
  
  Serial.write('p');
  delay(500);
  
  
  char previousFilename[MAX_FILE_LEN];  
  int i = 0;
  while(i < MAX_FILES) { // iterate until we find a file that still hasn't been written
    char tryfilename[MAX_FILE_LEN];
    char num[4];
    itoa(i, num, 10); // convert the file number to a C string/char array
    strcpy(tryfilename, "flight");
    strcat(tryfilename, num);
    strcat(tryfilename, ".txt"); // punch in flightXX.aiu via C string operations 
    
    if (!sd.exists(tryfilename)) { // if the file is available...
      
     // strcpy(filename,tryfilename); // make it official
      break; // we're done here
    }
    i++;
    strcpy(previousFilename,tryfilename); 
  }
  //Serial.println(filename);
  File fs2 = sd.open(previousFilename, FILE_READ);
  emptySerial();
  //Serial.write(previousFilename, MAX_FILE_LEN);
  uint32_t fsize = fs2.size();
  writeBytes(fsize);
  //writeBytes(123.45f);
  for(int i = 0; i < fsize / 4; i++){
    //fs2.seek(i * 4);
    char* buffer = new char[4];
    fs2.readBytes(buffer, 4);
    float out = *((float*) buffer);
    writeBytes(out);
    //Serial.println(out);
  }
   digitalWrite(A0, LOW);
  //Serial.flush();
  fs2.close();
  while(1);
}

void emptySerial(){
  while(Serial.available() > 0) {
    char t = Serial.read();
  }
}

template <typename TYPE>
void writeBytes(TYPE data){
  const char* bytes = (const char*) &data;
  Serial.write(bytes, sizeof(TYPE));
}
