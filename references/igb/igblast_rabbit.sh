#!/bin/bash

# Input FASTA files
V_GENES=("IGHV_rabbit.fasta" "IGKV_rabbit.fasta" "IGLV_rabbit.fasta")
D_GENES=("IGHD_rabbit.fasta")
J_GENES=("IGHJ_rabbit.fasta" "IGKJ_rabbit.fasta" "IGLJ_rabbit.fasta")

# Clean all FASTA files
echo "🧼 Cleaning FASTA files..."
for file in "${V_GENES[@]}" "${D_GENES[@]}" "${J_GENES[@]}"; do
    if [[ -f "$file" ]]; then
        clean_file="${file%.fasta}_clean.fasta"
        sed '/^>/!s/[^ATGCatgcNn]//g' "$file" > "$clean_file"
        echo "✅ Cleaned $file → $clean_file"
    else
        echo "⚠️ File not found: $file"
    fi
done

# Create BLAST databases
echo "🔧 Creating BLAST databases from cleaned files..."
for file in *_clean.fasta; do
    makeblastdb -parse_seqids -dbtype nucl -in "$file"
    echo "✅ Created DB for $file"
done

# Create .gl and .aux files using cleaned file names
echo "📄 Creating .gl and .aux files..."

cat > rabbit_gl_V <<EOF
IGHV IGHV_rabbit_clean.fasta
IGKV IGKV_rabbit_clean.fasta
IGLV IGLV_rabbit_clean.fasta
EOF

cat > rabbit_gl_D <<EOF
IGHD IGHD_rabbit_clean.fasta
EOF

cat > rabbit_gl_J <<EOF
IGHJ IGHJ_rabbit_clean.fasta
IGKJ IGKJ_rabbit_clean.fasta
IGLJ IGLJ_rabbit_clean.fasta
EOF

cat > rabbit_gl.aux <<EOF
IGHV rabbit_gl_V
IGKV rabbit_gl_V
IGLV rabbit_gl_V
IGHD rabbit_gl_D
IGHJ rabbit_gl_J
IGKJ rabbit_gl_J
IGLJ rabbit_gl_J
EOF

echo "✅ Setup complete!"
echo ""
echo "🧪 Sample igblastn command:"
echo ""
echo "igblastn -query your_sequences.fa \\"
echo "         -germline_db_V IGHV_rabbit_clean.fasta \\"
echo "         -germline_db_D IGHD_rabbit_clean.fasta \\"
echo "         -germline_db_J IGHJ_rabbit_clean.fasta \\"
echo "         -auxiliary_data rabbit_gl.aux \\"
echo "         -domain_system imgt -organism rabbit \\"
echo "         -out results.txt"
