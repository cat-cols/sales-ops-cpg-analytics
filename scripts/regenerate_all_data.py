#!/usr/bin/env python3
"""
Master script to regenerate data for all projects.
This script calls each project's generator in sequence.
Run from repo root: python scripts/regenerate_all_data.py
"""

import subprocess
import sys
from pathlib import Path


def run_generator(project_name: str, script_path: Path, repo_root: Path) -> bool:
    """Run a single project generator and return success status."""
    print(f"Generating {project_name} data...")
    try:
        result = subprocess.run(
            [sys.executable, str(script_path)],
            cwd=repo_root,
            check=True,
            capture_output=False,
        )
        print(f"✓ {project_name} complete")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ {project_name} failed with exit code {e.returncode}")
        return False
    except FileNotFoundError:
        print(f"✗ {project_name} script not found: {script_path}")
        return False


def main() -> None:
    print("=" * 42)
    print("Regenerating data for all projects")
    print("=" * 42)
    print()

    # Get repo root (parent of scripts directory)
    repo_root = Path(__file__).parent.parent

    generators = [
        ("Project 1: Ops Command Center", repo_root / "01_ops_command_center" / "scripts" / "generate_project1_data.py"),
        ("Project 2: Quarterly DC QA/QC System", repo_root / "02_quarterly_dc_qaqc_system" / "scripts" / "generate_project2_dq_inputs.py"),
        ("Project 3: Forecasting + Variance Story", repo_root / "03_forecasting_variance_story" / "scripts" / "generate_project3_forecast_inputs.py"),
        ("Project 4: GHG Scope Reporting", repo_root / "04_ghg_scope_reporting" / "scripts" / "generate_project4_ghg_inputs.py"),
    ]

    results = []
    for project_name, script_path in generators:
        success = run_generator(project_name, script_path, repo_root)
        results.append((project_name, success))
        print()

    print("=" * 42)
    if all(success for _, success in results):
        print("All project data regenerated successfully!")
    else:
        print("Some generators failed:")
        for project_name, success in results:
            if not success:
                print(f"  ✗ {project_name}")
        sys.exit(1)
    print("=" * 42)


if __name__ == "__main__":
    main()
