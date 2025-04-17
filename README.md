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
   ```r
   # at top of app.R
   library(here)
   data_dir <- here("data")
   ```

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

All concentrations are computed via a headspace injection method into a LI-COR analyzer (Li-7810 Trace Gas Analyzer, open-loop). Below are the key equations:

## 1. Headspace Preparation
1. Fill a 150 mL vial completely with water.
2. Remove 60 mL of water and simultaneously replace it with 60 mL of air.
3. Shake the vial for 3 minutes.
4. Inject ~1 mL of headspace gas into the LI-COR.

## 2. Gas‑phase Concentration

\`\`\`latex
\\[
C_g = \\frac{\\bigl(I \\times Q / V_{\\text{inject}}\\bigr) + C_{\\text{base}}}
           {1000 \\times C_{\\text{conv}} \\times V_{\\text{ig}}}
\\]
\`\`\`

where:
- \(I\) = integrated CH\(_4\) peak area (ppb·s)  
- \(Q\) = analyzer flow rate (mL·s\(^{-1}\))  
- \(V_{\text{inject}}\) = injected gas volume (mL)  
- \(C_{\text{base}}\) = reference‑air concentration (ppb)  
- \(C_{\text{conv}}\) = conversion factor (10\(^9\) to convert ppb to mol fraction)  
- \(V_{\text{ig}}\) = molar volume (23 L·mol\(^{-1}\))  

## 3. Henry’s Law Constant

\`\`\`latex
\\[
H = \\frac{1}
           {P \\times R \\times T \\times K_{\\mathrm{methane}}
            \\times \\exp\\Bigl[\\beta_{\\mathrm{methane}}
            \\bigl(\\tfrac{1}{T} - \\tfrac{1}{T_{\\text{std}}}\\bigr)\\Bigr]}
\\]
\`\`\`

where:
- \(P = 1.013\) bar (atmospheric pressure)  
- \(R = 0.082\) L·atm·mol\(^{-1}\)·K\(^{-1}\)  
- \(T\) = water temperature (K)  
- \(T_{\text{std}} = 298.15\) K  
- \(\beta_{\mathrm{methane}} = 1700\) K  
- \(K_{\mathrm{methane}} = 0.0014\) mol·(kg·bar)\(^{-1}\)  

## 4. Liquid‑phase Concentration

\`\`\`latex
\\[
C_l = \\frac{C_g \\times V_g + \\bigl(\\tfrac{C_g}{H} \\times V_l\\bigr)}{V_l}
\\]
\`\`\`

where:
- \(C_l\) = CH\(_4\) concentration in liquid (mol·L\(^{-1}\))  
- \(C_g\) = gas‑phase CH\(_4\) concentration (mol·L\(^{-1}\))  
- \(V_g = 60\) mL (gas volume)  
- \(V_l = 90\) mL (liquid volume)  
- \(H\) = Henry’s constant (mol·L\(^{-1}\)·atm\(^{-1}\))  
"""

## 🔍 Citation

If you use this tool in a publication, please cite:

> *Your Lab’s Name* (2023), *Concentration_app*: R Shiny dashboard for LI‑COR headspace processing. GitHub repository: https://github.com/yourusername/Concentration_app

---

## 📝 License

This project is released under the **MIT License** – see [LICENSE](LICENSE) for details.

