#!/usr/bin/env python3
"""Mutate ranking/filter guards in disposable copies; never edit the working source."""
import os
import pathlib
import shutil
import subprocess
import tempfile

root = pathlib.Path(__file__).resolve().parent.parent
source = (root / 'Model.lua').read_text()
mutations = [
    ('completed filter', 'showCompleted or not r.completed', 'true'),
    ('zero filter', 'showZero or r.fraction == nil or r.fraction > 0', 'true'),
    ('unknown last', 'if b.fraction == nil then return true end', 'if b.fraction == nil then return false end'),
    ('descending progress', 'return a.fraction > b.fraction', 'return a.fraction < b.fraction'),
    ('remaining tiebreak', 'return (a.units or math.huge) < (b.units or math.huge)',
     'return (a.units or math.huge) > (b.units or math.huge)'),
]
with tempfile.TemporaryDirectory(prefix='kwiklegacy-mutation-', dir=os.environ.get('TMPDIR')) as tmp:
    path = pathlib.Path(tmp)
    (path / 'tests').mkdir()
    shutil.copy2(root / 'tests/model.lua', path / 'tests/model.lua')
    for name, old, new in mutations:
        assert source.count(old) == 1, 'pattern count is not one: ' + name
        (path / 'Model.lua').write_text(source.replace(old, new, 1))
        proc = subprocess.run(['lua5.1', 'tests/model.lua'], cwd=path, capture_output=True, text=True)
        print(f'{name}: {"killed" if proc.returncode else "SURVIVED"} (failing suite runs: {int(proc.returncode != 0)})')
        if proc.returncode == 0:
            raise SystemExit(1)
print('mutation checks: PASS')
