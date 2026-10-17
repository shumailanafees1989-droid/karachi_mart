/**
 * Karachi Mart Retail ERP — Supabase Data Layer & Realtime Client
 * Connects the ERP and Web Storefront to Supabase PostgreSQL.
 */

(function(window) {
  'use strict';

  // Default seed products fallback
  const SEED_PRODUCTS = [
    { id: '1', sku: 'GRD-BAS-5K', barcode: '89640001001', name: 'Guard Basmati Rice 5kg Bag', brand: 'Guard', category_slug: 'grocery', cost_price: 1450, selling_price: 1850, current_stock: 45, reorder_level: 10, unit: 'bag', image_url: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=600&q=80' },
    { id: '2', sku: 'DLD-OIL-5L', barcode: '89640001002', name: 'Dalda Cooking Oil 5 Litre Tin', brand: 'Dalda', category_slug: 'grocery', cost_price: 2250, selling_price: 2680, current_stock: 18, reorder_level: 15, unit: 'tin', image_url: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=600&q=80' },
    { id: '3', sku: 'TPL-DAN-950', barcode: '89640001003', name: 'Tapal Danedar Tea 950g Pouch', brand: 'Tapal', category_slug: 'beverages', cost_price: 1280, selling_price: 1520, current_stock: 28, reorder_level: 12, unit: 'pouch', image_url: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80' },
    { id: '4', sku: 'OLP-MILK-1L', barcode: '89640001004', name: 'Olper\'s UHT Full Cream Milk 1L', brand: 'Olpers', category_slug: 'dairy', cost_price: 245, selling_price: 290, current_stock: 64, reorder_level: 25, unit: 'carton', image_url: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=600&q=80' },
    { id: '5', sku: 'SHN-BIRY-50', barcode: '89640001005', name: 'Shan Bombay Biryani Recipe Mix 50g', brand: 'Shan', category_slug: 'spices', cost_price: 105, selling_price: 140, current_stock: 92, reorder_level: 20, unit: 'box', image_url: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=600&q=80' },
    { id: '6', sku: 'DWN-BRD-PLN', barcode: '89640001006', name: 'Dawn Whole Wheat Bread (Family Size)', brand: 'Dawn', category_slug: 'bakery', cost_price: 125, selling_price: 160, current_stock: 22, reorder_level: 10, unit: 'loaf', image_url: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80' },
    { id: '7', sku: 'PRM-YOG-400', barcode: '89640001007', name: 'Prema Natural Sweet Yogurt 400g Cup', brand: 'Prema', category_slug: 'dairy', cost_price: 155, selling_price: 195, current_stock: 14, reorder_level: 15, unit: 'cup', image_url: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=600&q=80' },
    { id: '8', sku: 'KNS-NUG-1K', barcode: '89640001008', name: 'K&N\'s Chicken Nuggets 1kg Economy Pack', brand: 'K&Ns', category_slug: 'frozen', cost_price: 1420, selling_price: 1750, current_stock: 16, reorder_level: 8, unit: 'pack', image_url: 'https://images.unsplash.com/photo-1562967914-608f82629710?auto=format&fit=crop&w=600&q=80' },
    { id: '9', sku: 'RHF-SYR-800', barcode: '89640001009', name: 'Hamdard Rooh Afza Sharbat 800ml Bottle', brand: 'Hamdard', category_slug: 'beverages', cost_price: 330, selling_price: 420, current_stock: 35, reorder_level: 10, unit: 'bottle', image_url: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=600&q=80' },
    { id: '10', sku: 'NAT-CHIL-300', barcode: '89640001010', name: 'National Chilli Garlic Sauce 300g Squeezer', brand: 'National', category_slug: 'grocery', cost_price: 165, selling_price: 210, current_stock: 40, reorder_level: 12, unit: 'bottle', image_url: 'https://images.unsplash.com/photo-1589135233689-d64b54e7f861?auto=format&fit=crop&w=600&q=80' },
    { id: '11', sku: 'MIT-JAM-450', barcode: '89640001011', name: 'Mitchell\'s Golden Apple & Mixed Jam 450g', brand: 'Mitchells', category_slug: 'bakery', cost_price: 265, selling_price: 340, current_stock: 19, reorder_level: 8, unit: 'jar', image_url: 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?auto=format&fit=crop&w=600&q=80' },
    { id: '12', sku: 'LIP-YLW-400', barcode: '89640001012', name: 'Lipton Yellow Label Black Tea 400g Pouch', brand: 'Lipton', category_slug: 'beverages', cost_price: 620, selling_price: 780, current_stock: 31, reorder_level: 10, unit: 'pouch', image_url: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80' },
    { id: '13', sku: 'SRF-EXC-1K', barcode: '89640001013', name: 'Surf Excel Washing Powder 1kg Polybag', brand: 'Surf Excel', category_slug: 'cleaning', cost_price: 560, selling_price: 690, current_stock: 26, reorder_level: 10, unit: 'bag', image_url: 'https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?auto=format&fit=crop&w=600&q=80' },
    { id: '14', sku: 'LFB-SOP-115', barcode: '89640001014', name: 'Lifebuoy Total Active Germ Protection Soap 115g', brand: 'Lifebuoy', category_slug: 'personal-care', cost_price: 95, selling_price: 130, current_stock: 75, reorder_level: 20, unit: 'bar', image_url: 'https://images.unsplash.com/photo-1607006314188-f58c73456041?auto=format&fit=crop&w=600&q=80' }
  ];

  let supabaseClient = null;

  function getConfig() {
    const url = localStorage.getItem('KM_SUPABASE_URL') || (window.ENV && window.ENV.SUPABASE_URL) || '';
    const key = localStorage.getItem('KM_SUPABASE_ANON_KEY') || (window.ENV && window.ENV.SUPABASE_ANON_KEY) || '';
    const isReal = url && !url.includes('your-project-ref') && key && !key.includes('your-anon-key');
    return { url, key, isReal };
  }

  function initClient() {
    const config = getConfig();
    if (config.isReal && window.supabase && window.supabase.createClient) {
      try {
        supabaseClient = window.supabase.createClient(config.url, config.key);
        console.log('[KarachiMartDB] Initialized live Supabase client for:', config.url);
      } catch (err) {
        console.warn('[KarachiMartDB] Failed to init Supabase client:', err);
        supabaseClient = null;
      }
    }
    return supabaseClient;
  }

  // Self-init on load
  initClient();

  const KarachiMartDB = {
    getConfig,
    initClient,
    getSeedProducts() {
      return JSON.parse(JSON.stringify(SEED_PRODUCTS));
    },

    isConfigured() {
      return Boolean(supabaseClient);
    },

    async testConnection(url, key) {
      if (!window.supabase || !window.supabase.createClient) {
        return { success: false, error: 'Supabase JS library not loaded. Check internet connection.' };
      }
      try {
        const client = window.supabase.createClient(url, key);
        const { data, error } = await client.from('products').select('count', { count: 'exact', head: true });
        if (error) {
          // If table doesn't exist yet, it's still a reachable database!
          if (error.code === '42P01') {
            return { success: true, message: 'Connected to Supabase! (Tables need to be created using schema SQL)', needsSchema: true };
          }
          return { success: false, error: error.message };
        }
        return { success: true, message: 'Connected successfully to Karachi Mart Supabase database!', count: data };
      } catch (err) {
        return { success: false, error: err.message || 'Connection failed' };
      }
    },

    saveConfig(url, key) {
      localStorage.setItem('KM_SUPABASE_URL', url.trim());
      localStorage.setItem('KM_SUPABASE_ANON_KEY', key.trim());
      initClient();
    },

    clearConfig() {
      localStorage.removeItem('KM_SUPABASE_URL');
      localStorage.removeItem('KM_SUPABASE_ANON_KEY');
      supabaseClient = null;
    },

    // 1. PRODUCTS
    async getProducts() {
      if (supabaseClient) {
        try {
          const { data, error } = await supabaseClient.from('products').select('*').order('name');
          if (!error && data && data.length > 0) {
            return data;
          }
        } catch (e) {
          console.warn('[KarachiMartDB] Supabase getProducts fallback:', e);
        }
      }
      // Return cached/seeded
      const cached = localStorage.getItem('KM_MOCK_PRODUCTS');
      if (cached) {
        try { return JSON.parse(cached); } catch (e) {}
      }
      return this.getSeedProducts();
    },

    async updateStock(sku, deltaQty) {
      if (supabaseClient) {
        try {
          const { data: prod } = await supabaseClient.from('products').select('current_stock').eq('sku', sku).single();
          if (prod) {
            const newStock = Math.max(0, prod.current_stock + deltaQty);
            await supabaseClient.from('products').update({ current_stock: newStock, updated_at: new Date() }).eq('sku', sku);
          }
        } catch (e) {
          console.warn('[KarachiMartDB] Failed to update stock in Supabase:', e);
        }
      }
      // Update local storage cache
      const products = await this.getProducts();
      const p = products.find(i => i.sku === sku);
      if (p) {
        p.current_stock = Math.max(0, p.current_stock + deltaQty);
        localStorage.setItem('KM_MOCK_PRODUCTS', JSON.stringify(products));
      }
    },

    // 2. ORDERS
    async createOrder(orderData, lineItems) {
      let createdOrder = { ...orderData, id: 'ord-' + Date.now(), created_at: new Date().toISOString() };
      if (supabaseClient) {
        try {
          const { data, error } = await supabaseClient.from('orders').insert([orderData]).select().single();
          if (!error && data) {
            createdOrder = data;
            if (lineItems && lineItems.length > 0) {
              const formattedItems = lineItems.map(item => ({
                order_id: createdOrder.id,
                product_id: item.product_id || null,
                product_name: item.name,
                sku: item.sku,
                unit_price: item.price,
                quantity: item.qty,
                total_price: item.price * item.qty
              }));
              await supabaseClient.from('order_items').insert(formattedItems);
            }
            // Decrement stock in Supabase for each item
            for (const it of lineItems) {
              await this.updateStock(it.sku, -it.qty);
            }
          }
        } catch (e) {
          console.warn('[KarachiMartDB] createOrder fallback to local:', e);
        }
      } else {
        // Local simulation
        for (const it of lineItems) {
          await this.updateStock(it.sku, -it.qty);
        }
      }
      return createdOrder;
    },

    async getOrders(limit = 20) {
      if (supabaseClient) {
        try {
          const { data, error } = await supabaseClient.from('orders').select('*').order('created_at', { ascending: false }).limit(limit);
          if (!error && data && data.length > 0) return data;
        } catch (e) {}
      }
      return [
        { order_number: 'INV-9841', channel: 'pos', customer_name: 'Tariq Mehmood', delivery_area: 'Walk-in Counter 02', order_status: 'completed', payment_method: 'cash', total_amount: 4850, created_at: new Date().toISOString() },
        { order_number: 'ORD-7821', channel: 'online', customer_name: 'Zohra Batool', delivery_area: 'PECHS Block 2', order_status: 'out_for_delivery', payment_method: 'cod', total_amount: 8240, created_at: new Date().toISOString() },
        { order_number: 'INV-9840', channel: 'pos', customer_name: 'Asim Raza', delivery_area: 'Express Counter 04', order_status: 'completed', payment_method: 'card', total_amount: 2190, created_at: new Date().toISOString() },
        { order_number: 'ORD-7825', channel: 'online', customer_name: 'Dr. Farah Naz', delivery_area: 'Bahadurabad Main', order_status: 'packing', payment_method: 'cod', total_amount: 11400, created_at: new Date().toISOString() }
      ];
    },

    // 3. LOAD EVERYTHING / SEED DATABASE VIA REST
    async seedDatabase(onProgress) {
      if (!supabaseClient) {
        throw new Error('Please configure a valid Supabase URL and Anon Key first.');
      }
      if (onProgress) onProgress('Seeding categories...');
      await supabaseClient.from('categories').upsert([
        { slug: 'grocery', name: 'Staples & Grocery', description: 'Atta, Basmati Rice, Pulses, Ghee', icon: 'grain', display_order: 1 },
        { slug: 'dairy', name: 'Dairy & Chilled', description: 'Milk, Butter, Cheese, Yogurt, Eggs', icon: 'egg', display_order: 2 },
        { slug: 'beverages', name: 'Beverages & Tea', description: 'Tapal Tea, Rooh Afza, Juices', icon: 'local_cafe', display_order: 3 },
        { slug: 'spices', name: 'Spices & Recipe Mixes', description: 'Shan Masalas, Himalayan Salt', icon: 'soup_kitchen', display_order: 4 },
        { slug: 'bakery', name: 'Bakery & Bread', description: 'Dawn Bread, Rusk, Buns', icon: 'bakery_dining', display_order: 5 },
        { slug: 'frozen', name: 'Frozen & Ready-to-Cook', description: 'K&Ns Nuggets, Parathas', icon: 'ac_unit', display_order: 6 },
        { slug: 'personal-care', name: 'Personal Care', description: 'Lifebuoy, Lux, Dettol Soaps', icon: 'sanitizer', display_order: 7 },
        { slug: 'cleaning', name: 'Household & Cleaning', description: 'Surf Excel, Harpic, Ariel', icon: 'cleaning_services', display_order: 8 }
      ], { onConflict: 'slug' });

      if (onProgress) onProgress('Seeding products...');
      await supabaseClient.from('products').upsert(SEED_PRODUCTS.map(p => ({
        sku: p.sku,
        barcode: p.barcode,
        name: p.name,
        brand: p.brand,
        category_slug: p.category_slug,
        cost_price: p.cost_price,
        selling_price: p.selling_price,
        current_stock: p.current_stock,
        reorder_level: p.reorder_level,
        unit: p.unit,
        image_url: p.image_url,
        is_active: true
      })), { onConflict: 'sku' });

      if (onProgress) onProgress('Seeding customers...');
      await supabaseClient.from('customers').upsert([
        { name: 'Dr. Farah Naz', phone: '0300-8291044', delivery_area: 'Bahadurabad Main', tier: 'Platinum', loyalty_points: 1450, lifetime_spend: 184200, whatsapp_opt_in: true },
        { name: 'Tariq Mehmood', phone: '0321-4920199', delivery_area: 'Gulshan Block 5', tier: 'Gold', loyalty_points: 820, lifetime_spend: 92400, whatsapp_opt_in: true },
        { name: 'Zohra Batool', phone: '0333-7182900', delivery_area: 'PECHS Block 2', tier: 'Silver', loyalty_points: 410, lifetime_spend: 45800, whatsapp_opt_in: true },
        { name: 'Asim Raza', phone: '0301-8492019', delivery_area: 'North Nazimabad Block H', tier: 'Gold', loyalty_points: 680, lifetime_spend: 74200, whatsapp_opt_in: true }
      ], { onConflict: 'phone' });

      if (onProgress) onProgress('Seeding riders...');
      await supabaseClient.from('fleet_riders').upsert([
        { employee_code: 'RDR-01', name: 'Tariq Khan', bike_number: 'KHI-8291', phone: '0300-1122334', status: 'on_delivery', cash_in_hand: 8240, zone_area: 'PECHS & Bahadurabad' },
        { employee_code: 'RDR-02', name: 'Bilal Sheikh', bike_number: 'KHI-3910', phone: '0321-2233445', status: 'available', cash_in_hand: 3850, zone_area: 'North Nazimabad' },
        { employee_code: 'RDR-03', name: 'Kamran Ali', bike_number: 'KHI-5512', phone: '0333-3344556', status: 'on_delivery', cash_in_hand: 3450, zone_area: 'Gulshan-e-Iqbal' },
        { employee_code: 'RDR-04', name: 'Zeeshan Farooq', bike_number: 'KHI-9941', phone: '0345-4455667', status: 'available', cash_in_hand: 0, zone_area: 'Gulshan-e-Iqbal' }
      ], { onConflict: 'employee_code' });

      if (onProgress) onProgress('Seeding shift #4029...');
      await supabaseClient.from('pos_shifts').upsert([
        { shift_number: 'SHIFT-4029', cashier_name: 'Muhammad Ahmed', branch_code: 'KHI-01', opening_float: 25000, cash_collected: 165400, expected_drawer: 173250, physical_counted: 173250, discrepancy: 0, status: 'open' }
      ], { onConflict: 'shift_number' });

      if (onProgress) onProgress('Database seeded successfully!');
      return { success: true };
    },

    // 4. REALTIME WEBSOCKET LISTENER
    subscribeToOrders(callback) {
      if (!supabaseClient) return null;
      try {
        const channel = supabaseClient.channel('realtime_orders')
          .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'orders' }, payload => {
            console.log('[KarachiMartDB] Realtime Order Received:', payload.new);
            if (callback) callback(payload.new);
          })
          .subscribe();
        return channel;
      } catch (e) {
        console.warn('[KarachiMartDB] Realtime subscribe error:', e);
        return null;
      }
    }
  };

  window.KarachiMartDB = KarachiMartDB;
})(window);
