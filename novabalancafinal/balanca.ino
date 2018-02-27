/*
1) Visitar o Site de spakfun para obter os manuais de uso e montagem do Amplificador HX711 e do Combinador para as células de peso da balança e seu hackeo:
https://learn.sparkfun.com/tutorials/load-cell-amplifier-hx711-breakout-hookup-guide?_ga=2.261439693.17426171.1519700546-86089324.1519700546
2) Descarregar livraria para Arduino https://github.com/aguegu/ardulibs/tree/master/hx711 e instala-la 
Usamos como ponto de partida descrito no inicio do arquivo a programação fornecida pela Sparkfun
*/

#include "HX711.h"

/*
  Example using the SparkFun HX711 breakout board with a scale
  By: Nathan Seidle
  SparkFun Electronics
  Date: November 19th, 2014
  License: This code is public domain but you buy me a beer if you use this and we meet someday (Beerware license).

  This example demonstrates basic scale output. See the calibration sketch to get the calibration_factor for your
  specific load cell setup.

  This example code uses bogde's excellent library: https://github.com/bogde/HX711
  bogde's library is released under a GNU GENERAL PUBLIC LICENSE

  The HX711 does one thing well: read load cells. The breakout board is compatible with any wheat-stone bridge
  based load cell which should allow a user to measure everything from a few grams to tens of tons.
  Arduino pin 2 -> HX711 CLK
  3 -> DAT
  5V -> VCC
  GND -> GND

  The HX711 board can be powered from 2.7V to 5V so the Arduino 5V power should be fine.

*/

#include "HX711.h"
//-23630
#define calibration_factor -21840.00 //This value is obtained using the SparkFun_HX711_Calibration sketch

#define DOUT  3
#define CLK  2

HX711 scale(DOUT, CLK);

int pessoas = 0;

void setup() {
  Serial.begin(9600);

  scale.set_scale(calibration_factor); //This value is obtained by using the SparkFun_HX711_Calibration sketch
  scale.tare(); //Assuming there is no weight on the scale at start up, reset the scale to 0

}

void loop() {
  float peso;
  peso = scale.get_units();
  if (peso > 20) {
    pessoas++;
    float maxi = 0;
    while ((peso = scale.get_units()) > 20) {
      if (peso > maxi) {
        maxi = peso;
      }
    }
   // Serial.println(pessoas++);
    Serial.println(maxi -5);
  }
}
