"""Exercise real Git worktree and Beads routing in disposable project homes."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

SOFTWARE = Path(__file__).resolve().parents[1]


def run(*args, cwd, env=None):
    result = subprocess.run(args, cwd=cwd, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode:
        raise RuntimeError(f"{args}: {result.stdout}\n{result.stderr}")
    return result.stdout.strip()


with tempfile.TemporaryDirectory(prefix="rig-topology-") as temporary:
    root = Path(temporary)
    source = root / "source"
    source.mkdir()
    run("git", "init", "-b", "main", cwd=source)
    run("git", "-c", "user.name=Rig Test", "-c", "user.email=rig@example.invalid",
        "commit", "--allow-empty", "-m", "Core base", cwd=source)
    homes = []
    for number in (1, 2):
        home = root / f"project-{number}"
        shutil.copytree(SOFTWARE / "templates/instance", home)
        (home / "rig.toml").write_text(
            f'software_root = "{SOFTWARE}"\nproject_root = "../source"\n')
        run("git", "init", "-b", "main", cwd=home)
        env = dict(os.environ, RIG_INSTANCE_ROOT=str(home))
        env.pop("BEADS_DIR", None)
        env["RIG_EMACS_BIN"] = "/usr/bin/printenv"
        # A recorder checks launcher wiring without starting an agent runtime.
        recorder = root / f"record-launch-{number}"
        recorder.write_text('#!/bin/sh\nprintf "%s\\n" "$RIG_INSTANCE_ROOT" "$@"\n')
        recorder.chmod(0o755)
        env["RIG_EMACS_BIN"] = str(recorder)
        launch = run(str(home / "rig"), cwd=home, env=env)
        assert str(home) in launch and str(SOFTWARE / "emacs/rig.el") in launch
        worker_launch = run(str(home / "rig"), "probe", cwd=home, env=env)
        assert '(rig-fleet-member "probe")' in worker_launch
        run("bd", "init", "--prefix", f"project{number}", "--skip-hooks",
            "--skip-agents", "--non-interactive", cwd=home, env=env)
        worker = home / "fleet/probe"
        worker.mkdir(parents=True)
        (worker / "member.toml").write_text(
            f'slug = "probe"\nworktree = "worktree"\n'
            f'branch = "probe-{number}"\nintegration_branch = "main"\n')
        run(str(SOFTWARE / "bin/rig-fleet-onboard"), "--check", "probe",
            cwd=home, env=env)
        run(str(SOFTWARE / "bin/rig-fleet-onboard"), "probe", cwd=home, env=env)
        worktree = worker / "worktree"
        env["BEADS_DIR"] = str(home / ".beads")
        issue = run("bd", "create", f"Project {number} evidence", "--silent",
                    cwd=worktree, env=env)
        assert issue.startswith(f"project{number}-"), issue
        assert str(home / ".beads") in run("bd", "where", cwd=worktree, env=env)
        assert not (worktree / "fleet").exists()
        (worktree / f"change-{number}.txt").write_text("Core-only implementation evidence\n")
        run("git", "add", f"change-{number}.txt", cwd=worktree)
        run("git", "-c", "user.name=Rig Test", "-c", "user.email=rig@example.invalid",
            "commit", "-m", f"Worker {number} core change",
            cwd=worktree)
        run("git", "merge", "--ff-only", f"probe-{number}", cwd=source)
        assert run("git", "ls-tree", "--name-only", "HEAD", cwd=source).splitlines() == [
            f"change-{i}.txt" for i in range(1, number + 1)]
        homes.append((home, env, issue))
    for home, env, issue in homes:
        listing = run("bd", "list", "--json", cwd=home, env=env)
        assert issue in listing
        other = homes[1][2] if issue == homes[0][2] else homes[0][2]
        assert other not in listing
    print("PASS: two independent operating repositories/databases, worker routing, "
          "main-based worktrees, and core-only fast-forward integration")
