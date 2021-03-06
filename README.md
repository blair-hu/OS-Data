# Open access human movement data for improving lower-limb wearable robotics
Project code associated with Hu et al. '18 [paper](https://doi.org/10.3389/frobt.2018.00014) on the ENcycopedia of Able-bodied Lower Limb Locomotor Signals (ENABL3S) [dataset](https://doi.org/10.6084/m9.figshare.5362627). 

<p align="center">
  <img style="float: center;" src="http://blair-hu.github.io/img/OpenSourceDataset1.jpg" width="800">
</p>

### Introduction
The program is written in MATLAB (Mathworks). The code is known to run on R2014a, but should also be compatible with other versions. The data should be processed sequentially in the following order: 

1. Run **getsegmentedfromraw.m** on raw data (direct output from our CAPS data acquisition software), using the experimental annotation notes and visual inspection to exclude errant gait events, to save **resegmented.m** versions of each file.

2. Run **getfeatsfromsegmented.m** on **resegmented.m** files from all subjects to save:<br/>
-raw and processed data for each circuit as CSV files (**raw.csv** and **post.csv**)<br/>
-EMG signal-to-noise metadata (**checkEMG.mat**)<br/>
-goniometer statistical metadata (**checkGONIO.mat**)<br/>
-level ground walking EMG and kinematic data from averaged strides for comparison to reference data (**all_LW_EMG.mat** and **all_LW_GONIO.mat**)<br/>
-aggregated features with varying time delays of 0, 30, 60, 90, and 120 ms (**AllSubs_feats_reprocessed.mat**)

3. Run **savemeta.m** to save subject-specific metadata from **checkEMG.mat** and **checkGONIO.mat** as CSV files **Metadata.csv**.

4. Run **savemvc.mat** and **savemvctrunc.mat** to save subject-specific average maximum RMS during voluntary contractions as **AllSubjectMVC.mat**. 

5. Run **compareWinter.m** to make graphs comparing the aggregated kinematic and EMG patterns for stance/swing to Winter's data.

For more details about the dataset, please see the following reference:

    @Article{
        Title                    = {Benchmark Datasets for Bilateral Lower-Limb Neuromechanical Signals from Wearable Sensors during Unassisted Locomotion in Able-Bodied Individuals},
        Author                   = {Hu, Blair, Rouse, Elliott, and Hargrove, Levi},
        Journal                  = {Frontiers in Robotics and AI},
        Year                     = {2018},
        Volume                   = {5},
        Number                   = {14},
        Doi                      = {10.3389/frobt.2018.00014},
    }
