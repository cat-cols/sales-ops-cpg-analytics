#!/usr/bin/env python3
"""
Script to manually render SchemaSpy .dot files to PNG images.
This works around SchemaSpy's Graphviz path configuration issues.
"""

import os
import subprocess
from pathlib import Path

def render_dot_files(schema_dir):
    """
    Render all .dot files in a SchemaSpy output directory to PNG images.
    """
    schema_path = Path(schema_dir)
    diagrams_dir = schema_path / "diagrams"
    
    if not diagrams_dir.exists():
        print(f"No diagrams directory found in {schema_dir}")
        return
    
    # Find all .dot files recursively
    dot_files = list(diagrams_dir.rglob("*.dot"))
    
    if not dot_files:
        print(f"No .dot files found in {diagrams_dir}")
        return
    
    print(f"Found {len(dot_files)} .dot files in {schema_dir}")
    
    rendered_count = 0
    failed_count = 0
    
    for dot_file in dot_files:
        # Output PNG file in the same directory as the .dot file
        png_file = dot_file.with_suffix('.png')
        
        try:
            # Render using dot command
            subprocess.run(
                ['dot', '-Tpng', str(dot_file), '-o', str(png_file)],
                check=True,
                capture_output=True,
                text=True
            )
            rendered_count += 1
            print(f"  ✓ Rendered: {dot_file.name}")
        except subprocess.CalledProcessError as e:
            failed_count += 1
            print(f"  ✗ Failed: {dot_file.name}")
            print(f"    Error: {e.stderr}")
    
    print(f"\nSummary for {schema_dir}:")
    print(f"  Rendered: {rendered_count}")
    print(f"  Failed: {failed_count}")

if __name__ == "__main__":
    # Base directory for SchemaSpy output
    base_dir = Path("/Users/b/DATA/PROJECTS/cannalytics-sales-ops-cpg/01_ops_command_center/docs")
    
    # Schema directories
    schemas = ["schema", "schema_stg", "schema_int", "schema_mart"]
    
    for schema in schemas:
        schema_dir = base_dir / schema
        if schema_dir.exists():
            print(f"\n{'='*60}")
            print(f"Processing: {schema}")
            print(f"{'='*60}")
            render_dot_files(schema_dir)
        else:
            print(f"Directory not found: {schema_dir}")
