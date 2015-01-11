Most scripts use a variable called suffix to distinguish among files derived from different models. I have the value 'Test' in this example.

I first use ParseExtractScriptYiping to create AllMetabolitesYipingMin1Percent.xlsx from XiaojingTargetedYiping.xlsx and TargetedListNames.txt. XiaojingTargetedYiping is derived from Xiaojing's original Excel file targeted-11ppm-both, which I modified by removing every column past AW, removing all spaces in the metabolite names, removing the first row, and renaming the UMP metabolite in rows 1691-1700 to UMP_2. Then I interchanged the values for 3 and 4[13C] erythrose in AllMetabolites following Xiaojing's recommendation, to make AllMetabolitesYipingMin1PercentErythroseInterchanged.xlsx.

I then handwrote everything except the measurements and errors in modelTest.xls. The script writeXiaojingMeas automatically writes measurements and errors to the model file using AllMetabolitesYipingMin1PercentErythroseInterchanged.xlsx. I save modelTest as a .txt file, and use the jar file OpenFLUX_v2.jar, with the setting Overwrite all existing files, in OpenFlux to create some auxiliary files from modelTest.txt.

I then run OpenFlux flux estimation by running start13OF and selecting Task 1 from the menu it presents. There are many different settings you have to give for this command-however, if the script detects the file setting_PE.mat, it can load the settings automatically from there, and similarly setting_CI.mat for confidence interval estimation, and inputSubConfig.mat for input labeling patterns. I have saved all three files with descriptive names from previous runs, and run the short script renameSettingsFiles to copy them over with the plain names that start13OF recognizes. You can view the parameters after loading them, and they should be self-explanatory except for reversible UB, which is set to 10/11 because a numerical convention used in OpenFlux, which translates to an upper flux value of 1000. You can read more about it in the OpenFlux manual.

After the end of Task 1, several output files are created, of which I usually use MID_solution, results_mid, and results_PE.txt. To avoid overwriting them on the next run, I usually run renameOutputFiles to add a suffix to the filenames, and renameOutputFiles2 for the reverse.

graphMIDResults makes several different bar graphs from the renamed output files, some of which are obsolete and no longer very useful, which are described in the comments. Finally, I use fluxNetDiagram to make the files modelTest.xml, modelTestFluxes.xml, and modelTestFluxes.json. In Cytoscape with the plugins CyFluxViz and CySBML, I import modelTest.xml from the File menu, load a layout from modelTestLayout.xml (which I created manually and saved previously), then import modelTestFluxes.xml with CyFluxViz.

Workflow Notes (initially added on 10/25/2014):

Make XiaojingTargetedYipingv0.xlsx from targeted-11ppm-both.xlsx by removing every column past AW, removing all spaces in the metabolite names, removing the first row, and renaming the UMP metabolite in rows 1691-1700 to UMP_2. 

Use parseExtractScriptYiping to make AllMetabolitesYipingv0.xlsx from XiaojingTargetedYiping.xlsx and TargetedListNames.txt.

Interchange the values for 3 and 4[13C] erythrose in AllMetabolitesYipingv0.xlsx.

Handwrite everything in modelv0.xls except measurements and errors.

Use writeXiaojingMeas to write measurements and errors to modelv0.xls, and make errorCompareGraphv0.png.

Save modelv0.xls in .txt format.

Use OpenFLUX_v2.jar, with the setting Overwrite all existing files, to make dee_x_sim.m, error.txt, measurements.txt, substrate_EMU.m, x_sim.m, and all files in the "model" folder.

Run renameSettingsFiles to write over setting_PE.mat, setting_CI.mat, and inputSubConfig.mat with v0 versions.

Run start13OF, Task 1, accept all settings detected from setting_PE.mat and inputSubConfig.mat. Output allBasis_soln.txt, inputSubEMU.mat, results_exitflag.txt, results_flag.txt, results_fval.txt, results_midv0.txt, results_PEv0.txt, results_x.txt, results_x0.txt, and x_solution.txt

Run graphMIDResults to make fluxGraphExchangeTest.png, fluxGraphv0.png, fluxGraphZoomv0.png, MIDErrorSelectv0.png, MIDGraphSelectv0.png, MIDGraphv0.png.

Run fluxNetDiagram to make modelv0.xml, modelv0Fluxes.xml, and modelv0Fluxes.json.

Configuration Notes:

.mat files are inputSubConfigTestExport.mat, setting_CIBasis100Limits1000OnlyGlucoseExport.mat, and setting_PETwoIterBasis100Limits1000Export.mat.

parseExtractScriptYiping: min1Percent=1
writeXiaojingMeas: meanOffset=1,errorOffset=2,overwriteError=1,uniformError=0

Above, including manual erythrose interchange, XiaojingTargetedYiping changes, and model file definition, are summarized as v0.

1/11/2015
testPathways.R reads testKEGG.txt, which the KEGG ID of succinate, and prints to screen the first KEGG pathway associated with the KEGG ID.

parseExtractScriptYipingMaria is derived from the original script for Xiaojing, and uses dataMaria.xlsx, which is a rename of 12-8-14_13C-glucose intracellular labeling.xlsx. It puts the output in outputMaster/Maria