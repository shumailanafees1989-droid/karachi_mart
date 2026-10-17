-- =========================================================================
-- KARACHI MART RETAIL ERP & STOREFRONT — SUPABASE POSTGRESQL SCHEMA
-- Branch: Gulshan-e-Iqbal Branch #01, Karachi, Sindh, Pakistan
-- Currency: PKR (Rs.)
-- =========================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -------------------------------------------------------------------------
-- 1. CATEGORIES TABLE
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug VARCHAR(64) UNIQUE NOT NULL,
    name VARCHAR(128) NOT NULL,
    description TEXT,
    icon VARCHAR(64) DEFAULT 'category',
    display_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -------------------------------------------------------------------------
-- 2. SUPPLIERS TABLE
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(128),
    phone VARCHAR(32),
    email VARCHAR(128),
    address TEXT,
    credit_terms_days INT DEFAULT 15,
    status VARCHAR(32) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -------------------------------------------------------------------------
-- 3. PRODUCTS TABLE
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku VARCHAR(64) UNIQUE NOT NULL,
    barcode VARCHAR(64) UNIQUE,
    name VARCHAR(255) NOT NULL,
    brand VARCHAR(128),
    category_slug VARCHAR(64) REFERENCES public.categories(slug) ON UPDATE CASCADE ON DELETE SET NULL,
    cost_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
    selling_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
    compare_at_price NUMERIC(12, 2),
    current_stock INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 10,
    unit VARCHAR(32) DEFAULT 'piece',
    is_featured BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- -------------------------------------------------------------------------
-- 4. INVENTORY BATCHES (FIFO & Expiry Tracking)
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.inventory_batches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    batch_number VARCHAR(64) UNIQUE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    supplier_id UUID REFERENCES public.suppliers(id) ON DELETE SET NULL,
    quantity_received INT NOT NULL,
    quantity_remaining INT NOT NULL,
    purchase_rate NUMERIC(12, 2) NOT NULL,
    expiry_date DATE NOT NULL,
    aisle_location VARCHAR(64),
    received_at TIMESTAMPTZ DEFAULT NOW()
);

-- -------------------------------------------------------------------------
-- 5. CUSTOMERS & LOYALTY CLUB
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(128) NOT NULL,
    phone VARCHAR(32) UNIQUE NOT NULL,
    email VARCHAR(128),
    delivery_area VARCHAR(128),
    tier VARCHAR(32) DEFAULT 'Silver', -- 'Bronze', 'Silver', 'Gold', 'Platinum'
    loyalty_points INT DEFAULT 0,
    lifetime_spend NUMERIC(12, 2) DEFAULT 0,
    whatsapp_opt_in BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -------------------------------------------------------------------------
-- 6. FLEET RIDERS
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.fleet_riders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_code VARCHAR(32) UNIQUE NOT NULL,
    name VARCHAR(128) NOT NULL,
    bike_number VARCHAR(32) NOT NULL,
    phone VARCHAR(32) NOT NULL,
    status VARCHAR(32) DEFAULT 'available', -- 'available', 'on_delivery', 'break', 'offline'
    cash_in_hand NUMERIC(12, 2) DEFAULT 0,
    zone_area VARCHAR(128) DEFAULT 'Gulshan-e-Iqbal',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -------------------------------------------------------------------------
-- 7. POS SHIFTS (Cash Drawer Tracking)
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.pos_shifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shift_number VARCHAR(32) UNIQUE NOT NULL,
    cashier_name VARCHAR(128) NOT NULL,
    branch_code VARCHAR(32) DEFAULT 'KHI-01',
    opening_float NUMERIC(12, 2) NOT NULL DEFAULT 25000,
    cash_collected NUMERIC(12, 2) DEFAULT 0,
    card_collected NUMERIC(12, 2) DEFAULT 0,
    raast_collected NUMERIC(12, 2) DEFAULT 0,
    expected_drawer NUMERIC(12, 2) DEFAULT 0,
    physical_counted NUMERIC(12, 2) DEFAULT 0,
    discrepancy NUMERIC(12, 2) DEFAULT 0,
    status VARCHAR(32) DEFAULT 'open', -- 'open', 'closed'
    opened_at TIMESTAMPTZ DEFAULT NOW(),
    closed_at TIMESTAMPTZ
);

-- -------------------------------------------------------------------------
-- 8. ORDERS (Web Storefront + POS Counter)
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(32) UNIQUE NOT NULL,
    channel VARCHAR(32) NOT NULL DEFAULT 'pos', -- 'pos', 'online'
    customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL,
    customer_name VARCHAR(128) DEFAULT 'Walk-in Customer',
    customer_phone VARCHAR(32),
    delivery_address TEXT,
    delivery_area VARCHAR(128),
    order_status VARCHAR(32) DEFAULT 'completed', -- 'received', 'packing', 'out_for_delivery', 'delivered', 'completed', 'cancelled'
    payment_method VARCHAR(32) NOT NULL DEFAULT 'cash', -- 'cash', 'raast', 'jazzcash', 'card', 'cod'
    payment_status VARCHAR(32) DEFAULT 'paid', -- 'paid', 'pending', 'refunded'
    subtotal NUMERIC(12, 2) NOT NULL DEFAULT 0,
    tax NUMERIC(12, 2) DEFAULT 0,
    discount NUMERIC(12, 2) DEFAULT 0,
    delivery_fee NUMERIC(12, 2) DEFAULT 0,
    total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    assigned_rider_id UUID REFERENCES public.fleet_riders(id) ON DELETE SET NULL,
    shift_id UUID REFERENCES public.pos_shifts(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -------------------------------------------------------------------------
-- 9. ORDER ITEMS
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name VARCHAR(255) NOT NULL,
    sku VARCHAR(64) NOT NULL,
    unit_price NUMERIC(12, 2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    total_price NUMERIC(12, 2) NOT NULL
);

-- -------------------------------------------------------------------------
-- 10. STORE OPERATING EXPENSES
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.store_expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    voucher_number VARCHAR(32) UNIQUE NOT NULL,
    category VARCHAR(64) NOT NULL,
    payee VARCHAR(128) NOT NULL,
    payment_mode VARCHAR(64) DEFAULT 'Petty Cash',
    amount NUMERIC(12, 2) NOT NULL,
    notes TEXT,
    logged_by VARCHAR(128) DEFAULT 'Muhammad Ahmed',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =========================================================================
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fleet_riders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pos_shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_expenses ENABLE ROW LEVEL SECURITY;

-- Allow public read access to catalog
CREATE POLICY "Public Read Categories" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Public Read Products" ON public.products FOR SELECT USING (true);
CREATE POLICY "Public Read Batches" ON public.inventory_batches FOR SELECT USING (true);
CREATE POLICY "Public Read Suppliers" ON public.suppliers FOR SELECT USING (true);
CREATE POLICY "Public Read Customers" ON public.customers FOR SELECT USING (true);
CREATE POLICY "Public Read Riders" ON public.fleet_riders FOR SELECT USING (true);
CREATE POLICY "Public Read Shifts" ON public.pos_shifts FOR SELECT USING (true);
CREATE POLICY "Public Read Orders" ON public.orders FOR SELECT USING (true);
CREATE POLICY "Public Read Order Items" ON public.order_items FOR SELECT USING (true);
CREATE POLICY "Public Read Expenses" ON public.store_expenses FOR SELECT USING (true);

-- Allow insert/update for anon (portfolio demo & ERP access)
CREATE POLICY "Anon Insert Orders" ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Anon Update Orders" ON public.orders FOR UPDATE USING (true);
CREATE POLICY "Anon Insert Order Items" ON public.order_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Anon Update Products" ON public.products FOR UPDATE USING (true);
CREATE POLICY "Anon Insert Products" ON public.products FOR INSERT WITH CHECK (true);
CREATE POLICY "Anon Insert Batches" ON public.inventory_batches FOR INSERT WITH CHECK (true);
CREATE POLICY "Anon Update Shifts" ON public.pos_shifts FOR ALL USING (true);
CREATE POLICY "Anon Insert Customers" ON public.customers FOR ALL USING (true);
CREATE POLICY "Anon Insert Expenses" ON public.store_expenses FOR ALL USING (true);

-- Enable Realtime WebSockets for Karachi Mart ERP
BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE 
    public.products, 
    public.orders, 
    public.order_items, 
    public.inventory_batches, 
    public.pos_shifts, 
    public.fleet_riders;
COMMIT;

-- =========================================================================
-- SEED DATA — LOAD EVERYTHING FOR KARACHI MART
-- =========================================================================

-- 1. Seed Categories
INSERT INTO public.categories (slug, name, description, icon, display_order) VALUES
('grocery', 'Staples & Grocery', 'Atta, Basmati Rice, Pulses, Cooking Oils, Ghee', 'grain', 1),
('dairy', 'Dairy & Chilled', 'Milk, Butter, Cheese, Yogurt, Eggs', 'egg', 2),
('beverages', 'Beverages & Tea', 'Tapal Tea, Rooh Afza, Juices, Cold Drinks', 'local_cafe', 3),
('spices', 'Spices & Recipe Mixes', 'Shan Masalas, Himalayan Pink Salt, Turmeric', 'soup_kitchen', 4),
('bakery', 'Bakery & Bread', 'Dawn Bread, Rusk, Buns, Bakery Biscuits', 'bakery_dining', 5),
('frozen', 'Frozen & Ready-to-Cook', 'K&Ns Nuggets, Parathas, Seekh Kababs', 'ac_unit', 6),
('personal-care', 'Personal Care', 'Lifebuoy, Lux, Sunsilk, Dettol Soaps', 'sanitizer', 7),
('cleaning', 'Household & Cleaning', 'Surf Excel, Harpic, Ariel, Dishwashers', 'cleaning_services', 8)
ON CONFLICT (slug) DO NOTHING;

-- 2. Seed Karachi Suppliers
INSERT INTO public.suppliers (code, name, contact_person, phone, email, address, credit_terms_days) VALUES
('SUP-SHAN', 'Shan Foods Karachi', 'Waqas Mansoor', '+92 21 3507 8900', 'orders@shanfoods.com', 'Sector 23, Korangi Industrial Area, Karachi', 15),
('SUP-DALDA', 'Dalda Foods Corp', 'Kashif Mehmood', '+92 21 3256 7100', 'distributors@dalda.com.pk', 'SITE Industrial Area, Karachi', 7),
('SUP-ENGRO', 'Engro Foods PK (FrieslandCampina)', 'Salman Sheikh', '+92 21 3529 7800', 'supplychain@engrofoods.com', 'Harbour Front, Clifton, Karachi', 0),
('SUP-TAPAL', 'Tapal Tea Pakistan Ltd', 'Irfan Hashmi', '+92 21 3506 3831', 'corporate@tapaltea.com', 'Plot 40, Korangi Industrial Zone, Karachi', 30),
('SUP-GUARD', 'Guard Agri Foods', 'Malik Jahangir', '+92 42 3636 5000', 'rice@guardagri.com', 'Karachi Wholesale Hub, Jodia Bazaar, Karachi', 15),
('SUP-DAWN', 'Dawn Bread Karachi', 'Aslam Pervez', '+92 21 3505 4411', 'fleet@dawnbread.com', 'Plot 12, Sector 15, Korangi, Karachi', 0),
('SUP-UNILEVER', 'Unilever Pakistan', 'Bilal Butt', '+92 21 3566 0062', 'orders@unilever.pk', 'Avari Plaza, Fatima Jinnah Rd, Karachi', 30),
('SUP-KNS', 'K&N''s Foods Pakistan', 'Tariq Rasheed', '+92 21 3455 1100', 'depot.gulshan@kns.com.pk', 'Central Cold Storage, Gulshan Depot, Karachi', 7)
ON CONFLICT (code) DO NOTHING;

-- 3. Seed Products
INSERT INTO public.products (sku, barcode, name, brand, category_slug, cost_price, selling_price, current_stock, reorder_level, unit, is_featured, image_url) VALUES
('GRD-BAS-5K', '89640001001', 'Guard Basmati Rice 5kg Bag', 'Guard', 'grocery', 1450.00, 1850.00, 45, 10, 'bag', true, 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=600&q=80'),
('DLD-OIL-5L', '89640001002', 'Dalda Cooking Oil 5 Litre Tin', 'Dalda', 'grocery', 2250.00, 2680.00, 18, 15, 'tin', true, 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=600&q=80'),
('TPL-DAN-950', '89640001003', 'Tapal Danedar Tea 950g Pouch', 'Tapal', 'beverages', 1280.00, 1520.00, 28, 12, 'pouch', true, 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80'),
('OLP-MILK-1L', '89640001004', 'Olper''s UHT Full Cream Milk 1L', 'Olpers', 'dairy', 245.00, 290.00, 64, 25, 'carton', true, 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=600&q=80'),
('SHN-BIRY-50', '89640001005', 'Shan Bombay Biryani Recipe Mix 50g', 'Shan', 'spices', 105.00, 140.00, 92, 20, 'box', true, 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=600&q=80'),
('DWN-BRD-PLN', '89640001006', 'Dawn Whole Wheat Bread (Family Size)', 'Dawn', 'bakery', 125.00, 160.00, 22, 10, 'loaf', false, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80'),
('PRM-YOG-400', '89640001007', 'Prema Natural Sweet Yogurt 400g Cup', 'Prema', 'dairy', 155.00, 195.00, 14, 15, 'cup', false, 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=600&q=80'),
('KNS-NUG-1K', '89640001008', 'K&N''s Chicken Nuggets 1kg Economy Pack', 'K&Ns', 'frozen', 1420.00, 1750.00, 16, 8, 'pack', true, 'https://images.unsplash.com/photo-1562967914-608f82629710?auto=format&fit=crop&w=600&q=80'),
('RHF-SYR-800', '89640001009', 'Hamdard Rooh Afza Sharbat 800ml Glass Bottle', 'Hamdard', 'beverages', 330.00, 420.00, 35, 10, 'bottle', true, 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=600&q=80'),
('NAT-CHIL-300', '89640001010', 'National Chilli Garlic Sauce 300g Squeezer', 'National', 'grocery', 165.00, 210.00, 40, 12, 'bottle', false, 'https://images.unsplash.com/photo-1589135233689-d64b54e7f861?auto=format&fit=crop&w=600&q=80'),
('MIT-JAM-450', '89640001011', 'Mitchell''s Golden Apple & Mixed Jam 450g', 'Mitchells', 'bakery', 265.00, 340.00, 19, 8, 'jar', false, 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?auto=format&fit=crop&w=600&q=80'),
('LIP-YLW-400', '89640001012', 'Lipton Yellow Label Black Tea 400g Pouch', 'Lipton', 'beverages', 620.00, 780.00, 31, 10, 'pouch', false, 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80'),
('SRF-EXC-1K', '89640001013', 'Surf Excel Washing Powder 1kg Polybag', 'Surf Excel', 'cleaning', 560.00, 690.00, 26, 10, 'bag', false, 'https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?auto=format&fit=crop&w=600&q=80'),
('LFB-SOP-115', '89640001014', 'Lifebuoy Total Active Germ Protection Soap 115g', 'Lifebuoy', 'personal-care', 95.00, 130.00, 75, 20, 'bar', false, 'https://images.unsplash.com/photo-1607006314188-f58c73456041?auto=format&fit=crop&w=600&q=80')
ON CONFLICT (sku) DO NOTHING;

-- 4. Seed Customers
INSERT INTO public.customers (name, phone, delivery_area, tier, loyalty_points, lifetime_spend, whatsapp_opt_in) VALUES
('Dr. Farah Naz', '0300-8291044', 'Bahadurabad Main', 'Platinum', 1450, 184200.00, true),
('Tariq Mehmood', '0321-4920199', 'Gulshan Block 5', 'Gold', 820, 92400.00, true),
('Zohra Batool', '0333-7182900', 'PECHS Block 2', 'Silver', 410, 45800.00, true),
('Asim Raza', '0301-8492019', 'North Nazimabad Block H', 'Gold', 680, 74200.00, true),
('Mrs. Sadaf Junaid', '0345-2281900', 'Gulshan Block 7', 'Silver', 310, 32100.00, true),
('Waseem Khattak', '0312-9910244', 'Gulshan Block 13-D', 'Bronze', 120, 14500.00, false)
ON CONFLICT (phone) DO NOTHING;

-- 5. Seed Fleet Riders
INSERT INTO public.fleet_riders (employee_code, name, bike_number, phone, status, cash_in_hand, zone_area) VALUES
('RDR-01', 'Tariq Khan', 'KHI-8291', '0300-1122334', 'on_delivery', 8240.00, 'PECHS & Bahadurabad'),
('RDR-02', 'Bilal Sheikh', 'KHI-3910', '0321-2233445', 'available', 3850.00, 'North Nazimabad'),
('RDR-03', 'Kamran Ali', 'KHI-5512', '0333-3344556', 'on_delivery', 3450.00, 'Gulshan-e-Iqbal'),
('RDR-04', 'Zeeshan Farooq', 'KHI-9941', '0345-4455667', 'available', 0.00, 'Gulshan-e-Iqbal'),
('RDR-05', 'Farrukh Javed', 'KHI-VAN-02', '0312-5566778', 'available', 0.00, 'DHA & Clifton'),
('RDR-06', 'Hamza Qureshi', 'KHI-7721', '0308-6677889', 'available', 0.00, 'PECHS')
ON CONFLICT (employee_code) DO NOTHING;

-- 6. Seed Active POS Shift #4029
INSERT INTO public.pos_shifts (shift_number, cashier_name, branch_code, opening_float, cash_collected, card_collected, raast_collected, expected_drawer, physical_counted, discrepancy, status, opened_at) VALUES
('SHIFT-4029', 'Muhammad Ahmed', 'KHI-01', 25000.00, 165400.00, 55000.00, 64150.00, 173250.00, 173250.00, 0.00, 'open', NOW() - INTERVAL '6 hours')
ON CONFLICT (shift_number) DO NOTHING;

-- 7. Seed Initial Orders
INSERT INTO public.orders (order_number, channel, customer_name, customer_phone, delivery_area, order_status, payment_method, payment_status, subtotal, tax, discount, total_amount) VALUES
('INV-9841', 'pos', 'Tariq Mehmood', '0321-4920199', 'Walk-in Counter 02', 'completed', 'cash', 'paid', 4750.00, 100.00, 0.00, 4850.00),
('ORD-7821', 'online', 'Zohra Batool', '0333-7182900', 'PECHS Block 2', 'out_for_delivery', 'cod', 'pending', 8080.00, 160.00, 0.00, 8240.00),
('INV-9840', 'pos', 'Asim Raza', '0301-8492019', 'Express Counter 04', 'completed', 'card', 'paid', 2150.00, 40.00, 0.00, 2190.00),
('ORD-7825', 'online', 'Dr. Farah Naz', '0300-8291044', 'Bahadurabad Main', 'packing', 'cod', 'pending', 11180.00, 220.00, 0.00, 11400.00)
ON CONFLICT (order_number) DO NOTHING;

-- 8. Seed Store Expenses
INSERT INTO public.store_expenses (voucher_number, category, payee, payment_mode, amount, notes) VALUES
('EXP-841', 'Electricity & K-Electric', 'K-Electric Consumer # 049281', 'HBL Corporate Bank Wire', 165000.00, 'Commercial peak units for cold room and chillers'),
('EXP-840', 'Store Rent & Lease', 'Gulshan Plaza Commercial Landlord', 'Cheque # 491028', 240000.00, 'October 2024 ground floor retail lease'),
('EXP-839', 'Generator Diesel Fuel', 'PSO Petrol Pump Rashid Minhas', 'Cash Register Drop', 48000.00, '200 Litres Euro-5 Diesel for store load-shedding backup'),
('EXP-838', 'Fleet Fuel Allowance', 'Karachi Mart Courier Fleet', 'Petty Cash Float', 32000.00, 'Weekly petrol allowance for 8 active dispatch motorbikes')
ON CONFLICT (voucher_number) DO NOTHING;

-- =========================================================================
-- END OF SCHEMA SCRIPT — KARACHI MART DATABASE READY
-- =========================================================================
