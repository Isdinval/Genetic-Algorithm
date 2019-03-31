class DNA {
  // **************************************************************
  //                         PARAMETERS
  // **************************************************************
  char[] genes;
  float fitness;


  // **************************************************************
  //                        CONSTRUCTOR
  // **************************************************************
  DNA() {
    genes = new char[target.length()];
    for (int i=0; i < genes.length; i++) {
      genes[i] = (char) random(32, 128);
    }
  }


  // **************************************************************
  //                         FUNCTIONS
  // **************************************************************
  // **************************************************************
  // Give a score to the member of the population
  void fitness() {
    int score = 0;
    for (int i=0; i < genes.length; i++) {
      if (genes[i] == target.charAt(i)) {
        score++;
      }
    }
    fitness = (float)pow(2, score);
  }
  
  
  // **************************************************************
  // Crossover between two member of the population.
  // Random midpoint technique is used here :
  DNA crossover(DNA partner) {
    DNA child = new DNA();
    int midpoint = int(random(genes.length));
    for (int i = 0; i < genes.length; i++) {
      if (i > midpoint) child.genes[i] = genes[i];
      else              child.genes[i] = partner.genes[i];
    }
    return child;
  }
  
  
  // **************************************************************
  // Mutation given the mutationRate
  void mutate(float mutationRate) {
    for (int i = 0; i < genes.length; i++) {
      if (random(1) < mutationRate) {
        genes[i] = (char) random(32, 128);
      }
    }
  }
  
  
  // **************************************************************
  // Convert to String - PHENOTYPE
  String getPhrase() {
  return new String(genes);
  }
  

}
