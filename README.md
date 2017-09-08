# CVLFE
**Compressive Volumetric Light-Field Excitation**

## SYSTEM AND SOFTWARE
#### System Requirements:
A decent PC with enough RAM (16 GB or more, depending on the dataset).

#### Software Requirements:
- Matlab (>=R2015b) with Image Processing Toolbox.
The software was tested on Windows 10 running Matlab R2015b. 

#### External Libraries/Tools (included in `thirdparty` folder):
- some functions from Ron Rubinstein's [OMP-Box](http://www.cs.technion.ac.il/~ronrubin/software.html)
- SART implementation by Alexander Koppelhuber
- [NMF toolbox](https://sites.google.com/site/nmftool/) by Yifeng Li and Alioune Ngom 
- [matlab-tree](http://tinevez.github.io/matlab-tree/) by Jean-Yves Tinevez to represent tree data structures in Matlab 
- [matgraph](https://de.mathworks.com/matlabcentral/fileexchange/19218-matgraph) library by Edward Scheinerman to schedule parallel recordings 

#### Instructions:
- Download or clone the software from Github.
- Download the data files (see [data readme](data/README.md) for details).
- The package should run as it is without any modifications. 
- Running `run_all.m` and it will create results with a low scattering level. 
- Results will be stored in a `results` folder.

## DATA
Example data needs to be placed in the `data` folder in form of Matlab data files (.mat). 
Data is available for download at [Google Drive](https://drive.google.com/drive/folders/0BybPuFSOXAjHc1hNOE9vMk5iakk?usp=sharing).
See [data readme](data/README.md) for details.

## RELATED PAPERS
This source code supplements the following papers:
- Schedl, D. C. and Bimber, O. Compressive Volumetric Light-Field Excitation. Nature Sci. Rep. (to appear), 2017
- Schedl, D. C. and Bimber, O. Volumetric Light-Field Excitation. Nature Sci. Rep. 6, 29193; doi: 10.1038/srep29193, 2016

## SUPPORT
We probably can not take any feature requests, but we will try to help you getting the code running (just write us an email).

## CONTACT
[David C. Schedl](mailto:david.schedl@jku.at)
```
Institute of Computer Graphics

JOHANNES KEPLER UNIVERSITY LINZ
Altenberger Straße 69
Science Park III, 0354
4040 Linz, Austria

P +43 732 2468 6640
david.schedl@jku.at
www.jku.at/cg
```
