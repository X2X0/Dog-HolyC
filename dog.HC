#include "StdLib.HC"

#define DOG_SITTING 0
#define DOG_RUNNING 1
#define DOG_BARKING 2
#define DOG_SLEEPING 3

class CDog {
    F64 x, y;
    F64 vel_x, vel_y;
    I64 state;
    I64 timer;
    F64 wag_angle;
    Bool is_happy;
    I64 energy;
    I64 bark_timer;
};

CDog dog;
F64 mouse_x, mouse_y;
I64 bg_color;

U0 DrawDogBody(F64 x, F64 y, I64 color) {
    GrEllipse(x-15, y-10, 30, 20, color);
    GrEllipse(x-8, y-25, 16, 12, color);
    GrEllipse(x-20, y+5, 8, 15, color);
    GrEllipse(x+12, y+5, 8, 15, color);
    GrEllipse(x-18, y-5, 8, 12, color);
    GrEllipse(x+10, y-5, 8, 12, color);
}

U0 DrawDogFace(F64 x, F64 y, I64 state) {
    GrEllipse(x-8, y-30, 16, 12, LTGRAY);
    GrEllipse(x-5, y-35, 3, 6, BLACK);
    GrEllipse(x+2, y-35, 3, 6, BLACK);
    
    if (state == DOG_BARKING) {
        GrEllipse(x-2, y-28, 4, 6, RED);
        GrLine(x-8, y-25, x-3, y-27, RED);
        GrLine(x+3, y-27, x+8, y-25, RED);
    } else if (state == DOG_SLEEPING) {
        GrLine(x-5, y-32, x-2, y-32, BLACK);
        GrLine(x+2, y-32, x+5, y-32, BLACK);
    } else {
        GrCircle(x-1, y-30, 2, BLACK);
    }
    
    GrEllipse(x-4, y-40, 3, 4, BLACK);
    GrEllipse(x+1, y-40, 3, 4, BLACK);
}

U0 DrawDogTail(F64 x, F64 y, F64 angle, I64 color) {
    F64 tail_x = x + 15 + 12 * Cos(angle);
    F64 tail_y = y - 5 + 8 * Sin(angle);
    GrLine(x+15, y-5, tail_x, tail_y, color);
    GrLine(tail_x, tail_y, tail_x-3, tail_y+5, color);
    GrLine(tail_x, tail_y, tail_x+3, tail_y+5, color);
}

U0 DrawDog(CDog *d) {
    I64 body_color = BROWN;
    if (d->is_happy) body_color = YELLOW;
    
    DrawDogBody(d->x, d->y, body_color);
    DrawDogFace(d->x, d->y, d->state);
    DrawDogTail(d->x, d->y, d->wag_angle, body_color);
    
    if (d->state == DOG_BARKING && d->bark_timer > 0) {
        GrPrint(d->x + 20, d->y - 40, "WOOF!");
        d->bark_timer--;
    }
}

U0 DrawBackground() {
    GrRect(0, 0, GR_WIDTH, GR_HEIGHT, bg_color);
    
    for (I64 i = 0; i < 20; i++) {
        F64 grass_x = i * 40;
        F64 grass_y = GR_HEIGHT - 50;
        GrLine(grass_x, grass_y, grass_x + 5, grass_y - 10, GREEN);
        GrLine(grass_x + 10, grass_y, grass_x + 15, grass_y - 8, GREEN);
        GrLine(grass_x + 20, grass_y, grass_x + 25, grass_y - 12, GREEN);
    }
    
    GrCircle(GR_WIDTH - 80, 60, 30, YELLOW);
    for (I64 i = 0; i < 8; i++) {
        F64 angle = i * 2 * π / 8;
        F64 sx = GR_WIDTH - 80 + 40 * Cos(angle);
        F64 sy = 60 + 40 * Sin(angle);
        F64 ex = GR_WIDTH - 80 + 50 * Cos(angle);
        F64 ey = 60 + 50 * Sin(angle);
        GrLine(sx, sy, ex, ey, YELLOW);
    }
    
    for (I64 i = 0; i < 5; i++) {
        F64 cloud_x = 100 + i * 150;
        F64 cloud_y = 80 + i * 5;
        GrEllipse(cloud_x, cloud_y, 40, 20, WHITE);
        GrEllipse(cloud_x - 15, cloud_y, 30, 15, WHITE);
        GrEllipse(cloud_x + 15, cloud_y, 30, 15, WHITE);
    }
}

U0 UpdateDog(CDog *d) {
    d->timer++;
    
    ms.pos.x = mouse_x;
    ms.pos.y = mouse_y;
    
    F64 dist_to_mouse = Sqrt(Sqr(mouse_x - d->x) + Sqr(mouse_y - d->y));
    
    if (dist_to_mouse < 50) {
        d->is_happy = TRUE;
        d->state = DOG_BARKING;
        d->bark_timer = 30;
        if (d->timer % 10 == 0) {
            Beep(800, 100);
        }
    } else if (dist_to_mouse < 200 && d->energy > 20) {
        d->state = DOG_RUNNING;
        d->vel_x = (mouse_x - d->x) * 0.02;
        d->vel_y = (mouse_y - d->y) * 0.02;
        d->energy--;
    } else if (d->energy < 20) {
        d->state = DOG_SLEEPING;
        d->vel_x *= 0.9;
        d->vel_y *= 0.9;
        d->energy++;
    } else {
        d->state = DOG_SITTING;
        d->vel_x *= 0.95;
        d->vel_y *= 0.95;
        d->is_happy = FALSE;
    }
    
    if (d->state == DOG_RUNNING || d->is_happy) {
        d->wag_angle = Sin(d->timer * 0.5) * 0.8;
    } else {
        d->wag_angle = 0.2;
    }
    
    d->x += d->vel_x;
    d->y += d->vel_y;
    
    if (d->x < 50) d->x = 50;
    if (d->x > GR_WIDTH - 50) d->x = GR_WIDTH - 50;
    if (d->y < 50) d->y = 50;
    if (d->y > GR_HEIGHT - 100) d->y = GR_HEIGHT - 100;
    
    if (d->timer % 60 == 0) {
        bg_color = RandU16 % 16;
    }
}

U0 DrawUI() {
    GrPrint(10, 10, "Energy: %d", dog.energy);
    GrPrint(10, 25, "State: ");
    switch (dog.state) {
        case DOG_SITTING: GrPrint(60, 25, "Sitting"); break;
        case DOG_RUNNING: GrPrint(60, 25, "Running"); break;
        case DOG_BARKING: GrPrint(60, 25, "Barking"); break;
        case DOG_SLEEPING: GrPrint(60, 25, "Sleeping"); break;
    }
    GrPrint(10, 40, "Move mouse to interact!");
    GrPrint(10, GR_HEIGHT - 30, "Credits: X2X0");
    
    for (I64 i = 0; i < dog.energy / 10; i++) {
        GrRect(120 + i * 5, 10, 4, 10, GREEN);
    }
}

U0 InitDog() {
    dog.x = GR_WIDTH / 2;
    dog.y = GR_HEIGHT / 2;
    dog.vel_x = 0;
    dog.vel_y = 0;
    dog.state = DOG_SITTING;
    dog.timer = 0;
    dog.wag_angle = 0;
    dog.is_happy = FALSE;
    dog.energy = 100;
    dog.bark_timer = 0;
    bg_color = LTBLUE;
}

U0 Main() {
    SettingsPush;
    Fs->draw_it = &DrawIt;
    
    InitDog();
    
    while (TRUE) {
        mouse_x = ms.pos.x;
        mouse_y = ms.pos.y;
        
        GrClear;
        
        DrawBackground();
        UpdateDog(&dog);
        DrawDog(&dog);
        DrawUI();
        
        Sleep(50);
        
        if (ScanKey) {
            if (GetKey == CH_ESC) break;
            if (GetKey == ' ') {
                dog.energy = 100;
                dog.is_happy = TRUE;
                Beep(1000, 200);
            }
        }
    }
    
    SettingsPop;
}
