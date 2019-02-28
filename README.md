# Open access human movement data for improving lower-limb wearable robotics
Project code associated with Hu et al. '18 paper on the ENcycopedia of Able-bodied Lower Limb Locomotor Signals (ENABL3S) dataset. 

<p align="center">
  <img style="float: center;" src="http://blair-hu.github.io/img/OpenSourceDataset1.jpg" width="800">
</p>

### Introduction

The program is written in MATLAB (Mathworks). The code is known to run on R2014a, but should also be compatible with other versions. The main program function is **demo.m**. Running this program will simulate the model network's response to different input stimuli, corresponding to the contour integration experiments (Chen et al., 2014) and the border-ownership experiments (Qiu et al., 2007). Please be patient as these simulations may take some time. Please also note that our final results are based on averages over multiple simulations, while the demo here just shows results from a single simulation. To reproduce a subset of the figures shown in the paper using the actual data from our simulations, run **plot_figs.m**. For more details about the model and/or experiments, please see the following references:

    @Article{Hu_Niebur17,
        Title                    = {A recurrent neural model of proto-object based contour integration and figure-ground segregation},
        Author                   = {Hu, Brian and Niebur, Ernst},
        Journal                  = {Journal of Computational Neuroscience},
        Year                     = {2017},
        Volume                   = {43},
        Number                   = {3},
        Pages                    = {227--242},
        Doi                      = {10.1007/s10827-017-0659-3},
    }
