# code to build full (VH-VL) antibody model
import sys
from pyfasta import Fasta
from igfold import IgFoldRunner
from collections.abc import Mapping
"""
sequences = {
    "H": "EVQLVQSGPEVKKPGTSVKVSCKASGFTFMSSAVQWVRQARGQRLEWIGWIVIGSGNTNYAQKFQERVTITRDMSTSTAYMELSSLRSEDTAVYYCAAPYCSSISCNDGFDIWGQGTMVTVS",
    "L": "DVVMTQTPFSLPVSLGDQASISCRSSQSLVHSNGNTYLHWYLQKPGQSPKLLIYKVSNRFSGVPDRFSGSGSGTDFTLKISRVEAEDLGVYFCSQSTHVPYTFGGGTKLEIK"
}
"""
# get file prefix from command line'
pref = sys.argv[1]
#pref = 'M2-A96Y'
fasta_file = pref +'.fa'
pred_pdb = pref + '_igf.pdb'


# read the fasta file
this_seq = Fasta(fasta_file)

# set the Fasta to an antibody dict
abseq = {
    'H': str(this_seq['VH']),
    'L': str(this_seq['VL'])
}

# create an igfold object
igfold = IgFoldRunner()

# check available methods
#dir(igfold)

out = igfold.fold(
    pred_pdb, # Output PDB file
    sequences=abseq, # Antibody sequences
    do_refine=True, # Refine the antibody structure with PyRosetta
    use_openmm=True, # Use OpenMM for refinement
    do_renum=False, # Renumber predicted antibody structure (Chothia)
)

