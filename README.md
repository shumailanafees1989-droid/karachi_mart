# Karachi Mart — Retail ERP & Management Suite (Pakistan)

A high-performance, modern Pakistani supermarket management system and Retail ERP designed for **Karachi Mart** (Gulshan-e-Iqbal Branch #01 & Karachi Central Depot). Built to seamlessly interface with the Karachi Mart public customer-facing website via a shared Supabase PostgreSQL data layer.

---

## 🌟 Modules Included

| Module | File | Description |
| :--- | :--- | :--- |
| **Overview Dashboard** | [`index.html`](file:///c:/Users/AU/Desktop/karachi%20mart/index.html) | Executive KPIs (Daily Sales, MTD Revenue, COGS, Net Profit), Hourly Sales SVG Visualizer, Cash Reconciliation ledger, and Karachi Fleet Live Status. |
| **Inventory & Stock** | [`inventory.html`](file:///c:/Users/AU/Desktop/karachi%20mart/inventory.html) | 482 SKU management across 8 FMCG categories, real-time FIFO valuation, automated reorder triggers, physical audit drawer, stock adjustment modals, and CSV export. |
| **POS & Sales Counter** | [`pos.html`](file:///c:/Users/AU/Desktop/karachi%20mart/pos.html) | Cashier billing station with barcode scanner input, touch item cards, Pakistani payment methods (Cash, Raast Instant QR, JazzCash/Easypaisa, HBL Card POS), and 80mm thermal receipt preview. |
| **Cash Register & Closing** | [`cash-register.html`](file:///c:/Users/AU/Desktop/karachi%20mart/cash-register.html) | Shift #4029 reconciliation, PKR currency denominations calculator (Rs. 5000 down to Rs. 10 notes), blind drop logging, and Day-End Z-Report generator. |
| **Deliveries & Fleet** | [`deliveries.html`](file:///c:/Users/AU/Desktop/karachi%20mart/deliveries.html) | Real-time Karachi courier tracking (Gulshan, PECHS, Bahadurabad, North Nazimabad, DHA, Clifton), rider dispatch queue, and COD settlement. |
| **Supplier Purchases** | [`suppliers.html`](file:///c:/Users/AU/Desktop/karachi%20mart/suppliers.html) | Vendor management for Shan Foods, Engro Foods, Dalda, Tapal Tea, Guard Basmati Rice, PO creation, and Goods Received Notes (GRN). |
| **Customers & Loyalty** | [`customers.html`](file:///c:/Users/AU/Desktop/karachi%20mart/customers.html) | Customer CRM with phone search (0300/0321/etc.), tier badges (Platinum, Gold, Silver), points redemption (100 Pts = Rs. 100), and WhatsApp receipts. |
| **Staff & Attendance** | [`staff.html`](file:///c:/Users/AU/Desktop/karachi%20mart/staff.html) | Biometric attendance roster for store cashiers, stock attendants, and dispatch riders. |
| **Expenses & P&L** | [`expenses.html`](file:///c:/Users/AU/Desktop/karachi%20mart/expenses.html) | Store operating costs (K-Electric tariff, rent, generator backup diesel, fleet fuel) and interactive P&L margin waterfall. |
| **Reports & Analytics** | [`reports.html`](file:///c:/Users/AU/Desktop/karachi%20mart/reports.html) | Business intelligence, top-selling FMCG products in Karachi, and CSV export. |
| **Database & Schema** | [`database.html`](file:///c:/Users/AU/Desktop/karachi%20mart/database.html) | PostgreSQL & Supabase schema explorer with full DDL script for relational tables and WebSocket triggers. |

---

## 🚀 How to Run Locally

### Option A: Direct Browser Preview
Double-click [`index.html`](file:///c:/Users/AU/Desktop/karachi%20mart/index.html) or open it in any modern browser (Chrome, Edge, Firefox). All sidebar links, interactive modals, tabs, and filters work out of the box with zero external build dependencies.

### Option B: Built-in PowerShell Local Server
Run the included PowerShell server script:
```powershell
powershell -ExecutionPolicy Bypass -File .\server.ps1
```
This serves the application on `http://localhost:5174/` and automatically launches your browser.

---

## 🔗 Architecture: Connecting with the Customer Storefront

Both applications share the same PostgreSQL data model in Supabase:
```
[Customer Web Storefront]  <==== Supabase PostgreSQL ====>  [Karachi Mart Retail ERP]
 (karachi art website)           (Realtime WebSockets)           (karachi mart)
  - Browses Catalog                                              - Adjusts Stock Levels
  - Places Orders                                                - Packs & Dispatches
  - Earns Loyalty Points                                         - Reconciles Cash Drawer
```
All SQL schemas and table definitions are available in [`database.html`](file:///c:/Users/AU/Desktop/karachi%20mart/database.html).
