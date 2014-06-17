#define uint  unsigned int
#define ulong unsigned long

#define PIN_ANEMOMETER  2     // Digital 2
#define PIN_RAIN  3     // Digital 3
#define PIN_VANE        5     // Analog 5

// How often we want to calculate wind speed or directio
#define MSECS_CALC       5000
#define MSECS_DB         5

ulong nextCalc;
ulong nextWindSig;
ulong nextRainSig;
volatile int numRevsAnemometer = 0; // Incremented in the interrupt
volatile int numRainDumps = 0; // Incremented in the interrupt
ulong time;                         // Millis() at each start of loop().

// ADC readings:
#define NUMDIRS 8
ulong   adc[NUMDIRS] = {26, 45, 77, 118, 161, 196, 220, 256};

// These directions match 1-for-1 with the values in adc, but
// will have to be adjusted as noted above. Modify 'dirOffset'
// to which direction is 'away' (it's West here).
char *strVals[NUMDIRS] = {"W","NW","N","SW","NE","S","SE","E"};
byte dirOffset=0;

//=======================================================
// Initialize
//=======================================================
void setup() {
   Serial.begin(9600);
   pinMode(PIN_ANEMOMETER, INPUT);
   digitalWrite(PIN_ANEMOMETER, HIGH);
   attachInterrupt(0, countAnemometer, FALLING);
   pinMode(PIN_RAIN, INPUT);
   digitalWrite(PIN_RAIN, HIGH);   
   attachInterrupt(1, countRain, FALLING );
   nextCalc   = millis() + MSECS_CALC;
   nextWindSig = millis();
   nextRainSig = millis();
}

//=======================================================
// Main loop.
//=======================================================
void loop() {
   time = millis();
   if (time >= nextCalc) {
      calcCounts();
      nextCalc = time + MSECS_CALC;
   }  
}

//=======================================================
// Interrupt handler for anemometer. Called each time the reed
// switch triggers (one revolution).
//=======================================================
void countAnemometer() {
   time = millis();
   if(time >= nextWindSig)
   {
     nextWindSig = millis() + MSECS_DB;
     numRevsAnemometer++;
     // Serial.print(".");
   }
}

void countRain() {
   time = millis();
   if(time >= nextRainSig)
   {
     nextRainSig = millis() + MSECS_DB;
     numRainDumps++;
     // Serial.print("b");
   }
}

//=======================================================
// Find vane direction.
//=======================================================
void calcCounts() {
   int val;
   byte x, reading;

   val = analogRead(PIN_VANE);
   Serial.print("dir:");
   Serial.print(val);
   Serial.print("|wind:");
   Serial.print(numRevsAnemometer);
   Serial.print("|bucket:");
   Serial.println(numRainDumps);
   
   numRevsAnemometer = 0;        // Reset counter
   numRainDumps = 0;        // Reset counter
}
