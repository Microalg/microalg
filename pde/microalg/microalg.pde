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
    try {
        s = new Server(this, 12345);
    } catch (Exception e) {
        // processing.js n'a pas de Server.
    }
    reset();
    rectMode(CORNERS);
}

void reset() {
    background(#FFFFFF);
    strokeWeight(1);
    stroke(color(0, 0, 0));
    fill(1, 0, 0, 0);  // 0, 0, 0, 0 n’est pas transparent (bug de Processing)
    turtle = new Turtle();
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
        stroke(int(params[1]), int(params[2]), int(params[3]), alpha);
    } else if (cmd.equals("Remplissage")) {
        int alpha = 255;
        if (params.length == 5) {
            alpha = int(params[4]);
        }
        // 0, 0, 0, 0 n’est pas transparent (bug de Processing)
        if (alpha == 0) params[1] = "1";
        fill(int(params[1]), int(params[2]), int(params[3]), alpha);
    } else if (cmd.equals("Epaisseur")) {
        strokeWeight(int(params[1]));
    } else if (cmd.equals("Segment")) {
        line(int(params[1]), h - int(params[2]), int(params[3]), h - int(params[4]));
    } else if (cmd.equals("Cercle")) {
        ellipse(int(params[1]), h - int(params[2]), int(params[3]), int(params[3]));
    } else if (cmd.equals("Ellipse")) {
        ellipse(int(params[1]), h - int(params[2]), int(params[3]), int(params[4]));
    } else if (cmd.equals("Rectangle")) {
        rect(int(params[1]), h - int(params[2]), int(params[3]), h - int(params[4]));
    } else if (cmd.equals("Triangle")) {
        triangle(int(params[1]), h - int(params[2]),
                 int(params[3]), h - int(params[4]),
                 int(params[5]), h - int(params[6]));
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
    } else {
        println("Commande non reconnue : " + data);
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
