// From http://www.openprocessing.org/sketch/26896

import processing.net.Server;
import processing.net.Client;

Turtle turtle;

Server s;
Client c;
String data;

int w = 600;
int h = 600;

void setup() {
    size(w, h);
    fill(#000000);
    try {
        s = new Server(this, 12345);
    } catch (Exception e) {
	// processing.js n'a pas de Server.
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
    String[] params = data.split(" ");
    String cmd = "";
    switch (params.length) {
        case 0:
            cmd = data;
            break;
        default:
            cmd = params[0];
            break;
    }
    if (false) {
        // pas de switch sur les strings !!!
    } else if (cmd.equals("Contour")) {
        int alpha = 255;
        if (params.length == 5) {
            alpha = int(params[4]);
        }
        stroke(color(int(params[1]), int(params[2]), int(params[3]), alpha));
    } else if (cmd.equals("Remplissage")) {
        int alpha = 255;
        if (params.length == 5) {
            alpha = int(params[4]);
        }
        fill(color(int(params[1]), int(params[2]), int(params[3]), alpha));
    } else if (cmd.equals("Disque")) {
        ellipse(int(params[1]), h - int(params[2]), int(params[3]), int(params[3]));
    } else if (cmd.equals("AV")) {
        turtle.forward(int(params[1]));
    } else if (cmd.equals("TD")) {
        turtle.right(int(params[1]));
    } else if (cmd.equals("TG")) {
        turtle.left(int(params[1]));
    } else if (cmd.equals("BC")) {
        turtle.pendown();
    } else if (cmd.equals("LC")) {
        turtle.penup();
    } else if (cmd.equals("RAZ")) {
        reset();
    }
}

void draw() {
    if (s == null) {
	// Sans doute la version processing.js.
    } else {
        c = s.available();
        if (c != null) {
            data = trim(c.readString());
            interact(data);
        }
    }
}