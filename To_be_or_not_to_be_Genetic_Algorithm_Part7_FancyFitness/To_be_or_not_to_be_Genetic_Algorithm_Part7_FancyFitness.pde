//https://natureofcode.com/book/chapter-9-the-evolution-of-code/ //<>//

// ============================================================================
//                                   Feedback
// ============================================================================
/*
   In this application, we use a fancy fitness function : 
   2 ^ score. 
   Due to his exponential nature, we can't use a target with a length too long. 
   For instance, if target.length() = 150 chars, maxFitness = 2^150 = 1,42724769E45 !!!
   We cannot remap such a number. Processing consider it as INFINITY. 
   Even though Exponential fitness function with 2^score works very effiently. 
   It has to be consider. 
   
   /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
   /!\/!\/!\      Current limitation is 127 chars. After this, it crashs.     /!\/!\/!\
   /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
   
   
   Maybe we could use another fancy fitness function as score*score. 
   For instance, if target.length() = 150 chars, maxFitness = 150*150 = 22500 !!!
*/


// ============================================================================//<>////<>////<>//
//                                 PSEUDO-CODE
// ============================================================================
/*
  Step n°1 : Initialize Population
 --> Create a population of elements, each with randomly generated DNA.
 
 Step n°2 : Selection
 --> Evaluate the fitness of each element of the population and 
 build a mating pool.
 
 Step n°3 : Reproduction
 --> Pick two parents with probability according to relative fitness.
 --> Crossover — create a “child” by combining the DNA of these two parents.
 --> Mutation — mutate the child’s DNA based on a given probability.
 --> Add the new child to a new population.
 
 Step n°4 : Replace the old population with the new population and return to Step 2.
 */


// ============================================================================
//                                 PARAMETERS
// ============================================================================
import controlP5.*;
import java.util.*;

// Genetic algorithm parameters
float mutationRate = 0.001; // 0.001
int totalPopulation = 50000; //30 000
int totalGenerations;
DNA[] population;
ArrayList<DNA> matingPool;
String target0 = "La reconnaissance a la memoire courte.";
String target1 = "To be, or not to be: that is the question";
String target2 = "Science sans conscience n est que ruine de l ame";
String target3 = "La corde du mensonge est courte.";
String target4 = "Les enfants ont la memoire courte, mais ils ont le souvenir rapide.";
String target5 = "La plus courte reponse est l action.";
String target6 = "Un seul etre vous manque, et tout est depeuple";
String target7 = "Mieux vaut verge courte que coucher seule.";
String target8 = "La vie est trop courte pour qu'on se dispute.";
String target9 = "Le cul du berger sentira toujours le thym.";
String target10 = "Vivre sans amour n'est pas vivre, et vivre dans l'amour sans souffrir est impossible.";
String target11 = "Amour est avant tout de se consumer a essayer de deviner ce qui se pense dans une autre tete. Rien de plus torturant...";
float target_i;
String target = target0;
int endString = 24; // Used to display a reduced target on the scrollable list
List<String> l = new ArrayList<String>(); 
String bestPhrase;
char[] bestPhrase_char = new char[target.length()];
boolean end_GA = false;

// Display parameters
int textSize = 20;
float[] fitness_value = new float[totalPopulation];
float moyenne_fitness;
float max_fitness;
float max_index_fitness = 0;

// GUI Main parameters
ControlP5 cp5;
Accordion accordion;
PFont pfont;
ControlFont font ;
float play = 0;
boolean play_b = false;
float reset = 0;
boolean reset_b = false;

//Get time
float currTime, prevTime;  // milliseconds
float totalTime;




// ============================================================================
//                                     SETUP
// ============================================================================
void setup() {
  size(475, 600);
  frameRate(30);
  population = new DNA[totalPopulation];

  // Create the list to display in the scrollbox list
  if (target0.length() < 128) l.add("1-  " + target0.substring(0, endString).concat("..."));
  if (target1.length() < 128) l.add("2-  " + target1.substring(0, endString).concat("..."));
  if (target2.length() < 128) l.add("3-  " + target2.substring(0, endString).concat("..."));
  if (target3.length() < 128) l.add("4-  " + target3.substring(0, endString).concat("..."));
  if (target4.length() < 128) l.add("5-  " + target4.substring(0, endString).concat("..."));
  if (target5.length() < 128) l.add("6-  " + target5.substring(0, endString).concat("..."));
  if (target6.length() < 128) l.add("7-  " + target6.substring(0, endString).concat("..."));
  if (target7.length() < 128) l.add("8-  " + target7.substring(0, endString).concat("..."));
  if (target8.length() < 128) l.add("9-  " + target8.substring(0, endString).concat("..."));
  if (target9.length() < 128) l.add("10- " + target9.substring(0, endString).concat("..."));
  if (target10.length() < 128) l.add("11- " + target10.substring(0, endString).concat("..."));
  if (target11.length() < 128) l.add("11- " + target11.substring(0, endString).concat("..."));
  gui(105, 15*textSize, l);

  // Create the font and the police size we want to use in the canvas
  pfont = createFont("Georgia", 13, false); // use true/false for smooth/no-smooth

  // Start timer, right away when the application start
  currTime = prevTime = millis();

  // **************************************************************
  //               STEP n°1 : Initialize population
  // **************************************************************
  // Initializing each member of the population
  addPopulation();
}


// ============================================================================
//                                     DRAW
// ============================================================================
void draw() {
  background(255);
  // **************************************************************
  //             Get infos from GUI controllers
  // **************************************************************
  // Get informations from differen GUI controllers
  int populationButton = (int)(cp5.getController("Population").getValue());

  if (populationButton != totalPopulation) {
    totalPopulation = populationButton;
    population = new DNA[totalPopulation];
    addPopulation();
  }

  mutationRate = cp5.getController("Mutation rate (%)").getValue()/100;
  // paused = 0 : paused == false
  // paused = 1 : paused == true
  play = cp5.getController("Play").getValue();
  if (play == 0) play_b = true;
  if (play == 1) play_b = false;

  reset = cp5.getController("Reset").getValue();
  if (reset == 0) reset_b = false;
  if (reset == 1) reset_b = true;

  target_i = cp5.getController("Goal sentence").getValue();
  if (target_i == 0) if (target0.length() < 128) target=target0;
  if (target_i == 1) if (target1.length() < 128)target=target1;
  if (target_i == 2) if (target2.length() < 128)target=target2;
  if (target_i == 3) if (target3.length() < 128)target=target3;
  if (target_i == 4) if (target4.length() < 128)target=target4;
  if (target_i == 5) if (target5.length() < 128)target=target5;
  if (target_i == 6) if (target6.length() < 128)target=target6;
  if (target_i == 7) if (target7.length() < 128)target=target7;
  if (target_i == 8) if (target8.length() < 128)target=target8;  
  if (target_i == 9) if (target9.length() < 128)target=target9;
  if (target_i == 10) if (target10.length() < 128)target=target10;
  if (target_i == 11) if (target11.length() < 128)target=target11;

  // **************************************************************
  //                    RESET button is pressed
  // **************************************************************
  if (reset_b) { // IF we push reset button
    reset();
    prevTime = millis();
  }

  // **************************************************************
  //                     PLAY button is pressed
  // **************************************************************
  if (!play_b) { // if we push play button
    if (end_GA == false) { // if the application isn't finished, we continue

      // **************************************************************
      //                     STEP n°2 : SELECTION
      // **************************************************************
      // STEP 2-1 : Give a score to each member of the population
      for (int i=0; i < population.length; i++) {
        population[i].fitness();
      }

      // **************************************************************
      //                      Normalize the score
      // **************************************************************
      // Get the max fitness of the population
      // We need to create a float[]array : fitness_value to get along the getMax()
      for (int i = 0; i < population.length; i++) {
        fitness_value[i] = population[i].fitness;
      }
      max_fitness = getMax(fitness_value);

      // Normalize the score of each member of the population
      for (int i=0; i < population.length; i++) {
        population[i].fitness = map(population[i].fitness, 0, max_fitness, 0, 1);
      }

      // Get the average fitness of the population
      for (int i = 0; i < population.length; i++) {
        fitness_value[i] = map(fitness_value[i], 0, max_fitness, 0, 1);
      }

      for (int i = 0; i < fitness_value.length; i++) {
        moyenne_fitness = moyenne_fitness + fitness_value[i];
      }
      moyenne_fitness /= population.length;

      // Get the max index of fitness from a member of the pulation
      // Then get the bestPhrase
      max_index_fitness = getMaxIndex(fitness_value);
      bestPhrase = population[(int)max_index_fitness].getPhrase();
      bestPhrase_char = population[(int)max_index_fitness].genes;


      // **************************************************************
      //                IF GOAL HAS BEEN FOUND... we do :
      // **************************************************************
      for (int i = 0; i < population.length; i++) {
        if (population[i].getPhrase().equals(target)) {
          println("DONE!");
          end_GA = true;
          currTime = millis();
          totalTime = (currTime - prevTime)/1000;
        }
      }


      // STEP 2-2 : Add each member to the mating pool
      // Wheel of forturne technique
      matingPool = new ArrayList<DNA>();
      for (int i=0; i < population.length; i++) {
        int n = int(population[i].fitness*100);
        for (int j=0; j < n; j++) {
          matingPool.add(population[i]);
        }
      }

      // **************************************************************
      //                     STEP n°3 : REPRODUCTION
      // **************************************************************
      for (int i = 0; i < population.length; i++) {
        // Get two random indices from the mating pool
        int a = int(random(0, matingPool.size()));
        int b = int(random(0, matingPool.size()));
        // If "b" indice is the same as "a", we pick another parent's indice
        if (a == b) b = int(random(0, matingPool.size())); 
        // We Use these indices to retrieve an actual DNA instance from the
        // mating pool.
        DNA partnerA = matingPool.get(a);
        DNA partnerB = matingPool.get(b);

        // STEP 3-1 : Crossover
        DNA child = partnerA.crossover(partnerB);
        // STEP 3-2 : Mutation
        child.mutate(mutationRate);
        population[i] = child;
      }


      totalGenerations++;
    }
  }

  // **************************************************************
  //                   STEP n°4 : DISPLAY RESULTS
  // **************************************************************
  textFont(pfont);
  textSize(20);
  stroke(0);
  fill(0xffff0000);
  text("Goal phrase : ", 20, 2*textSize);

  fill(0);
  textSize(15);
  int endText = 64;
  
  if(target.length() < endText) {
    text(target, 20, 3*textSize);
  } else if (target.length() >= endText) { // if target.length is too long, we display it on two lines
    String target_part1 = target.substring(0, endText).concat("-");
    String target_part2 = target.substring(endText, target.length());
    text(target_part1, 20, 3*textSize);
    text(target_part2, 20, 4*textSize);
  }


  fill(0xffff0000);
  textSize(20);
  text("Best phrase : ", 20, 6*textSize);

  fill(0);
  textSize(15);
  if (bestPhrase != null) {
    if (bestPhrase.length() < endText) {
      text(bestPhrase, 20, 7*textSize);
    } else if (bestPhrase.length() >= endText) { // if bestPhrase.length is too long, we display it on two lines
      String bestPhrase_part1 = bestPhrase.substring(0, endText).concat("-");
      String bestPhrase_part2 = bestPhrase.substring(endText, bestPhrase.length());
      text(bestPhrase_part1, 20, 7*textSize);
      text(bestPhrase_part2, 20, 8*textSize);
    }
  }

  fill(0xffff0000);
  textSize(20);
  text("Some interesting stuff : ", 20, 10*textSize);

  fill(0);
  textSize(15);
  text("Total generations : " + (int)totalGenerations, 20, 11*textSize);
  text("Average fitness : " + nf(100*moyenne_fitness, 0, 1) + " %", 20, 12*textSize);
  text("Target length : " + target.length() + " characters", 20, 13*textSize);
  if (end_GA) {
    text("Total time : " + nf(totalTime, 0, 1) + " s", 20, 14*textSize);
  }
}




// ============================================================================
//                                     FUNCTIONS
// ============================================================================
// ****************************************************************************
// Initialize population
void addPopulation() {
  // **************************************************************
  //               STEP n°1 : Initialize population
  // **************************************************************
  // Initializing each member of the population
  for (int i=0; i < population.length; i++) {
    population[i] = new DNA();
  }
}


// ****************************************************************************
// Reset 
void reset() {
  totalGenerations = 0;
  moyenne_fitness = 0;
  max_fitness = 0;
  totalTime = 0;
  end_GA = false;
  // Initializing each member of the population
  for (int i=0; i < population.length; i++) {
    population[i] = new DNA();
  }

  // Get the average fitness of the population
  for (int i = 0; i < population.length; i++) {
    fitness_value[i] = population[i].fitness;
  }
}


// ****************************************************************************
// Method for getting the minimum value
float getMax(float[] inputArray) { 
  float maxValue = inputArray[0]; 
  for (int i=1; i<inputArray.length; i++) { 
    if (inputArray[i] > maxValue) { 
      maxValue = inputArray[i];
    }
  } 
  return maxValue;
} 


// ****************************************************************************
// Method for getting the minimum value
float getMaxIndex(float[] inputArray) { 
  float maxValue = inputArray[0]; 
  float maxIndex = 0;
  for (int i=1; i<inputArray.length; i++) { 
    if (inputArray[i] > maxValue) { 
      maxValue = inputArray[i]; 
      maxIndex = i;
    }
  } 
  return maxIndex;
} 


// ****************************************************************************
void gui(float posX, float posY, List l) {
  // Init ControlP5
  cp5 = new ControlP5(this);
  cp5.setColorForeground(0xffDC143C);
  cp5.setColorBackground(0xff660000);
  cp5.setColorActive(0xffff0000);


  // ********************************************************************
  //                     GROUPE 1 : Create some controllers
  //                    RadioButton x1, slider x2, button x1
  // ********************************************************************
  // Init Groupe 1
  Group g1 = cp5.addGroup("Main parameters")
    .setBackgroundColor(color(0, 90))
    .setBackgroundHeight(270)
    .setBarHeight(17);

  // Init sliders, radioButton and button
  cp5.addSlider("Population")
    .setPosition(10, 20)
    .setSize(100, 20)
    .setRange(100, 50000)
    .setValue(int(totalPopulation/2)) //10000
    .setDecimalPrecision(0)
    .moveTo(g1);

  cp5.addSlider("Mutation rate (%)")
    .setPosition(10, 50)
    .setSize(100, 20)
    .setRange(0.0001*100, 0.05*100)
    .setValue(mutationRate*100) //0.0001*100
    .moveTo(g1);

  cp5.addRadioButton("PlayButton")
    .setPosition(100, 90)
    .setItemWidth(14)
    .setItemHeight(14)
    .addItem("Play", 0)
    .setColorLabel(color(255))
    .activate(2)
    .moveTo(g1);

  cp5.addRadioButton("ResetButton")
    .setPosition(100, 120)
    .setItemWidth(14)
    .setItemHeight(14)
    .addItem("Reset", 0)
    .setColorLabel(color(255))
    .activate(0)
    .moveTo(g1);

  /* add a ScrollableList, by default it behaves like a DropdownList */
  cp5.addScrollableList("Goal sentence")
    .setPosition(10, 150)
    .setSize(230, 100)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems(l)
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    .close()
    .moveTo(g1);


  //// ********************************************************************
  ////    Groupe1 : Load and apply the font and captionlabels's content 
  //// ********************************************************************
  pfont = createFont("Georgia", 13, false); // use true/false for smooth/no-smooth
  font = new ControlFont(pfont, 13);
  cp5.setFont(font);


  // ********************************************************************
  //                               Accordion : 
  //                                 Groupe1
  // ********************************************************************
  // create a new accordion
  // add g1 to the accordion.
  accordion = cp5.addAccordion("acc")
    .setPosition(posX, posY)
    .setWidth(255)
    .addItem(g1);

  accordion.open(0);
  accordion.setCollapseMode(Accordion.SINGLE);


  // ********************************************************************
  //                    ShortCuts: Open/close accordion
  // ********************************************************************
  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      accordion.open(0, 1, 2);
    }
  }
  , 'o');
  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      accordion.close(0, 1, 2);
    }
  }
  , 'c');
}
