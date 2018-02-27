import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;
import javax.net.ssl.HttpsURLConnection;
import processing.serial.*;

class Bola {
  public int x, y;
  Bola (int a, int b) {
    x = a;
    y = b;
  }
}

class Elemento extends Thread {
  private double porcentagem;
  private double valor_localkg;
  private String moeda, name;
  private double preco_real;
  private long sec;
  private boolean up;

  private double speed;
  public double x;
  public int y;

  public color c;

  Elemento (double porcentagem, double valor_localkg, String moeda, String name) {
    super();
    this.porcentagem = porcentagem;
    this.valor_localkg = valor_localkg;
    this.name = name;
    this.moeda = moeda;
    this.preco_real = 0;
    this.sec = 0;
    this.up = false;

    this.speed = (height*Math.random())/400.0;
    this.y = (int)(Math.random()*height*0.1+height*0.8);
    this.x = width*Math.random();
    this.c = color(random(255), random(255), random(255));
  }

  public void upX () {
    x -= speed;
    if (x <= -width*0.20) {
      x = width;
      y = (int)(Math.random()*height*0.1+height*0.8);
      speed = (height*Math.random())/400.0;
    }
  }

  public String value() {
    double percentage = preco_real;
    double v = (double) Math.round(percentage * 100000) / 100000;
    return "R$ "+v;
  }

  public void run () {
    while (true) {
      try {
        long now = System.currentTimeMillis()/1000;
        if (now - sec < 10*60) {
          Thread.sleep(1000);
          continue;
        }

        String url = "https://www.investing.com/currencies/"+moeda+"-brl";
        String USER_AGENT = "Mozilla/5.0";

        URL obj = new URL(url);
        HttpURLConnection con = (HttpURLConnection) obj.openConnection();

        // optional default is GET
        con.setRequestMethod("GET");

        //add request header
        con.setRequestProperty("User-Agent", USER_AGENT);

        BufferedReader in = new BufferedReader(
          new InputStreamReader(con.getInputStream()));
        String inputLine;
        StringBuffer response = new StringBuffer();

        while ((inputLine = in.readLine()) != null) {
          if (inputLine.contains("last_last")) {
            response.append(inputLine);
          }
        }
        in.close();

        String s = response.toString();
        s = s.substring(s.indexOf("\">") + 2);
        s = s.substring(0, s.indexOf("</"));

        //print result
        double newv = Double.parseDouble(s);
        if (this.preco_real < newv) up = true;
        else up = false;

        this.preco_real = newv;
        System.out.println(this.name+": "+this.preco_real);

        sec = now;
      } 
      catch (Exception err) {
      }
    }
  }
}

ArrayList<Elemento> elementos = new ArrayList<Elemento>();
ArrayList<Bola> bolas = new ArrayList<Bola>();
PFont font;
Serial myPort;
int lf = 10; // Linefeed in ASCII

double peso_total = 0;
double peso_grafico= 0;
long numero_pessoas = 0;

double pesso_ultima = 0;

double max = 1000; // pesso maximo

void setup () {

  fullScreen();
  //size(640, 360);
  background(0);
  //font = createFont("SourceCodePro-Regular.ttf", 24);
  //textFont(font);

  // Adiciona os elementos
  Elemento e1 = new Elemento(0.2, 100, "usd", "Oxigenio");
  e1.c = color(255, 0, 0);
  elementos.add(e1);

  elementos.add(new Elemento(0.1, 50, "aud", "Carbono"));
  elementos.add(new Elemento(0.4, 1, "usd", "Hidrogenio"));
  elementos.add(new Elemento(0.3, 1, "cny", "Nitrogenio"));
  

  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 9600); // mudar serial

  for (Elemento e : elementos) {
    e.start();
  }
}

void draw () {

  while (myPort.available() > 0) {
    String myString = myPort.readStringUntil(lf);
    if (myString != null) {
      pesso_ultima = Float.valueOf(myString).floatValue();
      peso_total += pesso_ultima;
      peso_grafico += pesso_ultima;
      if (peso_grafico > max) peso_grafico = pesso_ultima;
      numero_pessoas++;
      bolas.add(new Bola((int)(Math.random()*width), height));
    }
  }

  background(0);

  // barra dados
  textSize(height*0.04);

  int y = 0;
  for (Elemento e : elementos) {
    fill(e.c);
    int delta = (int)(peso_grafico*e.porcentagem/max*height);
    rect(0, y, width, delta);
    y += delta;
  }

  for (int i = 0; i < bolas.size(); i++) {
    println(bolas.get(i).x);
    circles(bolas.get(i).x, bolas.get(i).y, 20, 120);
    if (bolas.get(i).y <= y) {
      bolas.remove(i);
      i--;
    } else {
      bolas.get(i).y = (int)(bolas.get(i).y-0.5);
      bolas.get(i).x = (int)(bolas.get(i).x+random(-2, 2));
    }
  }


  setGradient(0, height, width, height*0.85);

  for (Elemento e : elementos) {
    String name = e.name+": ";
    float sw = textWidth(name);

    fill(e.c);
    text(name, (int)e.x, e.y);
    if (e.up) fill(0, 255, 0);
    else fill(255, 0, 0);
    text(e.value(), (int)(e.x+sw), e.y);
    e.upX();
  }

  textSize(height*0.023);
  int dist = (int)(width/5.5);
  int d = (int)(width*0.02);

  fill(200, 200, 200);
  textAlign(LEFT);
  text("n° pessoas: "+numero_pessoas, d, height*0.95);
  d += dist;
  text("Peso total: "+r(peso_total, 1), d, height*0.95);
  d += dist;
  text("R$ total: "+r(valor(peso_total, elementos), 100), d, height*0.95);
  d += dist;
  text("Peso pessoa: "+r(pesso_ultima, 10), d, height*0.95);
  d += dist;
  text("R$ pessoa: "+r(valor(pesso_ultima, elementos), 100), d, height*0.95);
}

double valor (double peso, ArrayList<Elemento> elementos) {
  double valor = 0;
  for (Elemento e : elementos) {
    valor += peso*e.porcentagem*e.preco_real;
  }
  return valor;
}

void setGradient(int x, int y, float w, float h) {
  for (int i = y; i >= h; i--) {
    float inter = map(i, y, h, 255, 0);
    stroke(0, 0, 0, inter);
    line(x, i, w, i);
  }
}

double r (double percentage, int p) {
  return (double) Math.round(percentage * p) / p;
}


void circles(float x, float y, float size, color c) {
  stroke(255); // Set stroke color to white

  fill(c);
  ellipse(x, y, size, size);
}
