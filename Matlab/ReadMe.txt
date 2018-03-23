1. Use experimental notes along with "getsegmentedfromraw.m" to save "_resegmented.m" outputs for original files.

2. Use "getfeatsfromsegmented.m" on all "_resegmented.mat" files from all subjects to save raw/processed data for each circuit as CSV files ("_raw.csv" and "_post.csv"), EMG SNR metadata ("checkEMG.mat"), GONIO metadata ("checkGONIO.mat"), and LW EMG/GONIO data for comparison to reference data ("all_LW_EMG.mat" and "all_LW_GONIO.mat"), and aggregated features (with 0, 30, 60, 90, and 120 ms delay) as "AllSubs_feats_reprocessed.mat".

*These can also be run for subject-specific "_resegmented.mat" files to generate feature CSV files for each subject using "savefeats.m."

3. Use "savemeta.m" to save subject-specific metadata from "checkEMG.mat" and "checkGONIO.mat" as CSV files ("_Metadata.csv").

4. Get MVC data from raw data using "savemvc.mat" and "savemvctrunc.mat", which saves subject-specific data as "_MVC.csv", then saves truncated (based on user input) subject-specific data as "_MVC_trunc.csv", and saves average of max RMS values on a subject- and channel- basis as "AllSubjMVC.mat."

5. Use "compareWinter.m" to make graphs comparing the aggregated kinematic and EMG patterns for stance/swing to Winter's data.