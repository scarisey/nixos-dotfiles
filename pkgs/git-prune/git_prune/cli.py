import sys
from git import Repo


def prune():
    path = "./"
    if len(sys.argv) == 2:
        path = sys.argv[1]
    repo = Repo(path)
    remoteName = repo.remote().name
    local_branches = repo.heads
    remote_branches = [
        ref.name.replace(f"{remoteName}/", "") for ref in repo.remote().refs
    ]
    print(remote_branches)
    local_branches_no_remote = [
        branch.name
        for branch in local_branches
        if branch.name not in [r for r in remote_branches]
        and branch.name != repo.head.ref.name
    ]

    print(f"Current HEAD: {repo.head.ref.name}")

    print("Local branches that have no remote counterpart and not HEAD:")
    for branch in local_branches_no_remote:
        print(branch)
    response = input("Do you want to delete all these branches ? (y/n): ").lower()
    if response in ["y", "yes"]:
        for branch in local_branches_no_remote:
            repo.delete_head(branch, force=True)


if __name__ == "__main__":
    prune()
