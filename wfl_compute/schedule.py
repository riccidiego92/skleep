from __future__ import annotations

from datetime import date, datetime, time, timedelta
from zoneinfo import ZoneInfo

import pandas as pd

TZ = ZoneInfo("Europe/Rome")
DAILY_HOURS = tuple(range(7, 24))
CONTESTS_PER_DAY = len(DAILY_HOURS)
DEFAULT_SYNTHETIC_EPOCH = "2013-01-21"
LAUNCH_PARTIAL_MISSING_SLOTS = 5


def _parse_epoch(epoch_date: str | date) -> date:
    if isinstance(epoch_date, date):
        return epoch_date
    return date.fromisoformat(str(epoch_date))


def schedule_for_ordinal(
    ordinal: int,
    epoch_date: str | date = DEFAULT_SYNTHETIC_EPOCH,
) -> datetime:
    ordinal = int(ordinal)
    if ordinal < 0:
        raise ValueError("ordinal must be non-negative")
    epoch = _parse_epoch(epoch_date)
    day_index, slot = divmod(ordinal, CONTESTS_PER_DAY)
    d = epoch + timedelta(days=day_index)
    return datetime.combine(d, time(DAILY_HOURS[slot], 0), tzinfo=TZ)


def attach_public_schedule(
    frame: pd.DataFrame,
    start_date: str = "2013-01-21",
    launch_partial_first_day: bool = True,
) -> pd.DataFrame:
    out = frame.copy().reset_index(drop=True)
    start = pd.Timestamp(start_date)
    dates: list[str] = []
    times: list[str] = []
    for i in range(len(out)):
        if launch_partial_first_day and i < 12:
            day_offset = 0
            hour = 12 + i
        else:
            j = i - 12 if launch_partial_first_day else i
            day_offset = (1 + j // 17) if launch_partial_first_day else (j // 17)
            hour = 7 + (j % 17)
        dates.append((start + pd.Timedelta(days=day_offset)).date().isoformat())
        times.append(f"{hour:02d}:00")
    out["date"] = dates
    out["time"] = times
    return out


def calendar_alignment_offset(config) -> int:
    config.validate()
    return LAUNCH_PARTIAL_MISSING_SLOTS if config.reseed_mode == "per_day" else 0


def stage_frame(
    df: pd.DataFrame,
    stage: str,
    unlock_holdout: bool = False,
) -> pd.DataFrame:
    if stage != "train":
        raise RuntimeError("public compute lane is TRAIN-only")
    z = df.copy()
    dates = pd.to_datetime(z["date"], errors="raise")
    mask = (dates >= pd.Timestamp("2013-01-21")) & (dates <= pd.Timestamp("2018-12-31"))
    return z.loc[mask].reset_index(drop=True)
