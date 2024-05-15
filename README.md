# CTIA_TAHA
Github repository containing the required deliverables for the LLM AI challenge.
See report for more information.

El Hihi Taha
0567414
Taha.El.Hihi@vub.be

SETUP:
  LLM part:
  - python version 3.8.19
  - txtai 7.0.0
  
  The following is also required:
  - pip install txtai[pipeline-data]
  - pip install txtai[pipeline-llm]  
  - pip install txtai[pipeline-text]

  PARSER PART:
  The parser is implemented using prolog, the python script uses the parser using the “subprocess” library (which does terminal commands).
  To run it, you will need to install swipl: https://www.swi-prolog.org/download/stable and make sure to add “swipl” in the environment variable with its path.

The final implementation can be found in the 'rags' folder, the Final.ipynb.

Example usage:

llm_to_AutoML_translator("Train a model that can estimate density based on volume and mass given the objects dataset")

This will print:

intermediate:

Regression, dependent attribute: density, independent attributes: volume, mass.


AutoML Symbols:	

[loadData,calculateDensity,calculateVolume,splitTrainTestData,knnRegression,regressionMSEError]

Data columns:

[[],[massInKilograms,surfaceInSquareMeters],[surfaceInSquareMeters,heightInMeters],[],[[volume,mass],density],knnRegression_OUTPUT]








