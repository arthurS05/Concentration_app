# Concentration_app


**A Shiny dashboard for processing LI‑COR headspace injection data**  
This R Shiny application streamlines the batch processing of dissolved methane (CH₄) and carbon dioxide (CO₂) measurements obtained via a headspace injection method into a LI‑COR trace gas analyzer. Users can step through samples, pick start/end points on interactive plots, inspect summary statistics, add free‑text comments, and collate all results into a single table for export.

---

## 🚀 Features

- **Step‑wise sample navigation**: click “Next Sample” to load each new record.  
- **Interactive point selection**: choose start and end times directly on your CH₄/CO₂ time series plots.  
- **Automatic baseline & integral calculation**.  
- **Global injection & difference‑from‑mean plots**, with x‑axis labels rotated for readability.  
- **Free‑form comments** can be added per sample and saved alongside all computed values.  
- **Downloadable results table** via the DataTable UI.  

---

## 📂 Project Structure

```bash
Concentration_app/
├── app.R
├── data/
│   ├── all_data.csv
│   └── list_all.csv
├── README.md
└── LICENSE
```

- **app.R**: main Shiny app (UI + server).  
- **data/**: place your raw CSVs here.  
- **README.md**: this documentation.  

---

## 🔧 Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/Concentration_app.git
   cd Concentration_app
   ```

2. Install required R packages (if not already installed):
   ```r
   install.packages(c("shiny","shinydashboard","ggplot2","dplyr","DT","here"))
   ```

3. (Optional) Create the `data/` folder and copy your `all_data.csv` and `list_all.csv` into it.

---

## ▶️ Usage

1. **Set your data directory** in **app.R**:

2. Launch the app (from R):
   ```r
   shiny::runApp("app.R")
   ```

3. In the UI:
   - Click **Next Sample** to load a new sample.  
   - On the **CH₄** tab, click the scatter plot to select your injection start, then choose an end point on the “Diff from Mean” plot.  
   - Repeat on the **CO₂** tab.  
   - Optionally enter a **Comment**.  
   - Click **Save Results** to append both CH₄ and CO₂ rows (plus comment) to the master table.  

4. When you’ve processed all samples, export or copy the final table (`df_concentration_final`) from your global environment for downstream analyses.

---

## 📐 Methodology

All concentrations are computed using a headspace injection method into a LI‑COR analyzer (Li‑7810 Trace Gas Analyzer, open‑loop).

---

## 2. Gas-phase Concentration

The gas-phase methane concentration `C_g` (in mol·L⁻¹) is calculated as:

```
C_g = [ (I × Q / V_inject) + C_base ] / [1000 × C_conv × V_ig]
```

**Where:**

- `I` = integrated CH₄ peak area (ppb·s)  
- `Q` = analyzer flow rate (mL·s⁻¹)  
- `V_inject` = injected gas volume (mL)  
- `C_base` = reference‑air methane concentration (ppb)  
- `C_conv` = conversion factor (10⁹ to convert ppb to mol fraction)  
- `V_ig` = molar volume of an ideal gas (23 L·mol⁻¹)  

---

## 3. Henry’s Law Constant

Henry’s law constant `H` (in mol·L⁻¹·atm⁻¹) for methane is given by:

```
H = [1 / (P × R × T × K_methane)] × exp[ β_methane × (1/T - 1/T_std) ]
```

**Where:**

- `P` = 1.013 bar (atmospheric pressure)  
- `R` = 0.082 L·atm·mol⁻¹·K⁻¹ (ideal gas constant)  
- `T` = water temperature (K)  
- `T_std` = 298.15 K (standard temperature)  
- `β_methane` = 1700 K (temperature adjustment factor)  
- `K_methane` = 0.0014 mol·(kg·bar)⁻¹ (Henry’s constant at 298.15 K)  

---

## 4. Liquid-phase Concentration

The dissolved methane concentration `C_l` (in mol·L⁻¹) is:

```
C_l = [(C_g × V_g) + ((C_g / H) × V_l)] / V_l
```

**Where:**

- `C_l` = dissolved CH₄ concentration in liquid (mol·L⁻¹)  
- `C_g` = gas-phase CH₄ concentration (mol·L⁻¹)  
- `V_g` = 60 mL (gas-phase volume)  
- `V_l` = 90 mL (liquid-phase volume)  
- `H` = Henry’s law constant (mol·L⁻¹·atm⁻¹)


## 🔍 Citation

If you use this tool in a publication, please cite:





