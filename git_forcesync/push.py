import subprocess
import os

# Configuration
parent_directory = "/home/jddesk/jdDeskCodeLab/coding_jd"
remote_name = "secondary"
jd_branch_appendix = "_jd_codex"
remote_repo_template = "git@coding.jd.com:lichang93/{repo_name}.git"
failed_repos = []  # List to store repositories that fail to push


def run_command(command, cwd=None, env=None):
  """Run a shell command in the specified working directory and handle output."""
  result = subprocess.run(
      command, shell=True, text=True, capture_output=True, cwd=cwd, env=env)
  if result.returncode != 0:
    import pdb; pdb.set_trace()
    print(f"Error in {cwd}: {result.stderr}")
  return result.stdout, result.stderr, result.returncode


def find_git_repositories(parent_directory):
  """Find all subdirectories in the parent directory that are Git repositories."""
  return [
      f.path
      for f in os.scandir(parent_directory)
      if f.is_dir() and os.path.isdir(os.path.join(f.path, '.git'))
  ]


def force_git_checkout(repo_path, branch_name):
  """Force checkout a branch, creating it from origin if necessary."""
  run_command(
      f"git checkout {branch_name} || git checkout -b {branch_name} origin/{branch_name}",
      cwd=repo_path)


def force_git_remove_branch(repo_path, branch_name):
  """Force remove a branch if it exists."""
  stdout, stderr, returncode = run_command(
      f"git branch --list {branch_name}", cwd=repo_path)
  # import pdb
  # pdb.set_trace()
  if stdout.strip():
    branches_output, _, _ = run_command("git branch -r", cwd=repo_path)
    branches = [
        branch.strip()
        for branch in branches_output.strip().split('\n')
        if branch.strip() and not 'HEAD' in branch and not remote_name in branch
    ]

    run_command(
        f"git checkout {branches[0]}",
        cwd=repo_path)  # Checkout previous branch
    run_command(f"git branch -D {branch_name}", cwd=repo_path)


def force_git_clean(repo_path):
  """Force clean the working directory."""
  run_command("git clean -fdx", cwd=repo_path)


def force_git_fetch(repo_path):
  """Force fetch from origin."""
  run_command("git fetch origin --force --prune", cwd=repo_path)


def force_git_push(repo_path, branch_name, remote_name):
  """Force push a branch to the remote."""
  run_command(f"git push {remote_name} {branch_name} --force", cwd=repo_path)


def force_git_reassign_commits(repo_path, branch_name):
  """Reassign the commits of a branch to a new branch with specified author and committer details."""
  new_branch = branch_name.strip().replace("origin/",
                                           "") + f'{jd_branch_appendix}'
  # import pdb
  # pdb.set_trace()

  force_git_remove_branch(repo_path, new_branch)
  run_command(f"git checkout -b {new_branch} {branch_name}", cwd=repo_path)

  # Call the resign.sh script
  resign_script_path = os.path.join(os.path.dirname(__file__), 'resign.sh')
  run_command(f"{resign_script_path} {repo_path} {new_branch}", cwd=repo_path)

  return new_branch


def force_sync_with_github(repo_path):
  """Forcefully synchronize the local repository with the GitHub version and push to the secondary remote."""
  repo_name = os.path.basename(repo_path)
  remote_repo = remote_repo_template.format(
      repo_name=repo_name)  # Format remote repo URL based on folder name

  print(f"Force syncing repository located at {repo_path}")
  force_git_fetch(repo_path)
  branches_output, _, _ = run_command("git branch -r", cwd=repo_path)
  branches = [
      branch.strip()
      for branch in branches_output.strip().split('\n')
      if branch.strip() and not 'HEAD' in branch and not remote_name in branch
  ]

  for branch_name in branches:
    # import pdb
    # pdb.set_trace()
    force_git_clean(repo_path)

    # Reassign commits to a new branch
    new_branch = force_git_reassign_commits(repo_path, branch_name)

    # Ensure the remote is added (does nothing if already exists)
    run_command(
        f"git remote add {remote_name} {remote_repo} || true", cwd=repo_path)
    # Force push the new branch to the secondary remote
    force_git_push(repo_path, new_branch, remote_name)


if __name__ == "__main__":
  repositories = find_git_repositories(parent_directory)
  for repo_path in repositories:
    force_sync_with_github(repo_path)
  if failed_repos:
    print("Failed to push the following repositories:")
    for repo in failed_repos:
      print(repo)
