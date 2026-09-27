from __future__ import annotations

import json
import pandas as pd
from wfl_compute.p43_p42_train_screen import registry_rows


def main() -> None:
    df = pd.read_csv("data/wfl_train_public.csv")
    expected = ["date","time",*[f"n{i}" for i in range(1,11)],"numerone"]
    if list(df.columns) != expected:
        raise SystemExit("unexpected public TRAIN schema")
    dates = pd.to_datetime(df["date"], errors="raise")
    if dates.min() < pd.Timestamp("2013-01-21") or dates.max() > pd.Timestamp("2018-12-31"):
        raise SystemExit("non-TRAIN date leaked")
    rows = registry_rows()
    if len(rows) != 384 or len({r["candidate_id"] for r in rows}) != 384:
        raise SystemExit("P42 registry must contain 384 unique candidates")
    print(json.dumps({
        "status":"PUBLIC_COMPUTE_LANE_OK",
        "train_rows":len(df),
        "train_start":str(dates.min().date()),
        "train_end":str(dates.max().date()),
        "candidate_count":len(rows),
    }, sort_keys=True))


if __name__ == "__main__":
    main()
