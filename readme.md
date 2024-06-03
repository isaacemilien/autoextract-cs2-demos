# AutoExtract-CS2-Demos

## Overview

This PowerShell script automates the extraction and movement of CS2 demo files downloaded from FaceIt. It runs via Windows Task Scheduler, monitoring a download directory for `.dem.gz` files, extracting them, ensuring unique names, and moving them to the CS2 demos directory.

## Features

- **Automatic Monitoring**: Monitors the download directory for new demo files.
- **Automatic Extraction**: Extracts `.dem.gz` files to `.dem`.
- **Unique Naming**: Ensures extracted files have unique names.
- **Automatic Movement**: Moves extracted files to the CS2 demos directory.

## Requirements

- Windows PowerShell
- Windows Task Scheduler

## Installation

1. **Clone the repository:**

   ```sh
   git clone https://github.com/isaacemilien/autoextract-cs2-demos.git
   ```

2. **Edit the script:**

   Update `processFaceitDemos.ps1` with your paths:

   ```powershell
   $sourcePath = "C:\path\to\downloads\folder"
   $destinationPath = "C:\path\to\destination\folder"
   ```

## Usage

1. **Set up Windows Task Scheduler:**

   - Create a new task.
   - Name it (e.g., "AutoExtract CS2 Demos").
   - Set it to run with highest privileges.
   - Add a trigger to run at startup and repeat if desired.
   - Add an action:
     - Program/script: `powershell.exe`
     - Add arguments: `-File "C:\path\to\processFaceitDemos.ps1"`
   - Ensure it runs even if the user is not logged in.
   - Save the task.

2. **Run manually (optional):**

   ```powershell
   .\processFaceitDemos.ps1
   ```