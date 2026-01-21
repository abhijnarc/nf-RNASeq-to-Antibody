import csv
from Bio import SeqIO
import sys

cluster_tsv   = sys.argv[1]   # e.g. all_groups_Hclusters.tsv (cross-group)
target_group  = sys.argv[2]   # e.g. CAD (the target group to filter)
input_fasta   = sys.argv[3]   # e.g. CAD_heavy.fa
output_fasta  = sys.argv[4]   # e.g. CAD_heavy_unique.fa

# Control group is hardcoded as 'CTL' (adjust if needed)
control_group = 'CTL'

def ids_to_remove(tsv_file, target, control):
    """
    Remove target-group IDs that cluster with control-group IDs.
    
    For cross-group clustering:
    - Parse clusters from the combined file
    - Find clusters that contain both target and control sequences
    - Mark all target sequences in such clusters for removal
    """
    remove = set()

    with open(tsv_file) as f:
        reader = csv.reader(f, delimiter="\t")
        for row in reader:
            ids = [x.strip() for x in row if x.strip()]

            target_ids = [x for x in ids if x.startswith(f"{target}_")]
            control_ids = [x for x in ids if x.startswith(f"{control}_")]

            # If this cluster has BOTH target AND control sequences,
            # remove the target sequences (they are similar to control)
            if target_ids and control_ids:
                remove.update(target_ids)

    return remove


remove_ids = ids_to_remove(cluster_tsv, target_group, control_group)

kept = []
for rec in SeqIO.parse(input_fasta, "fasta"):
    if rec.id not in remove_ids:
        kept.append(rec)

SeqIO.write(kept, output_fasta, "fasta")

print(f"Target group: {target_group}")
print(f"Control group: {control_group}")
print(f"Removed {len(remove_ids)} sequences (similar to control)")
print(f"Kept {len(kept)} sequences (unique to target)")
