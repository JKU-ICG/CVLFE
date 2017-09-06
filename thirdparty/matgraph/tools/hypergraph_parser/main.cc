#include <iostream>
#include <fstream>
#include <map>
#include "LineParser.hxx"
using namespace std; 

int main() {
  
  string theLine;           // line of text read from cin
  long ne, nv;              // number of hyperedges, vertices
  map<string, long> vdict;  // vertex name to number dictionary
  map<string, long> edict;  // hyperedge name to number dictionary

  long e, v;                // current edge, vertex

  ne = nv = 0;  // initial edge, vertex counters to zero

  while(getline(cin,theLine)) {
    LineParser LP(theLine); 

    // if no words on this line, skip it
    if (LP.size() == 0) continue;

    // Check if first character of first word is #
    if ( *(LP[0].c_str()) == '#') continue;


    // see if the first word is in the edict
    if (edict.count(LP[0]) == 0) {
      ++ne;
      edict[LP[0]] = ne;
    }
    e = edict[LP[0]];

    // scan through the rest of the line for vertices
    for (long idx=1; idx < LP.size(); idx++) {
      string vtx = LP[idx];
      if (vdict.count(vtx) == 0) {
	++nv;
	vdict[vtx] = nv;
      }
      v = vdict[vtx];
      cout << e << '\t' << v << endl;
    }

  }      
    

  return 0;

}

      
