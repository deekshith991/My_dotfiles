
import argparse
import os
import subprocess

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Git Committer Script")
parser.add_argument("--dir", required=True, help="Directory location of the repository")
args = parser.parse_args()

# Store directory in a constant
REPO = args.dir

# Check if the directory is a Git repository
git_dir = os.path.join(REPO, ".git")
if os.path.isdir(git_dir):
    print(f"Repository directory set to: {REPO}")
    print("Git repository detected.")
    
    # Read .gitignore file if it exists
    gitignore_path = os.path.join(REPO, ".gitignore")
    ignored_files = set()
    if os.path.isfile(gitignore_path):
        with open(gitignore_path, "r") as f:
            ignored_files = {line.strip() for line in f if line.strip() and not line.startswith("#")}
    
    # List all files in the repository, excluding .git and ignored files
    files = []
    for root, _, filenames in os.walk(REPO):
        if ".git" in root:
            continue
        for filename in filenames:
            rel_path = os.path.relpath(os.path.join(root, filename), REPO)
            if rel_path not in ignored_files:
                files.append(os.path.join(root, filename))
    
    print("Files in repository:")
    for file in files:
        print(file)
    
    # Commit and push files one by one
    while files:
        file_to_commit = files.pop(0)
        try:
            print(f"Adding {file_to_commit} to staging area...")
            subprocess.run(["git", "add", file_to_commit], cwd=REPO, check=True)
            
            print(f"Committing {file_to_commit}...")
            subprocess.run(["git", "commit", "-m", f"Auto-committing {file_to_commit}"], cwd=REPO, check=True)
            
            print("Pushing changes to remote repository...")
            subprocess.run(["git", "push"], cwd=REPO, check=True)
            
            print(f"Successfully processed {file_to_commit}.")
        except subprocess.CalledProcessError as e:
            print(f"Error processing {file_to_commit}: {e}")
else:
    print(f"Repository directory set to: {REPO}")
    print("No Git repository found in the specified directory.")

