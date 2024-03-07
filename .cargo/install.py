import json
import subprocess
import sys

ERROR_EXIT_CODE = -1

if __name__ == "__main__":
    with open(".crates2.json") as f:
        crates_json = json.loads(f.read())

    for crate in crates_json["installs"].keys():
        name, version, registry = crate.split(" ")
        process = subprocess.Popen(
            ["cargo", "install", "--version", version, name],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        sys.stdout.write(f"\r🟡 Installing.. {name}=={version}")
        sys.stdout.flush()

        stdout, stderr = process.communicate()
        stderr = stderr.decode()
        if process.returncode != 0:
            sys.stdout.write(f"\r🔴 There was problem installing {name}=={version}")
            sys.stdout.write(f"Full output:\n")
            sys.stderr.write(stderr)
            exit(ERROR_EXIT_CODE)

        if "already installed" in stderr:
            sys.stdout.write(f"\r🟡 Already installed {name}=={version}. Skipping..\n")
        else:
            sys.stdout.write(f"\r🟢 Installed {name}=={version}   \n")

    sys.stdout.write(f"\n🎉 Success, all packages installed! 🎉\n")
