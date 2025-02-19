
import os
import sys
import subprocess

def print_banner():
    """Prints a stylish banner."""
    print("\n\033[94m" + "=" * 40)
    print("         Git Pusher Script")
    print("=" * 40 + "\033[0m\n")

def check_git_repo(directory):
    """Check if the given directory is a Git repository."""
    if not os.path.isdir(os.path.join(directory, '.git')):
        print("\033[91m❌ Error: No Git repository found in the given directory.\033[0m")
        sys.exit(1)

def list_files(directory):
    """List all files in the Git repository."""
    print("\033[93m📂 Files in the repository:\033[0m")
    for root, _, files in os.walk(directory):
        for file in files:
            print(f"  - {os.path.relpath(os.path.join(root, file), directory)}")
    print("\n")

def check_remote_repo():
    """Check if a remote repository is set up."""
    try:
        remotes = subprocess.check_output(['git', 'remote'], text=True).strip()
        if not remotes:
            print("\033[91m❌ Error: No remote repository configured.\033[0m")
            sys.exit(1)
    except subprocess.CalledProcessError:
        print("\033[91m❌ Error: Failed to check remote repository.\033[0m")
        sys.exit(1)

def check_and_push_changes():
    """Check for unpushed commits and push them."""
    try:
        push_needed = subprocess.check_output(['git', 'cherry', '-v'], text=True).strip()
        if push_needed:
            print("\033[96m🚀 Pushing unpushed commits...\033[0m")
            subprocess.run(['git', 'push'], check=True)
            print("\033[92m✅ All changes pushed successfully!\033[0m")
        else:
            print("\033[92m✅ No unpushed changes found.\033[0m")
    except subprocess.CalledProcessError:
        print("\033[91m❌ Error: Failed to check or push changes.\033[0m")
        sys.exit(1)

def add_commit_push_files():
    """Add, commit, and push files one by one until all are pushed."""
    try:
        while True:
            status_output = subprocess.check_output(['git', 'status', '--porcelain'], text=True).strip()
            files = [line[3:] for line in status_output.split('\n') if line]
            
            if not files:
                print("\033[92m✅ All files have been committed and pushed.\033[0m")
                break
            
            file = files[0]
            print(f"\033[94m➕ Adding {file}...\033[0m")
            subprocess.run(['git', 'add', file], check=True)
            print(f"\033[96m📝 Committing {file}...\033[0m")
            subprocess.run(['git', 'commit', '-m', f'Adding {file}'], check=True)
            print(f"\033[93m🚀 Pushing {file}...\033[0m")
            subprocess.run(['git', 'push'], check=True)
            print(f"\033[92m✅ {file} pushed successfully!\033[0m\n")
    except subprocess.CalledProcessError:
        print("\033[91m❌ Error: Failed to add, commit, or push files.\033[0m")
        sys.exit(1)

def main():
    print_banner()
    if len(sys.argv) != 2:
        print("\033[93m📌 Usage: python gitpusher.py <directory>\033[0m")
        sys.exit(1)
    
    directory = sys.argv[1]
    if not os.path.isdir(directory):
        print("\033[91m❌ Error: The given directory does not exist.\033[0m")
        sys.exit(1)
    
    os.chdir(directory)
    check_git_repo(directory)
    list_files(directory)
    check_remote_repo()
    add_commit_push_files()
    check_and_push_changes()

if __name__ == "__main__":
    main()

