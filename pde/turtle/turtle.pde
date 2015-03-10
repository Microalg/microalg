// From http://www.openprocessing.org/sketch/26896

import processing.net.Server;
import processing.net.Client;

Turtle turtle;

Server s;
Client c;
String data;

void setup() {
    size(400, 400);
    turtle = new Turtle();
    background(#FFFFFF);
    s = new Server(this, 12345);
}

class Turtle {
    int x, y;
    int oldx, oldy;
    int angle;
    color tcolor;

    Turtle() {
        oldx = int(width/2);
        oldy = int(height/2);
        x = oldx;
        y = oldy;
        tcolor = #000000;
        angle = 0;
        stroke(tcolor);
    }

    void forward(int step) {
        x = oldx - int(step * cos(radians(angle+90)));
        y = oldy - int(step * sin(radians(angle+90)));
        line(oldx, oldy, x, y);
        oldx = x;
        oldy = y;
    }

    void left(int dangle) {
        angle -= dangle;
    }

    void right(int dangle) {
        angle += dangle;
    }

    void pencolor(color ncolor) {
        tcolor = ncolor;
        stroke(tcolor);
    }

    void penup() {
        noStroke();
    }

    void pendown() {
        stroke(tcolor);
    }
}

void interact(String cmd, int param) {
    if (false) {
        // pas de switch sur les strings !!!
    } else if (cmd == "AV") {
        turtle.forward(param);
    } else if (cmd == "TD") {
        turtle.right(param);
    } else if (cmd == "TG") {
        turtle.left(param);
    } else if (cmd == "BC") {
        turtle.pendown();
    } else if (cmd == "LC") {
        turtle.penup();
    }
}

void draw() {
  c = s.available();
  if (c != null) {
    data = c.readString(); 
    // Keep what is inside the two first double quotes, then split at spaces.
    String[] src = data.split("\"")[1].split(" ");
    String cmd = src[0];
    int param = int(src[1]);
    interact(cmd, param);
    background(param);
  }
}
