// From http://www.openprocessing.org/sketch/26896

import processing.net.Server;
import processing.net.Client;

Turtle turtle;

Server s;
Client c;
String data;

int w = 600;
int h = 600;

float x_min = 0;
float x_max = 600;
float y_min = 0;
float y_max = 600;

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
    float x, y;
    float oldx, oldy;
    float angle;
    color tcolor;

    Turtle() {
        oldx = width/2;
        oldy = height/2;
        x = oldx;
        y = oldy;
        tcolor = #000000;
        angle = 0;
        stroke(tcolor);
    }

    void forward(float step) {
        x = oldx - step * cos(radians(angle+90));
        y = oldy - step * sin(radians(angle+90));
        line(oldx, oldy, x, y);
        oldx = x;
        oldy = y;
    }

    void left(float dangle) {
        angle -= dangle;
    }

    void right(float dangle) {
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

float mapx(float x) {
    return map(x, x_min, x_max, 0, 600);
}

float mapy(float y) {
    return map(y, y_min, y_max, 600, 0);
}

float mapw(float x) {
    return map(x, 0, x_max - x_min, 0, 600);
}

float maph(float y) {
    return map(y, 0, y_max - y_min, 0, 600);
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
    } else if (cmd.equals("Repere")) {
        x_min = float(params[1]);
        x_max = float(params[2]);
        y_min = float(params[3]);
        y_max = float(params[4]);
    } else if (cmd.equals("Contour")) {
        int alpha = 255;
        if (params.length == 5) {
            alpha = int(params[4]);
        }
        Color c = color(int(params[1]), int(params[2]), int(params[3]), alpha);
        stroke(c);
        turtle.pencolor(c);
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
        line(mapx(float(params[1])), mapy(float(params[2])),
             mapx(float(params[3])), mapy(float(params[4])));
    } else if (cmd.equals("Cercle")) {
        ellipse(mapx(float(params[1])), mapy(float(params[2])),
                mapw(float(params[3])), maph(float(params[3])));
    } else if (cmd.equals("Ellipse")) {
        ellipse(mapx(float(params[1])), mapy(float(params[2])),
                mapw(float(params[3])), maph(float(params[4])));
    } else if (cmd.equals("Rectangle")) {
        rect(mapx(float(params[1])), mapy(float(params[2])),
             mapx(float(params[3])), mapy(float(params[4])));
    } else if (cmd.equals("Triangle")) {
        triangle(mapx(float(params[1])), mapy(float(params[2])),
                 mapx(float(params[3])), mapy(float(params[4])),
                 mapx(float(params[5])), mapy(float(params[6])));
    } else if (cmd.equals("AV")) {
        turtle.forward(float(params[1]));
    } else if (cmd.equals("TD")) {
        turtle.right(float(params[1]));
    } else if (cmd.equals("TG")) {
        turtle.left(float(params[1]));
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
