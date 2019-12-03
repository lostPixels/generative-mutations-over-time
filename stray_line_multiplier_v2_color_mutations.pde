import java.util.Collections;
import processing.pdf.*;

int maxPoints = 60;
int bufferX = 50;
float mutationChance = .9;
float minSpace = 4;

float mutationMinPoint = .2;
float startingSize = 7;
float downTick = -7;

Boolean PDFMODE = false;

void setup() {
  size(1056, 1332);
  background(255);
  //size(1056, 1632);
  //frameRate(5);
  if(PDFMODE) {
    beginRecord(PDF, "triangles2.pdf");  
  }
}

ArrayList<PVector> points = new ArrayList();
boolean firstRun = true;

void draw() {
    
  if(firstRun) {
   points.add( new PVector(width / 2, bufferX));
   firstRun = false;
  }
  
  ArrayList<PVector> newPoints = new ArrayList();
  for(PVector point : points) {
    float randomAspect = point.y / (height);
    randomAspect = randomAspect < mutationMinPoint ? 0 : map(randomAspect, mutationMinPoint, 1, 0, 1);
    boolean drop = random(.5) > 1 - randomAspect;
    if(!drop && point.y < height-bufferX && point. x > bufferX && point.x < width - bufferX) {
      newPoints.add(drawSegment(point.x, point.y, 1, randomAspect));
      newPoints.add(drawSegment(point.x, point.y, -1, randomAspect));
    }
  }
  points = removeDupes(newPoints);
  if(points.size() > maxPoints) {
    Collections.shuffle(points);
    int start = floor(random(points.size() - maxPoints));
    points = new ArrayList(points.subList(start, start + maxPoints));
  }
  else if(points.size() == 0) {
    println("complete");
    noLoop();
    if(PDFMODE) {
      endRecord();
      exit();
    }
  }
}

PVector drawSegment(float x, float y, float dir, float randomAspect) {

  if(randomAspect < .2 || random(1) < mutationChance) { //flipping this < makes the strings look uniform.
    randomAspect = 0;
  }
  
  float progression = y / (height);
  
  progression = progression < mutationMinPoint ? 0 : map(progression, mutationMinPoint, 1, 0, 1);
  
  float dist = startingSize + (downTick*progression) + random(randomAspect * 25);
  
  float strayX = startingSize;
  strayX += (downTick*progression);
  strayX *= dir;
  strayX += (-10 + random(10))* randomAspect;
  
  if(progression > 0) {
    strayX += -1 + random(2);  
  }
  
  float jump = random(1) < randomAspect ? 15 + random(70) : 0;
  if(jump > 0) { println("jump!"); }

  float tX = x + strayX;
  float tY = y + dist + jump;
  
  //line(x, y+jump, tX, tY);
  beginShape();
  noFill();
  vertex(x, y+jump);
  vertex(tX, tY);
  endShape();
  return new PVector(tX, tY);
}

ArrayList removeDupes(ArrayList<PVector> originalArray) {
  ArrayList<PVector> newPoints = new ArrayList();
  for(PVector point : originalArray) {
    boolean found = false;
    int i = 0;
    while(i < newPoints.size() && !found) {
      PVector otherPoint = newPoints.get(i);
      if(otherPoint.x - minSpace < point.x && 
         otherPoint.x + minSpace > point.x &&
         otherPoint.y - minSpace < point.y && 
         otherPoint.y + minSpace > point.y) {
           found = true; 
      }
      
      i++;
    }
    if(!found) {
      newPoints.add(point);
    }
  }
  
  return newPoints;
}
