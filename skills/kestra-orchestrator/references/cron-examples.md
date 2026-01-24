# Cron Expression Reference

Common cron expressions for Kestra Schedule triggers.

## Cron Format

```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12)
│ │ │ │ ┌───────────── day of week (0-6, Sunday=0)
│ │ │ │ │
* * * * *
```

## Common Patterns

### Every X Minutes

| Expression | Description |
|------------|-------------|
| `* * * * *` | Every minute |
| `*/5 * * * *` | Every 5 minutes |
| `*/15 * * * *` | Every 15 minutes |
| `*/30 * * * *` | Every 30 minutes |

### Hourly

| Expression | Description |
|------------|-------------|
| `0 * * * *` | Every hour (at minute 0) |
| `30 * * * *` | Every hour (at minute 30) |
| `0 */2 * * *` | Every 2 hours |
| `0 */6 * * *` | Every 6 hours |

### Daily

| Expression | Description |
|------------|-------------|
| `0 0 * * *` | Every day at midnight |
| `0 9 * * *` | Every day at 9:00 AM |
| `0 18 * * *` | Every day at 6:00 PM |
| `0 9,18 * * *` | Every day at 9 AM and 6 PM |
| `30 8 * * *` | Every day at 8:30 AM |

### Weekly

| Expression | Description |
|------------|-------------|
| `0 9 * * 1` | Every Monday at 9:00 AM |
| `0 9 * * 1-5` | Weekdays at 9:00 AM |
| `0 10 * * 0,6` | Weekends at 10:00 AM |
| `0 9 * * 0` | Every Sunday at 9:00 AM |

### Monthly

| Expression | Description |
|------------|-------------|
| `0 0 1 * *` | First day of month at midnight |
| `0 9 1 * *` | First day of month at 9:00 AM |
| `0 9 15 * *` | 15th of each month at 9:00 AM |
| `0 0 1,15 * *` | 1st and 15th of month at midnight |

### Specific Days

| Expression | Description |
|------------|-------------|
| `0 9 * * 1,3,5` | Mon, Wed, Fri at 9:00 AM |
| `0 9 1-7 * 1` | First Monday of month at 9:00 AM |
| `0 9 L * *` | Last day of month at 9:00 AM |

### Business Hours

| Expression | Description |
|------------|-------------|
| `0 9-17 * * 1-5` | Every hour 9-17 on weekdays |
| `*/30 9-17 * * 1-5` | Every 30 min during business hours |
| `0 8,12,18 * * 1-5` | 8 AM, noon, 6 PM on weekdays |

## Special Characters

| Character | Meaning | Example |
|-----------|---------|---------|
| `*` | Any value | `* * * * *` = every minute |
| `,` | List separator | `0 9,18 * * *` = 9 AM and 6 PM |
| `-` | Range | `0 9-17 * * *` = hourly 9 AM to 5 PM |
| `/` | Step values | `*/15 * * * *` = every 15 minutes |
| `L` | Last | `0 0 L * *` = last day of month |
| `W` | Weekday | `0 0 15W * *` = nearest weekday to 15th |
| `#` | Nth weekday | `0 0 * * 1#1` = first Monday |

## Timezone Configuration

Always specify timezone for predictable scheduling:

```yaml
triggers:
  - id: daily
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 9 * * *"
    timezone: "Europe/Rome"
```

Common timezones:
- `Europe/Rome`
- `Europe/London`
- `America/New_York`
- `America/Los_Angeles`
- `Asia/Tokyo`
- `UTC`

## Examples for Kestra

### Daily Report at 9 AM

```yaml
triggers:
  - id: daily_report
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 9 * * *"
    timezone: "Europe/Rome"
```

### Health Check Every 5 Minutes

```yaml
triggers:
  - id: health_check
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "*/5 * * * *"
```

### Weekly Backup on Sunday Night

```yaml
triggers:
  - id: weekly_backup
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 2 * * 0"
    timezone: "Europe/Rome"
```

### Monthly Invoice on 1st

```yaml
triggers:
  - id: monthly_invoice
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 8 1 * *"
    timezone: "Europe/Rome"
```

### Business Hours Only

```yaml
triggers:
  - id: business_hours
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 * 9-17 * * 1-5"
    timezone: "Europe/Rome"
```
