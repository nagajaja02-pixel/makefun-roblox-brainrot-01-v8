"""Package twice into one existing directory; compare every emitted byte."""
from pathlib import Path
import os, subprocess, hashlib, json
root=Path(__file__).resolve().parents[1]
out=Path('/tmp/blitz-v7-output')
out.mkdir(exist_ok=True)
sentinel=out/'keep-existing-directory.txt'
sentinel.write_text('Preserve this directory and unrelated files.\n')
def digest(data): return hashlib.sha256(data).hexdigest()
def manifest():
    return {p.relative_to(out).as_posix():digest(p.read_bytes()) for p in sorted(out.rglob('*')) if p.is_file()}
env=dict(os.environ,MAKEFUN_OUTPUT_DIR=str(out))
subprocess.run(['node','main.ts'],cwd=root,env=env,check=True)
first=manifest()
subprocess.run(['node','main.ts'],cwd=root,env=env,check=True)
second=manifest()
assert first==second
assert sentinel.read_text()=='Preserve this directory and unrelated files.\n'
assert (root/'game.rbxl').read_bytes()==(out/'game.rbxl').read_bytes()
# Exclude only the unrelated sentinel from the output aggregate.
produced={k:v for k,v in second.items() if k!=sentinel.name}
report={'place_bytes':(root/'game.rbxl').stat().st_size,'place_sha256':second['game.rbxl'],
        'dossier_sha256':second['dossier.json'],
        'output_manifest_sha256':digest(json.dumps(produced,sort_keys=True,separators=(',',':')).encode()),
        'files':len(produced),'byte_identical':True,'existing_directory_preserved':True}
Path('/tmp/blitz-output-verification.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
