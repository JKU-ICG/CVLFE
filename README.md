# CVLFE
**Compressive Volumetric Light-Field Excitation**

## SYSTEM AND SOFTWARE
#### System Requirements:
A decent PC with enough RAM (16 GB or more, depending on the dataset).

#### Software Requirements:
- Matlab (>R2015b) with Image Processing Toolbox.
The software was tested on Windows 10 running Matlab R2015b. 

#### External Libraries/Tools (included in 'thirdparty' folder):
- some functions from Ron Rubinstein's OMP-Box [http://www.cs.technion.ac.il/~ronrubin/software.html]
- SART implementation by Alexander Koppelhuber
- NMF toolbox by Yifeng Li and Alioune Ngom [https://sites.google.com/site/nmftool/]
- matlab-tree by Jean-Yves Tinevez to represent tree data structures in Matlab [http://tinevez.github.io/matlab-tree/]
- matgraph library by Edward Scheinerman to schedule parallel recordings [https://de.mathworks.com/matlabcentral/fileexchange/19218-matgraph]

#### Instructions:
- Download or Clone the Software from Github
- The package should run as it is without any modifications. Just run 'run_all.m' and it will create results with a low scattering level. 
- Results will be stored in a 'results' folder.
- The scattering level can be changed to the scattering levels provided in the 'data' folder.

## DATA
Example data is provided in the 'data' folder in form of Matlab data files (.mat). Data is provided for several scattering levels for 30 20µm-sized microbeads (in the code they are called neurons).
The simulation data is generated by the phase-space measurement technique from Liu [https://www.osapublishing.org/oe/abstract.cfm?uri=oe-23-11-14461] for which we don't own the copyright. Therefore the data generation is omitted in our software.

## RELATED PAPER
This source code supplements the following papers:
- Schedl, D. C. and Bimber, O. Compressive Volumetric Light-Field Excitation. Nature Sci. Rep. (to appear), 2017
- Schedl, D. C. and Bimber, O. Volumetric Light-Field Excitation. Nature Sci. Rep. 6, 29193; doi: 10.1038/srep29193, 2016

## SUPPORT
We probably can not take any feature requests, but we will try to help you getting the code running (just write us an email).

## SUPPORT
David C. Schedl 
[mailto:david.schedl@jku.at]

