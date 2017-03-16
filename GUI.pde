size(1000,500);
var run = true;

//stores GUI element objects
var guiElements = [];

//GUI element shapes
var shapes = [
    {
        drw : function(w,h){ //rectangle
            rect(0,0,w,h,5);
        },
        mOvr : function(mx,my,x,y,w,h){
            return (mx > x && mx < x + w && my > y && my < y + h) ? true : false;
        }
    },
    {
        drw : function(w,h){ //ellipse/circle
            ellipseMode(CORNER);
            ellipse(0,0,w,h);
        },
        mOvr : function(mx,my,x,y,w,h){
            var a = w / 2;
            var b = h / 2;
            var cx = x + a;
            var cy = y + b;
            var t = atan2((my - cy) , (mx - cx));
            var r = (a * b) / sqrt(pow(a,2) * pow(sin(t),2) + pow(b,2) * pow(cos(t),2));
            return (dist(mx,my,cx,cy) < r) ? true : false;
        }
    },
];
var whichShape = function(input){
    var output;
    switch(input){
        default : 
            output = 0;
        break;
        case "ellipse":
            output = 1;
        break;
        
    }
    
    return output;
};

//color schemas 
var colorSchemes = [
    {
        fll : color(255),
        strk : color(0),
        mOvr : color(255, 0, 0),
        txtClr : color(0),
    },
];

//calculate maximum text size for certain parameters
var txtSze = function(txt,ts,w,h){
    var ts = ts;
    textSize(ts);
    var tw = textWidth(txt);
    var th = textAscent() + textDescent();
    
    while(textWidth(txt) * 1.2 < w && (textAscent() + textDescent()) * 1.2 < h){
        ts ++;
        textSize(ts);
        tw = textWidth(txt);
        th = textAscent() + textDescent();
    }
    
    return ts;
};

//Basic GUI element
var GUI = function(type,shape,cs,x,y,w,h,r,sx,sy,txt,exec){
    //imagery stuff
    this.type = type;
    this.sh = shapes[whichShape(shape)];
    this.cs = colorSchemes[cs];
    
    //size/location
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.r = r;
    this.sx = sx;
    this.sy = sy;
    
    //code to run when clicked
    this.exec = exec;
    
    //text stuff
    this.txt = txt;
    this.ts = 0;
    textSize(this.ts);
    this.tw = textWidth(txt);
    this.ta = textAscent();
    this.td = textDescent();
    this.th = this.ta + this.td;
    
    //click animation
    this.xc = 0;
    this.yc = 0;
    //mouse over?
    this.mOvr = false;
    
    //if object is an independant element, add to the array of GUI element objects
    if(this.type === "whole element"){
        guiElements.push(this);
    }
};
GUI.prototype.draw = function() {
    pushMatrix();
    translate(this.x+this.xc,this.y+this.yc);
    rotate(this.r);
    scale(this.sx,this.sy);
    
    //color scheme
    if(this.mOvr){
        fill(this.cs.mOvr);
    }else{
        fill(this.cs.fll);
    }
    stroke(this.cs.strk);
    
    //draw shape
    this.sh.drw(this.w,this.h);
    
    //draw text
    fill(this.cs.txtClr);
    textSize(txtSze(this.txt,0,this.w,this.h));
    
    textAlign(CENTER,CENTER);
    //text(this.txt,0,0,this.w,this.h);
    text(this.txt,this.w/2,this.h/2);
    
    popMatrix();
    
    //reset click animation
    this.xc = 0;
    this.yc = 0;
};
GUI.prototype.over = function(){
    //set this.mOvr to boolean for if the mouse is over the shape
    this.mOvr = this.sh.mOvr(mouseX,mouseY,this.x,this.y,this.w,this.h);
};

//Button GUI element
var Button = function(){
    GUI.apply(this,arguments);
};
Button.prototype = Object.create(GUI.prototype);
Button.prototype.clicked = function(){
    if(this.mOvr){
        //execute code for when button is clicked
        this.exec();
        
        //click animation
        this.xc -= 2;
        this.yc += 2;
    }
};

new Button("whole element","rectangle",0,20,20,100,30,0,1,1,"println \"abc\"",function(){println("abc");});
new Button("whole element","ellipse",0,20,60,100,30,0,1,1,"test",function(){ellipse(200,200,20,20);});

//Input GUI element
var Input = function(){
    GUI.apply(this,arguments);
    
    this.pointerLocation = 0;
    this.typing = false;
};
Input.prototype = Object.create(GUI.prototype);
Input.prototype.clicked = function(){
    if(this.mOvr){
        //execute code for when button is clicked
        this.txt = ["a"];
        this.typing = true;
    }
};
Input.prototype.execute = function(){
    if(this.typing){
        if(frameCount % 50 < 25){// <= 0 && frameCount % 10 > 6){
            stroke(0);
            strokeWeight(2);
            var px = textWidth(this.txt[this.pointerLocation]) / 2 + this.w / 2;
            line(this.x + px,this.y + this.h/6,this.x + px,this.y + (this.h*5)/6);
        }
    }
};

new Input("whole element","rectangle",0,20,100,100,30,0,1,1,"input",function(){});

void draw() {
    background(255);
    
    //draw GUI elements
    for(var i = 0; i < guiElements.length; i ++){
        guiElements[i].draw();
        if(guiElements[i].execute){
            guiElements[i].execute();
        }
    }
    
};

void mouseMoved(){
    //is mouse over GUI elements?
    for(var i = 0; i < guiElements.length; i ++){
        guiElements[i].over();
    }
};

void mouseClicked(){
    //is a GUI element clicked?
    for(var i = 0; i < guiElements.length; i ++){
        guiElements[i].clicked();
    }
};
