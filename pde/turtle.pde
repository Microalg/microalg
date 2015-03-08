// From http://www.openprocessing.org/sketch/26896

Turtle t1;
color bgColor = #000000;

void setup() {
    size(260,260);
    background(bgColor);
    t1 = new Turtle();
}
void draw() {
    t1.penup()
    t1.setxy(30,50);
    t1.left(45);
    t1.pendown()
    spiro (5,20,90,20);
    noLoop();
}

void polyspiro (int lepes, int max, int meret, int szog, int nov) {
    if (lepes<=max) {
        t1.forward(meret);
        t1.right(szog);
        polyspiro ((lepes+1),max,(meret+nov),szog,nov);
    }
}
void spiro (int max, int meret, int szog, int nov) {
    polyspiro (1,max,meret,szog,nov);
    spiro (max,meret,szog,nov);
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
        tcolor = #FFFFFF;
        angle = 0;
        stroke (tcolor);
    }

    void forward (int step) {
        x = oldx - int(step * cos(radians(angle+90)));
        y = oldy - int(step * sin(radians(angle+90)));
        line(oldx,oldy,x,y);
        oldx = x;
        oldy = y;
    }

    void back (int step) {
        x = oldx + int(step * cos(radians(angle+90)));
        y = oldy + int(step * sin(radians(angle+90)));
        line(oldx,oldy,x,y);
        oldx = x;
        oldy = y;
    }

    void home () {
        oldx = int(width/2);
        oldy = int(height/2);
        line(oldx,oldy,x,y);
        oldx = x;
        oldy = y;
        angle = 0.0;
    }

    void setx(int step) {
        x = oldx + step;
        oldx = x;
    }

    void sety(int step) {
        y = oldy + step;
        oldy = y;
    }

    void setxy(int stepx, int stepy) {
        x = oldx + stepx;
        y = oldy + stepy;
        oldx = x;
        oldy = y;
    }

    void left (int dangle) {
        angle -= dangle;
    }

    void right (int dangle) {
        angle += dangle;
    }

    void setheading (int nangle) {
        angle = nangle;
    }

    void pencolor (color ncolor) {
        tcolor = ncolor;
        stroke (tcolor);
    }

    void penup() {
        noStroke();
    }

    void pendown() {
        stroke (tcolor);
    }

    void penerase() {
        stroke (bgColor);
    }
}
