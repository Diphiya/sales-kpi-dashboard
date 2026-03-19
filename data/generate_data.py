import csv
import random
from datetime import date, timedelta

random.seed(42)

REGIONS = ['North-East', 'South-East', 'Midwest', 'South-Central', 'West', 'North-West']
SEGMENTS = ['Consumer', 'Corporate', 'Home Office']
CATEGORIES = {
    'Technology':    ['Laptops', 'Phones', 'Accessories', 'Monitors', 'Printers'],
    'Office Supplies': ['Paper', 'Binders', 'Pens & Pencils', 'Labels', 'Storage'],
    'Furniture':     ['Chairs', 'Tables', 'Bookcases', 'Desks', 'Sofas'],
}
PRODUCTS = []
pid = 1
for cat, subs in CATEGORIES.items():
    for sub in subs:
        for i in range(1, 4):
            PRODUCTS.append({
                'product_id': f'PROD-{pid:04d}',
                'product_name': f'{sub} Model {i}',
                'category': cat,
                'sub_category': sub,
                'unit_cost_base': random.uniform(20, 800),
            })
            pid += 1

CUSTOMERS = []
NAMES = ['Alice Johnson','Bob Smith','Carol White','David Brown','Eva Green',
         'Frank Lee','Grace Kim','Henry Park','Irene Ng','James Tan',
         'Kate Wu','Leo Chen','Mia Wang','Nathan Liu','Olivia Ma']
for i, name in enumerate(NAMES, 1):
    CUSTOMERS.append({
        'customer_id': f'CUST-{i:04d}',
        'customer_name': name,
        'segment': random.choice(SEGMENTS),
        'city': random.choice(['New York','Los Angeles','Chicago','Houston','Phoenix']),
        'state': random.choice(['NY','CA','IL','TX','AZ','FL','WA','OR']),
        'region_name': random.choice(REGIONS),
    })

rows = []
order_counter = 1
start = date(2022, 1, 1)
end   = date(2024, 12, 31)

for _ in range(2000):
    delta = (end - start).days
    order_date = start + timedelta(days=random.randint(0, delta))
    ship_date  = order_date + timedelta(days=random.randint(2, 10))
    customer   = random.choice(CUSTOMERS)
    product    = random.choice(PRODUCTS)
    qty        = random.randint(1, 15)
    markup     = random.uniform(1.2, 2.5)
    unit_price = round(product['unit_cost_base'] * markup, 2)
    unit_cost  = round(product['unit_cost_base'], 2)
    discount   = random.choice([0, 0, 0, 0.05, 0.10, 0.15, 0.20, 0.30])
    cost       = round(unit_cost * qty, 2)

    rows.append({
        'order_id':       f'ORD-{order_counter:06d}',
        'order_date':     order_date.strftime('%m/%d/%Y'),
        'ship_date':      ship_date.strftime('%m/%d/%Y'),
        'customer_id':    customer['customer_id'],
        'customer_name':  customer['customer_name'],
        'segment':        customer['segment'],
        'city':           customer['city'],
        'state':          customer['state'],
        'region_name':    customer['region_name'],
        'product_id':     product['product_id'],
        'product_name':   product['product_name'],
        'category':       product['category'],
        'sub_category':   product['sub_category'],
        'quantity':       qty,
        'unit_price':     unit_price,
        'discount':       discount,
        'unit_cost':      unit_cost,
        'cost':           cost,
    })
    order_counter += 1

rows.sort(key=lambda r: r['order_date'])

fieldnames = list(rows[0].keys())
with open('/home/claude/sales-kpi-dashboard/data/sales_data.csv', 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)

print(f"Generated {len(rows)} rows")
