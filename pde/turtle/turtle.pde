// From http://www.openprocessing.org/sketch/26896

import processing.net.Server;
import processing.net.Client;

Turtle turtle;

Server s;
Client c;
String data;

void setup() {
    size(400, 400);
    fill(#000000);
    try {
        s = new Server(this, 12345);
    } catch (ReferenceError e) {
	// processing.js n'a pas de Server
    } catch (ReferenceError e) {
	e.printStackTrace();
    }
    reset();
}

void reset() {
    turtle = new Turtle();
    background(#FFFFFF);
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

void interact(String data) {
    String[] src_array = data.split(" ");
    String cmd = "";
    int param = 0;
    switch (src_array.length) {
        case 0:
            cmd = data;
            break;
        case 1:
            cmd = src_array[0];
            break;
        case 2:
            cmd = src_array[0];
            param = int(src_array[1]);
            break;
        default:
            println("Too much spaces!");
    }
    if (false) {
        // pas de switch sur les strings !!!
    } else if (cmd.equals("AV")) {
        turtle.forward(param);
    } else if (cmd.equals("TD")) {
        turtle.right(param);
    } else if (cmd.equals("TG")) {
        turtle.left(param);
    } else if (cmd.equals("BC")) {
        turtle.pendown();
    } else if (cmd.equals("LC")) {
        turtle.penup();
    } else if (cmd.equals("RAZ")) {
        reset();
    }
}

void draw() {
  if (s != null) {
    c = s.available();
    if (c != null) {
      data = trim(c.readString());
      interact(data);
    }
  }
}
