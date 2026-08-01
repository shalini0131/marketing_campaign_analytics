"""
download_data.py — Dataset Acquisition Script
===============================================
Downloads the 'Online Shoppers Purchasing Intention' dataset from the
UCI Machine Learning Repository and saves it to the data/ directory.

Dataset Details:
    Source:   UCI Machine Learning Repository
    URL:      https://archive.ics.uci.edu/dataset/468
    Records:  12,330 user sessions
    Features: 18 attributes (10 numerical, 8 categorical)
    License:  CC BY 4.0 International
    Publisher: Sakar, C.O., Polat, S.O., Katircioglu, M. et al. (2019)
"""
import os
import sys
import urllib.request

# ── Configuration ────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'data')
CSV_PATH = os.path.join(DATA_DIR, 'online_shoppers_intention.csv')

DATASET_URL = (
    'https://archive.ics.uci.edu/ml/machine-learning-databases'
    '/00468/online_shoppers_intention.csv'
)


def download_dataset():
    """Download the UCI dataset if it does not already exist locally."""
    os.makedirs(DATA_DIR, exist_ok=True)

    if os.path.exists(CSV_PATH):
        file_size = os.path.getsize(CSV_PATH)
        print(f"[INFO] Dataset already exists at: {os.path.abspath(CSV_PATH)}")
        print(f"[INFO] File size: {file_size / 1024:.1f} KB")
        return CSV_PATH

    print("=" * 60)
    print("DOWNLOADING DATASET")
    print("=" * 60)
    print(f"Source:      UCI Machine Learning Repository")
    print(f"Dataset:     Online Shoppers Purchasing Intention")
    print(f"URL:         {DATASET_URL}")
    print(f"Saving to:   {os.path.abspath(CSV_PATH)}")
    print("-" * 60)

    try:
        urllib.request.urlretrieve(DATASET_URL, CSV_PATH)
        file_size = os.path.getsize(CSV_PATH)
        print(f"[SUCCESS] Download complete!")
        print(f"[INFO]    File size: {file_size / 1024:.1f} KB")
        print(f"[INFO]    Location:  {os.path.abspath(CSV_PATH)}")
    except urllib.error.URLError as e:
        print(f"[ERROR] Failed to download: {e}")
        print(f"[INFO]  Please download manually from:")
        print(f"        {DATASET_URL}")
        print(f"        Save the file as: {os.path.abspath(CSV_PATH)}")
        sys.exit(1)

    return CSV_PATH


if __name__ == '__main__':
    path = download_dataset()
    print(f"\nDataset ready at: {path}")
    print("Next step: Run 'python python/etl.py' to load into MySQL.")
