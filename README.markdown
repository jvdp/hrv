# hrv - sync my hours with harvest

## Configuration
Copy `credentials_example.yml` to `credentials.yml` and fill it out.  

## Available commands:
    hrv [open]           open ~/harvest.txt with $EDITOR
    hrv sync             sync to harvest
    hrv dry              see what can be synced
    hrv tail [n=10]      last n synced entries
    hrv dump             dump all entries
    hrv backups          open backups directory
    hrv days [n=10]      breakdown of hours per day (for last n days)
    hrv months           breakdown of hours per month

## harvest.txt format:
    28 augustus
    12:00 - 13:00 brightin uren invullen in harvest
