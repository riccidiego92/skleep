# WFL P43 public compute lane

Sanitized TRAIN-only compute branch for the Win for Life Classico P42/P43 research pipeline.

Included:
- P42 phased HMAC_DRBG-SHA256 synthetic comparator;
- frozen P43 TRAIN statistic and required feature code;
- public TRAIN outcomes 2013-01-21 through 2018-12-31, reduced to date/time/Main/Numerone;
- GitHub Actions compute orchestration.

Excluded:
- validation and holdout periods;
- source URLs and internal source hashes;
- prospective freezes and survivor sets;
- private control-plane artifacts;
- credentials, secrets and operational seed search.

Frozen parameters:
- 384 P42 candidates;
- confirmation: 2,000 reps, alpha 0.01;
- FINAL_TRAIN: 100,000 reps, alpha 0.05.

Results must be imported into the private fail-closed control plane before P48.
