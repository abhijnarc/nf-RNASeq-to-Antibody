import os
from pyfasta import Fasta
from igfold import IgFoldRunner

# Initialize IgFold once
igfold = IgFoldRunner()

# Loop through all .fa files in the current directory
for fasta_file in sorted(f for f in os.listdir('.') if f.endswith('.fa')):
    try:
        prefix = os.path.splitext(fasta_file)[0]
        pred_pdb = prefix + '_igf.pdb'

        print(f"Running IgFold on: {fasta_file}")

        # Read the FASTA file (should contain only >VH)
        this_seq = Fasta(fasta_file)
        vh_seq = str(this_seq['VH'])

        # Prepare input for IgFold
        abseq = {'H': vh_seq}

        # Run IgFold
        igfold.fold(
            pred_pdb,
            sequences=abseq,
            do_refine=True,
            use_openmm=True,
            do_renum=False
        )

        print(f"✅ Saved: {pred_pdb}\n")

    except Exception as e:
        print(f"❌ Error processing {fasta_file}: {e}")
