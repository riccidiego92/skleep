from __future__ import annotations

import argparse
import json
from pathlib import Path

import pandas as pd

from wfl_compute.p43_p42_train_screen import (
    registry_by_id,
    streaming_train_evaluation,
    train_frame_from_full_history,
)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("candidate_id")
    ap.add_argument("--reps", type=int, default=2000)
    ap.add_argument("--history", default="data/wfl_train_public.csv")
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    if args.reps not in (2000, 100000):
        raise SystemExit("public lane allows only frozen reps: 2000 or 100000")
    if args.candidate_id not in registry_by_id():
        raise SystemExit("unknown P42 candidate_id")

    full = pd.read_csv(args.history)
    train = train_frame_from_full_history(full)
    result = streaming_train_evaluation(train, args.candidate_id, args.reps)
    result["public_compute_lane"] = {
        "train_only": True,
        "validation_present": False,
        "holdout_present": False,
        "source_dataset": "data/wfl_train_public.csv",
    }
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
