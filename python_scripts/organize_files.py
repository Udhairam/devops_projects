import os
import shutil
from pathlib import Path

def organize_downloads(download_folder: str):
    file_types = {
        'Images': ['.jpg', '.jpeg', '.png', '.gif', '.bmp'],
        'Documents': ['.pdf', '.docx', '.doc', '.txt', '.xlsx', '.pptx'],
        'Audio': ['.mp3', '.wav', '.aac'],
        'Videos': ['.mp4', '.mov', '.avi', '.mkv'],
        'Archives': ['.zip', '.rar', '.tar', '.gz'],
        'Scripts': ['.py', '.sh', '.bat', '.ps1']
    }

    download_path = Path(download_folder)

    if not download_path.exists():
        print(f"Folder not found: {download_folder}")
        return

    for file in download_path.iterdir():
        if file.is_file():
            file_ext = file.suffix.lower()
            for category, extensions in file_types.items():
                if file_ext in extensions:
                    target_dir = download_path / category
                    target_dir.mkdir(exist_ok=True)
                    try:
                        shutil.move(str(file), str(target_dir / file.name))
                        print(f"✅ Moved: {file.name} → {category}/")
                    except Exception as e:
                        print(f"⚠️ Error moving {file.name}: {e}")
                    break

if __name__ == "__main__":
    # Use raw string or double backslashes for Windows paths
    organize_downloads(r"C:\Users\swath\Downloads")
