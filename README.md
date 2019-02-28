# Open access human movement data for improving lower-limb wearable robotics
Project code associated with Hu et al. '18 [paper](https://doi.org/10.3389/frobt.2018.00014) on the ENcycopedia of Able-bodied Lower Limb Locomotor Signals (ENABL3S) [dataset](https://doi.org/10.6084/m9.figshare.5362627). 

<p align="center">
  <img style="float: center;" src="http://blair-hu.github.io/img/OpenSourceDataset1.jpg" width="800">
</p>

### Introduction

The program is written in MATLAB (Mathworks). The code is known to run on R2014a, but should also be compatible with other versions. The main program function is **demo.m**. Running the provided code will generate the 

Running this program will simulate the model network's response to different input stimuli, corresponding to the contour integration experiments (Chen et al., 2014) and the border-ownership experiments (Qiu et al., 2007). Please be patient as these simulations may take some time. Please also note that our final results are based on averages over multiple simulations, while the demo here just shows results from a single simulation. To reproduce a subset of the figures shown in the paper using the actual data from our simulations, run **plot_figs.m**. For more details about the model and/or experiments, please see the following references:

    @Article{Hu_Niebur17,
        Title                    = {A recurrent neural model of proto-object based contour integration and figure-ground segregation},
        Author                   = {Hu, Blair, Rouse, Elliott, and Hargrove, Levi},
        Journal                  = {Frontiers in Robotics and AI},
        Year                     = {2018},
        Volume                   = {5},
        Number                   = {14},
        Doi                      = {10.3389/frobt.2018.00014},
    }

### Miscellaneous

The data from our final simulation results can be found in the **Results** directory. Our paper detailing the recurrent neural model can be found in the **resources** directory.

Special thanks to Danny Jeck (@dannyjeck) for contributing portions of the code in his re-write of an earlier model that the current work was based upon. If you have any questions, please feel free to contact me at bhu6 (AT) jhmi (DOT) edu.
