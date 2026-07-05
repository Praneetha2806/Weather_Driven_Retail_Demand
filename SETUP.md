# 🚀 Setup Guide: Weather-Driven Retail Demand Intelligence

Complete step-by-step instructions to deploy this project in your Databricks workspace.

---

## Prerequisites

### Required
- **Databricks Workspace** (AWS, Azure, or GCP)
- **Unity Catalog** enabled
- **Compute**: Serverless or cluster with DBR 13.0+
- **Permissions**: CREATE CATALOG, CREATE SCHEMA, CREATE TABLE

### Optional (for production)
- **Git integration** configured in Databricks
- **Workflow permissions** to create Jobs

---

## Part 1: Unity Catalog Setup (5 minutes)

### Step 1: Create Catalog and Schemas

1. Open a **SQL Warehouse** or **SQL Editor** in Databricks
2. Run the script from `sql/create_schemas.sql`:

```sql
-- Create Catalog
CREATE CATALOG IF NOT EXISTS retail_demo;
USE CATALOG retail_demo;

-- Create Schemas
CREATE SCHEMA IF NOT EXISTS retail_bronze;
CREATE SCHEMA IF NOT EXISTS retail_silver;
CREATE SCHEMA IF NOT EXISTS retail_gold;

-- Verify
SHOW SCHEMAS IN retail_demo;
```

**Expected output**: 3 schemas (retail_bronze, retail_silver, retail_gold) + system schemas (default, information_schema)

### Step 2: Create Store Master Table

1. Run the script from `sql/create_store_master.sql`:

```sql
USE CATALOG retail_demo;
USE SCHEMA retail_gold;

CREATE TABLE store_master (
    store_id STRING,
    city STRING,
    region STRING,
    latitude DOUBLE,
    longitude DOUBLE,
    category_focus STRING,
    store_size_sqft INT,
    opened_date DATE
) USING DELTA;

-- Insert 13 store records
INSERT INTO store_master VALUES
    ('ST001', 'San Jose', 'West', 37.3382, -121.8863, 'Electronics', 12000, '2019-03-15'),
    ... (see full script)
;

-- Verify
SELECT COUNT(*) FROM store_master; -- Should return 13
```

**Expected output**: 13 rows inserted

---

## Part 2: Import Notebooks (10 minutes)

### Option A: Import from This Git Repo (Recommended)

1. In Databricks, go to **Workspace** → **Users** → Your username
2. Click **…** → **Import**
3. Select **URL** and paste:
   ```
   https://github.com/your-username/weather-driven-retail-demand/tree/main/notebooks
   ```
4. Click **Import**

### Option B: Manual Copy from Existing Workspace

If you already have the notebooks in your workspace:

1. **Retail_Bronze_notebook.ipynb**
   - Location: `/Users/gunpraneetha76@gmail.com/Retail_Bronze_notebook`
   - Right-click → **Copy** → Paste into Git folder

2. **Retail_silver_notebook.ipynb**
   - Location: `/Users/gunpraneetha76@gmail.com/Retail_silver_notebook`
   - Right-click → **Copy** → Paste into Git folder

3. **Retail_gold_notebook.ipynb**
   - Location: `/Users/gunpraneetha76@gmail.com/Retail_gold_notebook`
   - Right-click → **Copy** → Paste into Git folder

### Verify Notebooks

Your folder structure should now look like:
```
Weather_Driven_Retail_Demand/
├── notebooks/
│   ├── Retail_Bronze_notebook.ipynb
│   ├── Retail_silver_notebook.ipynb
│   └── Retail_gold_notebook.ipynb
```

---

## Part 3: Run Initial Pipeline (15 minutes)

### Step 1: Run Bronze Notebook

1. Open `notebooks/Retail_Bronze_notebook.ipynb`
2. Attach serverless compute (or a cluster)
3. Click **Run All**
4. Wait ~2-3 minutes for execution

**Expected output**:
- Table created: `retail_demo.retail_bronze.weather_raw`
- Rows inserted: 104 (13 stores × 8 time periods)
- Status: All cells green ✅

**Verify**:
```sql
SELECT COUNT(*) FROM retail_demo.retail_bronze.weather_raw;
-- Expected: 104
```

### Step 2: Run Silver Notebook

1. Open `notebooks/Retail_silver_notebook.ipynb`
2. Click **Run All**
3. Wait ~3-4 minutes for execution

**Expected output**:
- Table created: `retail_demo.retail_silver.weather_current_clean`
- Rows inserted: 104 (deduplicated)
- Status: All cells green ✅

**Verify**:
```sql
SELECT 
    store_id, 
    city, 
    temperature_f, 
    precipitation_in 
FROM retail_demo.retail_silver.weather_current_clean 
LIMIT 5;
```

### Step 3: Run Gold Notebook

1. Open `notebooks/Retail_gold_notebook.ipynb`
2. Click **Run All**
3. Wait ~2-3 minutes for execution

**Expected output**:
- Tables created:
  - `retail_demo.retail_gold.demand_signal_current`
  - `retail_demo.retail_gold.demand_signal_history`
  - `retail_demo.retail_gold.demand_signal_forecast`
- Status: All cells green ✅

**Verify**:
```sql
SELECT 
    city, 
    region, 
    temperature_f, 
    ac_cooling_demand, 
    rain_gear_demand, 
    staffing_recommendation 
FROM retail_demo.retail_gold.demand_signal_current 
LIMIT 5;
```

---

## Part 4: Create Dashboard (20 minutes)

### Step 1: Create New Dashboard

1. Go to **AI/BI** → **Dashboards**
2. Click **Create Dashboard**
3. Name: `Weather-Driven Retail Demand Intelligence`

### Step 2: Add Widgets

Follow the dashboard documentation in `dashboard/widget_specs.json` to create:

1. **Region Filter** (Dropdown)
   - Dataset: `SELECT DISTINCT region FROM retail_demo.retail_gold.demand_signal_current`

2. **Daily Operations View** (Table)
   - Dataset: `SELECT city, region, category_focus, temperature_f, precipitation_in, staffing_recommendation FROM retail_demo.retail_gold.demand_signal_current`

3. **Staffing Needs by Region** (Bar Chart)
   - Dataset: Group by region and staffing_recommendation

4. **AC Cooling Demand by Store** (Bar Chart)
   - Dataset: AC demand by city

5. **Rain Gear Demand by Store** (Bar Chart)
   - Dataset: Rain gear demand by city

6. **Temperature Trends Over Time** (Line Chart)
   - Dataset: `SELECT observation_time, store_id, temperature_f, region FROM retail_demo.retail_gold.demand_signal_history`

7. **14-Day Staffing Forecast Planner** (Pivot Table)
   - Dataset: `SELECT city, forecast_date, staffing_recommendation FROM retail_demo.retail_gold.demand_signal_forecast`
   - Conditional formatting: Orange for "Increase Staff", Green for "Standard Staffing"

### Step 3: Connect Filter

1. Select the **Region Filter** widget
2. For each chart/table:
   - Click **…** → **Add Filter**
   - Map `region` column to the Region Filter

### Step 4: Publish Dashboard

1. Click **Publish**
2. Share link with stakeholders

---

## Part 5: Schedule Job (Optional, 15 minutes)

### Step 1: Create Job

1. Go to **Workflows** → **Jobs** → **Create Job**
2. Job name: `Weather_demand_pipeline`

### Step 2: Add Tasks

**Task 1: Bronze Ingestion**
- Type: Notebook
- Notebook path: `/Users/gunpraneetha76@gmail.com/Weather_Driven_Retail_Demand/notebooks/Retail_Bronze_notebook`
- Cluster: Serverless
- Timeout: 10 minutes

**Task 2: Silver Cleansing**
- Type: Notebook
- Notebook path: `/Users/gunpraneetha76@gmail.com/Weather_Driven_Retail_Demand/notebooks/Retail_silver_notebook`
- Depends on: Task 1
- Cluster: Serverless
- Timeout: 10 minutes

**Task 3: Gold Aggregations**
- Type: Notebook
- Notebook path: `/Users/gunpraneetha76@gmail.com/Weather_Driven_Retail_Demand/notebooks/Retail_gold_notebook`
- Depends on: Task 2
- Cluster: Serverless
- Timeout: 10 minutes

### Step 3: Configure Schedule

1. Click **Add Trigger** → **Scheduled**
2. Schedule type: **Cron**
3. Cron expression: `0 */3 * * *` (every 3 hours)
4. Timezone: Your local timezone

### Step 4: Run Job

1. Click **Run Now** to test
2. Monitor execution in the **Runs** tab
3. Expected duration: ~8-10 minutes

---

## Part 6: Git Integration (Optional, 10 minutes)

### Step 1: Initialize Git in Databricks

1. Right-click on `Weather_Driven_Retail_Demand` folder
2. Select **Git** → **Create Repo**
3. Enter your GitHub repository URL
4. Authenticate with GitHub token

### Step 2: Commit and Push

1. Stage all files
2. Commit message: `Initial commit: Weather-driven retail demand pipeline`
3. Push to `main` branch

---

## Troubleshooting

### Issue: "Catalog retail_demo not found"
**Solution**: Run `CREATE CATALOG retail_demo;` first

### Issue: "Table already exists" error
**Solution**: Add `CREATE OR REPLACE TABLE` or drop existing table

### Issue: Notebooks fail with "No compute attached"
**Solution**: Attach serverless compute or create a cluster

### Issue: Dashboard shows no data
**Solution**: Verify Gold tables have data:
```sql
SELECT COUNT(*) FROM retail_demo.retail_gold.demand_signal_current;
```

### Issue: Job fails on Task 2 or 3
**Solution**: Ensure previous tasks completed successfully. Check task logs for specific errors.

---

## Validation Checklist

Before considering setup complete, verify:

- [ ] Catalog `retail_demo` exists with 3 schemas
- [ ] Store master table has 13 rows
- [ ] Bronze table has 104 rows
- [ ] Silver table has 104 rows
- [ ] Gold tables (current, history, forecast) all have data
- [ ] Dashboard renders all 7-8 widgets
- [ ] Region filter affects all connected widgets
- [ ] Job runs successfully end-to-end

---

## Next Steps

1. **Customize**: Modify demand scoring logic in Gold notebook for your business rules
2. **Extend**: Add more stores to `store_master` table
3. **Integrate**: Connect real weather API (replace mock data in Bronze notebook)
4. **Monitor**: Set up job alerts for pipeline failures
5. **Share**: Distribute dashboard link to operations team

---

## Support

For issues or questions:
- Check `docs/troubleshooting.md`
- Open a GitHub issue
- Contact: gunpraneetha76@gmail.com

---

**🎉 Congratulations! Your Weather-Driven Retail Demand Intelligence system is now live!**