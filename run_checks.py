#!/usr/bin/env python3
"""Read-only GitSkills audit. Python standard library only; never runs dataset code."""
import argparse, collections, csv, hashlib, json, pathlib, platform, re, sqlite3, sys

def blocks(path):
    parts = re.split(r'^-- name: (.+)$', path.read_text(), flags=re.M)
    return [(parts[i],parts[i+1].strip()) for i in range(1,len(parts),2)]

def main():
    ap=argparse.ArgumentParser();ap.add_argument('database',type=pathlib.Path)
    ap.add_argument('--out',type=pathlib.Path,default=pathlib.Path('results'))
    args=ap.parse_args();args.out.mkdir(parents=True,exist_ok=True)
    c=sqlite3.connect(args.database.resolve().as_uri()+'?mode=ro',uri=True)
    c.row_factory=sqlite3.Row
    results={}
    root=pathlib.Path(__file__).resolve().parent
    for name,sql in blocks(root/'checks.sql'):
        results[name]=[dict(r) for r in c.execute(sql)]
    results['integrity_check']=[r[0] for r in c.execute('PRAGMA integrity_check')]
    n=bad=0
    for row in c.execute('SELECT file_sha,content FROM artifacts WHERE dedup_primary=1'):
        n+=1;b=row['content'].encode('utf-8')
        h=hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()
        bad+=(h!=row['file_sha'])
    results['independent_blob_hash_check']={'tested':n,'mismatches':bad}
    results['runtime']={'python':platform.python_version(),'sqlite':sqlite3.sqlite_version,
        'database_bytes':args.database.stat().st_size,
        'database_sha256':hashlib.sha256(args.database.read_bytes()).hexdigest()}
    (args.out/'observed_results.json').write_text(json.dumps(results,indent=2)+'\n')
    schema='\n\n'.join(r[0]+';' for r in c.execute(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name<>'sqlite_sequence' ORDER BY name"))
    (args.out/'schema.sql').write_text(schema+'\n')
    name,sql=blocks(root/'study.sql')[0];rows=[dict(r) for r in c.execute(sql)]
    with (args.out/'group_features.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    strata=collections.Counter(r['reuse_stratum'] for r in rows)
    summary={'eligible_groups':len(rows),'strata':dict(sorted(strata.items())),
        'complete_composition':sum(r['composition_fetched']==1 and r['composition_truncated']==0 for r in rows)}
    # Deterministic randomized ordering within strata, independent of labels.
    selected=[]
    for stratum in sorted(strata):
        pool=[r for r in rows if r['reuse_stratum']==stratum]
        pool.sort(key=lambda r:hashlib.sha256(('cs599-label-v1:'+r['file_sha']).encode()).hexdigest())
        selected+=pool[:80]
    # Blank forms are a sampling frame, not completed manual labels.
    fields=['file_sha','repo_full_name','path','reuse_stratum','verification_level',
        'evidence_lines','explicit_local_reference','resolution_status','notes']
    with (args.out/'label_sample_uncompleted.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=fields);w.writeheader()
        for r in selected:w.writerow({k:r.get(k,'') for k in fields})
    (args.out/'study_summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps({'audit':results,'study':summary},indent=2))
if __name__=='__main__':main()
