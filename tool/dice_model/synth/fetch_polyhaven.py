"""Download CC0 floor textures and HDRIs from Poly Haven for the synthetic dice scenes.

Poly Haven assets are CC0 (https://polyhaven.com/license): no attribution is
required, and they can be used to train a model shipped in an MIT app. The list
of downloaded assets is written to <out>/manifest.json.

Standard library only. Usage:
    python fetch_polyhaven.py --out D:/satowiki-dice/assets
"""

from __future__ import annotations

import argparse
import json
import random
import sys
import time
import urllib.request
from pathlib import Path

API = "https://api.polyhaven.com"
USER_AGENT = "SatoWiki-dice-synth/1.0 (github.com/Dado-hash/Sato-Wiki)"

# Surfaces a person might roll dice on, and how many textures to take from each.
TEXTURE_CATEGORIES = {
    "wood": 45,
    "fabric": 25,
    "floor": 25,
    "plaster-concrete": 15,
    "tiles": 10,
    "leather": 6,
    "rock": 10,
    "metal": 8,
}
# Indoor light first: dice are rolled at a desk or a table.
HDRI_CATEGORIES = {"indoor": 45, "studio": 15, "artificial light": 15, "outdoor": 10}
TEXTURE_MAPS = {"diff": "Diffuse", "nor": "nor_gl", "rough": "Rough"}


def get_json(url: str):
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=60) as response:
        return json.load(response)


def download(url: str, target: Path) -> None:
    if target.exists() and target.stat().st_size > 0:
        return
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    partial = target.with_suffix(target.suffix + ".part")
    with urllib.request.urlopen(request, timeout=120) as response, partial.open("wb") as handle:
        while chunk := response.read(1 << 16):
            handle.write(chunk)
    partial.replace(target)


def pick(asset_type: str, categories: dict, rng: random.Random) -> list:
    chosen: list = []
    for category, count in categories.items():
        assets = get_json(f"{API}/assets?t={asset_type}&c={urllib.request.quote(category)}")
        ids = sorted(set(assets) - set(chosen))
        rng.shuffle(ids)
        chosen.extend(ids[:count])
    return chosen


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--resolution", default="1k", help="Poly Haven resolution key (default 1k).")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    rng = random.Random(args.seed)
    textures_dir = args.out / "textures"
    hdris_dir = args.out / "hdris"
    textures_dir.mkdir(parents=True, exist_ok=True)
    hdris_dir.mkdir(parents=True, exist_ok=True)
    manifest = {"source": "https://polyhaven.com", "license": "CC0", "textures": [], "hdris": []}

    texture_ids = pick("textures", TEXTURE_CATEGORIES, rng)
    for n, asset_id in enumerate(texture_ids, 1):
        files = get_json(f"{API}/files/{asset_id}")
        entry = {"id": asset_id}
        for short, key in TEXTURE_MAPS.items():
            jpg = files.get(key, {}).get(args.resolution, {}).get("jpg")
            if jpg:
                target = textures_dir / f"{asset_id}_{short}.jpg"
                download(jpg["url"], target)
                entry[short] = target.name
        if "diff" in entry:
            manifest["textures"].append(entry)
        print(f"texture {n}/{len(texture_ids)} {asset_id}", flush=True)
        time.sleep(0.1)

    hdri_ids = pick("hdris", HDRI_CATEGORIES, rng)
    for n, asset_id in enumerate(hdri_ids, 1):
        files = get_json(f"{API}/files/{asset_id}")
        hdr = files.get("hdri", {}).get(args.resolution, {}).get("hdr")
        if hdr:
            target = hdris_dir / f"{asset_id}.hdr"
            download(hdr["url"], target)
            manifest["hdris"].append({"id": asset_id, "file": target.name})
        print(f"hdri {n}/{len(hdri_ids)} {asset_id}", flush=True)
        time.sleep(0.1)

    (args.out / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(f"{len(manifest['textures'])} textures, {len(manifest['hdris'])} HDRIs in {args.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
