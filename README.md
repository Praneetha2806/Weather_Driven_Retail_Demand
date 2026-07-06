# 🌦️ Weather-Driven Retail Demand Intelligence

> **Real-time operational intelligence dashboard powered by weather data to optimize retail staffing, inventory, and customer experience.**

[![Databricks](https://img.shields.io/badge/Databricks-Medallion%20Architecture-FF3621?style=flat&logo=databricks)](https://databricks.com)
[![Delta Lake](https://img.shields.io/badge/Delta%20Lake-3.0-003366?style=flat)](https://delta.io)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat&logo=python&logoColor=white)](https://python.org)
[![SQL](https://img.shields.io/badge/Databricks%20SQL-Spark%203.0-E25A1C?style=flat)](https://spark.apache.org/sql/)

---

## 📋 Table of Contents
- [Overview](#overview)
- [Business Problem](#business-problem)
- [Architecture](#architecture)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Data Pipeline](#data-pipeline)
- [Dashboard & Analytics](#dashboard--analytics)
- [Setup Instructions](#setup-instructions)
- [Project Structure](#project-structure)
- [Business Impact](#business-impact)
- [Future Enhancements](#future-enhancements)

---

## 🎯 Overview

Weather-Driven Retail Demand Intelligence is an **end-to-end data pipeline and analytics solution** that integrates real-time weather data with retail operations to provide actionable insights for:

- **Proactive staffing decisions** based on weather-driven foot traffic predictions
- **Dynamic inventory optimization** for weather-sensitive products (AC units, rain gear, seasonal items)
- **Real-time operational dashboards** for store managers and regional teams
- **Historical trend analysis** to understand weather-demand correlations

Built on Databricks using a **medallion architecture (Bronze → Silver → Gold)**, this project demonstrates production-grade data engineering practices including automated ingestion, data quality checks, deduplication, and scheduled orchestration.

---

## 💼 Business Problem

### Challenge
Retail stores experience **unpredictable demand fluctuations** driven by weather:
- Hot days → spike in AC/cooling product demand, increased foot traffic
- Rainy days → surge in rain gear sales, reduced in-store shopping
- Inadequate staffing during weather events → poor customer experience, lost sales
- Overstaffing during calm weather → unnecessary labor costs

### Solution
This system:
1. **Fetches real-time weather data** for all store locations (13 cities across 4 US regions)
2. **Processes and enriches** data through a medallion pipeline
3. **Generates demand signals** for AC cooling, rain gear, and staffing needs
4. **Delivers insights** via an interactive dashboard updated every 3 hours
5. **Provides 14-day forecasts** for proactive workforce planning

### Potential Impact
This system provides the operational intelligence needed to:
- ⚡ **Optimize staffing decisions** with weather-driven foot traffic predictions
- 📦 **Improve product availability** for weather-sensitive items (AC units, rain gear)
- 👥 **Enhance customer experience** by reducing wait times during weather events

---

## 🏗️ Architecture

### Medallion Architecture (Bronze → Silver → Gold)

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DATA SOURCES                                  │
│  Open-Meteo Weather API (current + historical data for 13 cities)   │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  BRONZE LAYER (retail_demo.retail_bronze.weather_raw)               │
│  • Raw JSON payloads stored as-is                                    │
│  • Ingestion timestamp for auditing                                  │
│  • Notebook: Retail_Bronze_notebook.ipynb                            │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  SILVER LAYER (retail_demo.retail_silver.weather_current_clean)     │
│  • Parsed, validated, deduplicated weather observations             │
│  • Schema enforcement (temperature, precipitation, humidity, etc.)   │
│  • MERGE-based upsert for idempotency                                │
│  • Notebook: Retail_silver_notebook.ipynb                            │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  GOLD LAYER (retail_demo.retail_gold.demand_signal_*)               │
│  • Business-ready aggregations and demand scoring                    │
│  • Tables:                                                           │
│    - demand_signal_current (real-time staffing/inventory signals)   │
│    - demand_signal_history (historical trends for analytics)        │
│    - demand_signal_forecast (14-day planning tool)                  │
│  • Notebook: Retail_gold_notebook.ipynb                              │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  DASHBOARD (Weather-Driven Retail Demand Intelligence)              │
│  • Real-time operations view (today's weather + staffing)           │
│  • Historical trend analysis (temperature over time)                │
│  • 14-day forecast planner (pivot table for workforce scheduling)   │
│  • Region filter for multi-location analysis                        │
└─────────────────────────────────────────────────────────────────────┘
```

### Orchestration
- **Job**: `Weather_demand_pipeline` (Databricks Jobs)
- **Schedule**: Every 3 hours (aligns with weather API update frequency)
- **Execution**: Runs Bronze → Silver → Gold notebooks sequentially

---

## ✨ Key Features

### 1. **Three-Horizon Time Architecture**
   - **Current** (`demand_signal_current`): Today's real-time operational data
   - **History** (`demand_signal_history`): Past trends for pattern analysis
   - **Forecast** (`demand_signal_forecast`): Next 14 days for proactive planning

### 2. **Automated Data Quality**
   - Deduplication (keeps most recent observation per store/time)
   - Schema validation and type enforcement
   - Error handling with graceful fallbacks

### 3. **Business-Ready Demand Signals**
   - **AC Cooling Demand**: High (≥90°F), Medium (75-89°F), Low (<75°F)
   - **Rain Gear Demand**: High (≥60% precip prob), Medium (30-59%), Low (<30%)
   - **Staffing Recommendation**: Increase Staff (hot or rainy) vs. Standard

### 4. **Interactive Dashboard**
   - Region-based filtering (West, South, Midwest, Northeast)
   - Color-coded visualizations for at-a-glance insights
   - Drill-down capability by city and store
   - 14-day forecast pivot table with conditional formatting

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|------------|--------|
| **Data Ingestion** | Python, Requests | Fetch weather data from Open-Meteo API |
| **Storage** | Delta Lake | ACID transactions, time travel, schema evolution |
| **Processing** | PySpark, Databricks SQL | Distributed data transformations |
| **Orchestration** | Databricks Jobs | Scheduled pipeline execution |
| **Catalog** | Unity Catalog | Centralized metadata and governance |
| **Visualization** | Databricks AI/BI Dashboards | Interactive analytics |
| **Version Control** | Git (GitHub) | Source code management |

---

## 🔄 Data Pipeline

### Bronze Layer: Raw Ingestion
**Notebook**: `Retail_Bronze_notebook.ipynb`

```python
# Key operations:
- Fetch weather data for 13 store locations via Open-Meteo API
- Generate realistic mock data for demo purposes (instant execution)
- Store raw JSON payloads in Delta table
- Add ingestion timestamp for audit trail
```

**Output**: `retail_demo.retail_bronze.weather_raw`

---

### Silver Layer: Cleansing & Transformation
**Notebook**: `Retail_silver_notebook.ipynb`

```python
# Key operations:
- Parse JSON payloads (Python dict format)
- Extract current weather observations
- Cast numeric fields to consistent types (float for temperature, humidity, etc.)
- Deduplicate (keep most recent observation per store)
- MERGE into Silver table for idempotent upserts
```

**Output**: `retail_demo.retail_silver.weather_current_clean`

---

### Gold Layer: Business Logic & Aggregations
**Notebook**: `Retail_gold_notebook.ipynb`

```python
# Key operations:
- Join weather data with store master (category focus)
- Calculate demand signals:
  * AC Cooling Demand: CASE WHEN temp >= 90 THEN 'High' ...
  * Rain Gear Demand: CASE WHEN precip_prob >= 60 THEN 'High' ...
  * Staffing Recommendation: CASE WHEN (temp >= 90 OR precip_prob >= 60) ...
- Write to three Gold tables:
  * demand_signal_current (today's snapshot)
  * demand_signal_history (append-only log)
  * demand_signal_forecast (14-day outlook)
```

**Outputs**:
- `retail_demo.retail_gold.demand_signal_current`
- `retail_demo.retail_gold.demand_signal_history`
- `retail_demo.retail_gold.demand_signal_forecast`
- `retail_demo.retail_gold.store_master`

---

## 📊 Dashboard & Analytics

### Dashboard: **Weather-Driven Retail Demand Intelligence**

![Dashboard Overview](dashboard/dashboard_screenshot.png)
*Interactive dashboard showing real-time weather conditions, demand signals, and 14-day staffing forecast*

#### Widgets
1. **Region Filter** (Dropdown)
   - Filter all visuals by: West, South, Midwest, Northeast

2. **Daily Operations View** (Table)
   - Columns: City, Region, Category Focus, Temperature, Precipitation, Staffing Recommendation
   - Use case: Today's operational snapshot

3. **Staffing Needs by Region** (Bar Chart)
   - Aggregates staffing recommendations by region
   - Color-coded by staffing level

4. **AC Cooling Demand by Store** (Bar Chart)
   - Shows AC demand levels (High/Medium/Low) per city
   - Helps prioritize inventory restocking

5. **Rain Gear Demand by Store** (Bar Chart)
   - Shows rain gear demand levels per city
   - Informs merchandising decisions

6. **Temperature Trends Over Time** (Line Chart)
   - Historical temperature patterns per store
   - Helps identify seasonal trends

7. **14-Day Staffing Forecast Planner** (Pivot Table)
   - **Rows**: Cities
   - **Columns**: Forecast dates (next 14 days)
   - **Cell values**: Staffing recommendation
   - **Conditional formatting**: Orange for "Increase Staff", Green for "Standard Staffing"
   - **Use case**: Proactive workforce scheduling 2 weeks ahead

8. **Executive Summary** (Text Widget)
   - Business impact, ROI, and key capabilities

---

## 🚀 Setup Instructions

### Prerequisites
- Databricks workspace (AWS, Azure, or GCP)
- Unity Catalog enabled
- Serverless compute or cluster with DBR 13.0+

### Step 1: Clone Repository
```bash
git clone https://github.com/your-username/weather-driven-retail-demand.git
cd weather-driven-retail-demand
```

### Step 2: Create Unity Catalog Schema
```sql
CREATE CATALOG IF NOT EXISTS retail_demo;
CREATE SCHEMA IF NOT EXISTS retail_demo.retail_bronze;
CREATE SCHEMA IF NOT EXISTS retail_demo.retail_silver;
CREATE SCHEMA IF NOT EXISTS retail_demo.retail_gold;
```

### Step 3: Import Notebooks
1. Upload `notebooks/` folder to your Databricks workspace:
   - `Retail_Bronze_notebook.ipynb`
   - `Retail_silver_notebook.ipynb`
   - `Retail_gold_notebook.ipynb`

### Step 4: Run Initial Pipeline
Run notebooks in sequence:
1. Bronze → Ingests raw data
2. Silver → Cleanses and deduplicates
3. Gold → Generates demand signals

### Step 5: Create Job (Optional)
1. Go to **Workflows** → **Jobs** → **Create Job**
2. Add tasks:
   - Task 1: Run `Retail_Bronze_notebook` (depends on: none)
   - Task 2: Run `Retail_silver_notebook` (depends on: Task 1)
   - Task 3: Run `Retail_gold_notebook` (depends on: Task 2)
3. Set schedule: Every 3 hours

### Step 6: Import Dashboard
1. Go to **AI/BI** → **Dashboards** → **Create Dashboard**
2. Use the dataset queries from `dashboard/queries.sql`
3. Create widgets as described in [Dashboard & Analytics](#dashboard--analytics)

---

## 📁 Project Structure

```
weather-driven-retail-demand/
│
├── README.md                          # This file
├── ARCHITECTURE.md                    # Detailed architecture documentation
├── SETUP.md                           # Step-by-step setup guide
│
├── notebooks/
│   ├── Retail_Bronze_notebook.ipynb   # Bronze layer: Raw ingestion
│   ├── Retail_silver_notebook.ipynb   # Silver layer: Cleansing
│   └── Retail_gold_notebook.ipynb     # Gold layer: Business logic
│
├── sql/
│   ├── create_schemas.sql             # Unity Catalog setup
│   └── create_store_master.sql        # Store master data
│
├── dashboard/
│   ├── queries.sql                    # Dashboard dataset queries
│   ├── widget_specs.json              # Widget configurations
│   └── screenshots/                   # Dashboard screenshots
│       ├── full_dashboard.png
│       ├── operations_table.png
│       └── forecast_planner.png
│
├── job/
│   └── pipeline_config.json           # Databricks Job configuration
│
└── docs/
    ├── business_requirements.md       # Original business problem
    ├── data_dictionary.md             # Schema documentation
    └── troubleshooting.md             # Common issues and fixes
```

---

## 💡 Business Impact

### Quantified Outcomes
This project demonstrates a rule-based framework for translating weather signals into retail 
operational recommendations. The demand-signal thresholds (e.g., AC/cooling demand, rain gear 
demand, staffing recommendations) are based on general, well-documented retail weather patterns 
— not derived from or validated against actual sales data, since no real point-of-sale dataset 
was available for this project.

**What this means:** figures like "increased sales" or "cost savings" are not calculated or 
measured anywhere in this pipeline — no such numbers are claimed here.

**What would be needed to measure real impact:** access to historical store-level sales data, 
correlated against the weather variables already being captured (temperature, precipitation, 
wind), using a statistical method such as regression analysis to quantify the actual relationship 
— confirming which thresholds meaningfully predict demand shifts, and by how much, at these 
specific stores.

### Stakeholder Value
- **Store Managers**: Real-time staffing guidance, eliminating guesswork
- **Regional Directors**: Multi-store view for resource allocation
- **Inventory Planners**: Proactive restocking based on 14-day forecast
- **Finance**: Measurable labor cost reduction with maintained service levels

---

## 🔮 Future Enhancements

### Phase 2 (Q3 2026)
- [ ] **Machine Learning Integration**
  - Train ML model on historical weather-sales correlation
  - Predict revenue impact of weather events
  - Personalized staffing recommendations per store

- [ ] **Real-Time Streaming**
  - Replace batch ingestion with Delta Live Tables
  - Sub-hourly updates for severe weather alerts

- [ ] **Mobile Alerts**
  - Push notifications to store managers for critical weather events
  - Integration with Slack/Teams

### Phase 3 (Q4 2026)
- [ ] **Multi-Source Data Integration**
  - Combine weather with:
    - Local events (concerts, sports games)
    - Holiday calendars
    - Social media sentiment

- [ ] **Advanced Analytics**
  - Customer segmentation by weather preference
  - Predictive modeling for new store openings
  - What-if scenario planning

---

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📧 Contact

**Project Maintainer**: [Your Name]
- LinkedIn: [Your LinkedIn Profile]
- Email: gunpraneetha76@gmail.com
- Portfolio: [Your Portfolio Website]

---

## 🙏 Acknowledgments

- **Weather Data**: [Open-Meteo API](https://open-meteo.com/) for free, high-quality weather data
- **Platform**: [Databricks](https://databricks.com/) for unified analytics platform
- **Community**: Databricks Community Edition for democratizing data engineering

---

## Limitations & Future Work

**Current limitations:**
- Demand-signal scoring uses fixed, rule-based thresholds (e.g., "precipitation > 0.1in → High 
  rain gear demand") based on general retail knowledge, not statistically validated against real 
  sales outcomes.
- Store locations represent sample major-metro coordinates, not actual retail store addresses.
- Category mix per store (`category_focus`) is illustrative, not based on real inventory data.

**Future work:**
- Validate demand-signal thresholds against real POS/sales data using regression analysis, to 
  confirm and quantify the actual relationship between weather conditions and sales by category.
- Extend the pipeline to ingest 14-day forecast data (in addition to current conditions) to 
  support staffing and inventory planning on a realistic 1–2 week retail planning horizon.
- Once sufficient history accumulates, analyze `demand_signal_history` for seasonal patterns 
  by region, and explore time-series forecasting (e.g., Prophet, ARIMA) as a predictive layer 
  on top of the current rule-based approach.

  ---

**⭐ If you found this project helpful, please give it a star on GitHub!**