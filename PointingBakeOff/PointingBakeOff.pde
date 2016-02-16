import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;
import ddf.minim.*;

//when in doubt, consult the Processsing reference: https://processing.org/reference/

int margin = 200; //set the margina around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 50; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
Robot robot; //initalized in setup
Rectangle currentBox;
Rectangle nextBox;
Minim minim;
AudioPlayer clickSound;

int numRepeats = 3; //sets the number of times each button repeats in the test
boolean blink = true;

void setup()
{
  size(700, 700); // set the size of the window
  //noCursor(); //hides the system cursor if you want
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  //rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

  minim = new Minim(this);
  clickSound = minim.loadFile("Click2.wav");
  try {
    robot = new Robot(); //create a "Java Robot" class that can move the system cursor
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  System.out.println("trial order: " + trials);
  
  frame.setLocation(0,0); // put window in top left corner of screen (doesn't always work)
}


void draw()
{
  background(255); //set background to black

  if (trialNum >= trials.size()) //check to see if test is over
  {
    textSize(20);
    fill(0); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
    text("Total time taken: " + (finishTime-startTime) / 1000f + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + ((finishTime-startTime) / 1000f)/(float)(hits+misses) + " sec", width / 2, height / 2 + 100);      
    return; //return, nothing else to do now test is over
  }
  
  

  textSize(30);
  fill(0); //set fill color to white
  text((trialNum +  1) + " of " + trials.size(), 80, 40); //display what trial the user is on
  
  
   
  if(trialNum < trials.size()-1 && currentBox != null && nextBox != null) {
    if(isMouseInside(currentBox)) {
     fill(125);
     rect(currentBox.x-10, currentBox.y-10, currentBox.width+20, currentBox.height+20);
     fill(255);
     rect(currentBox.x-5, currentBox.y-5, currentBox.width+10, currentBox.height+10);
   }
    stroke(120);
    //arrow((currentBox.x+currentBox.width/2.0), (currentBox.y+currentBox.height/2.0), (nextBox.x+nextBox.width/2.0), (nextBox.y+nextBox.height/2.0));
    if(currentBox.equals(nextBox)) {
      noFill();
      ellipse(currentBox.x+10, currentBox.y+10, 30, 30);
      //text("Double Tap!", currentBox.x+50, currentBox.y+50);
    }
    else
    line(currentBox.x+currentBox.width/2.0, currentBox.y+currentBox.height/2.0, nextBox.x+nextBox.width/2.0, nextBox.y+nextBox.height/2.0);
    noStroke();
  }
  
  for (int i = 0; i < 16; i++)// for all button
    drawButton(i); //draw button
  
  
  // fill(255, 0, 0, 200); // set fill color to translucent red
  // ellipse(mouseX, mouseY, 20, 20); //draw user cursor as a circle with a diameter of 20
}

void mousePressed() // test to see if hit was in target!
{
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) //check if first click, if so, start timer
    startTime = millis();

  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output:
    println("Hits: " + hits);
    println("Misses: " + misses);
    println("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%");
    println("Total time taken: " + (finishTime-startTime) / 1000f + " sec");
    println("Average time for each button: " + ((finishTime-startTime) / 1000f)/(float)(hits+misses) + " sec");
  }

  Rectangle bounds = getButtonLocation(trials.get(trialNum));

 //check to see if mouse cursor is inside correct button 
  if (findClosestButton() == trials.get(trialNum) || (mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
  {
    clickSound.play();
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
    hits++; 
    clickSound.rewind();
  } 
  else
  {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
  }

  trialNum++; //Increment trial number

  //in this example code, we move the mouse back to the middle
  // robot.mouseMove(width/2, (height)/2); //on click, move cursor to roughly center of window!
}

//find closest button
int findClosestButton()
{
  double min = getMouseButtonDistance(0);
  int index = -1;
  for(int i=1; i<16; ++i) {
    double dist = getMouseButtonDistance(i);
    if(dist < min && dist < 100d) { // 100 is the threshold
      min = dist;
      index = i;
    }
  }
  return index;
}

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

//get mouse button distance
double getMouseButtonDistance(int i)
{
  int x = (i % 4) * (padding + buttonSize) + margin + buttonSize / 2;
  int y = (i / 4) * (padding + buttonSize) + margin + buttonSize / 2;
  return Math.sqrt(Math.pow(mouseX - x, 2) + Math.pow(mouseY - y, 2));
}

void arrow(float x1, float y1, float x2, float y2) {
      // draw the line
    line(x1, y1, x2, y2);
    
    // draw a triangle at (x2, y2)
    pushMatrix();
     rotate(atan2(y2-y1, x2-x1));
     translate((x2+x1)/2, (y2+y1)/2);
     triangle(0, 0, -10, 5, -10, -5);
    popMatrix(); 
    
} 

void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);

  if (trials.get(trialNum) == i) { // see if current button is the target
    currentBox = bounds;
    
    
    // Handles blink factor in current box. 
    if (frameCount % 10 < 5) 
      fill(255, 150, 150); // Change to light red to enable blinking
    else
      fill(255, 0, 0); // if so, fill cyan
    rect(bounds.x+8, bounds.y+8, bounds.width-16, bounds.height-16);
    
  }
  else if ((trialNum +1 < trials.size()) && trials.get(trialNum+1) == i) { 
    nextBox = bounds;
    fill(180, 80, 80); // if so, fill with lighter cyan
    rect(bounds.x+8, bounds.y+8, bounds.width-16, bounds.height-16);
  }
  else {
    fill(100); // if not, fill gray
    rect(bounds.x+8, bounds.y+8, bounds.width-16, bounds.height-16);
    //rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
  }
}

boolean isMouseInside(Rectangle b) {
  return mouseX > b.x && mouseX < (b.x + b.width) && mouseY > b.y && mouseY < (b.y + b.height);
}

// In case sound file plays longer than program, this stops it. 
void stop() {
  minim.stop();
  super.stop();
}

void mouseMoved()
{
   //can do stuff everytime the mouse is moved (i.e., not clicked)
   //https://processing.org/reference/mouseMoved_.html
}

void mouseDragged()
{
  //can do stuff everytime the mouse is dragged
  //https://processing.org/reference/mouseDragged_.html 
}

void keyPressed() 
{
    mousePressed();
  //can use the keyboard if you wish
  //https://processing.org/reference/keyTyped_.html
  //https://processing.org/reference/keyCode.html
}