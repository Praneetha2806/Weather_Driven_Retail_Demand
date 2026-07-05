# Dashboard Auto-Update Information

## 🔄 Continuous Data Updates

This dashboard is connected to a **live, continuously updating data pipeline**. As new weather observations are ingested through the Bronze → Silver → Gold medallion architecture, the dashboard visualizations automatically refresh with the latest data.

### How It Works

1. **Automated Data Ingestion**
   - The Bronze layer notebook fetches weather data from the Open-Meteo API on a scheduled basis
   - New observations are parsed and cleaned in the Silver layer
   - Business intelligence fields are computed in the Gold layer

2. **Self-Updating Visualizations**
   - All dashboard queries run against `retail_demo.retail_gold.demand_signal_history`
   - As new rows are inserted into this table, charts automatically include the new data points
   - No manual refresh or configuration changes are required

3. **Historical Trend Growth**
   - The temperature trend charts currently show 4 days of data (July 2-5, 2026)
   - As more data accumulates over weeks and months, the line charts will become smoother with more data points
   - The x-axis will intelligently adjust to show appropriate date intervals (daily, weekly, monthly)

### Data Freshness

- **Current data range:** July 2-5, 2026 (4 days)
- **Expected growth:** As the pipeline runs, data will accumulate continuously
- **Chart behavior:** Line charts will display smoother curves with 1 week, 1 month, 3+ months of data

### Chart Readability Features

To ensure charts remain readable as data grows:
- ✅ **45° angled date labels** prevent label clustering on the x-axis
- ✅ **Clean date format** (YYYY-MM-DD) instead of full timestamps
- ✅ **Improved typography** (Inter font, 14px base size) for PDF exports
- ✅ **Automatic label spacing** - the chart engine skips dates as needed to prevent overlap

### Dashboard Maintenance

**No maintenance required!** The dashboard is designed to scale automatically as your data grows. Just keep the Bronze notebook running on schedule, and the visualizations will stay current.

---

**Dashboard URL:** [View Published Dashboard](https://dbc-06c9250b-d515.cloud.databricks.com/dashboardsv3/01f17728963f1dfda38220eff6a5f44b/published?o=7474659082381814)

**Last Updated:** July 5, 2026
