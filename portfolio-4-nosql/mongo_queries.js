// Portfolio 4: MongoDB (document model) for the glasses store
db = db.getSiblingDB("glasses_store");
db.products.drop();
db.orders.drop();

print("===== 1. INSERT: products with flexible lens attributes =====");
db.products.insertMany([
  {
    sku: "CR-001", name: "Classic Round", category: "Photochromic Glasses",
    lens: { type: "PHOTOCHROMIC", tint: "grey", transition_seconds: 30, uv400: true },
    variants: [
      { sku: "CR-BLK-M", colour: "Black", size: "M", price: 25000, stock: 40 },
      { sku: "CR-TOR-M", colour: "Tortoise", size: "M", price: 26000, stock: 15 }
    ],
    reviews: [{ customer: "Ada", rating: 5, comment: "Darkens quickly outdoors" }]
  },
  {
    sku: "SQ-002", name: "Square Office", category: "Anti-Blue Light Glasses",
    lens: { type: "ANTI_BLUE_LIGHT", blue_light_filter_pct: 40, coating: "multi-layer" },
    variants: [
      { sku: "SQ-BLK-S", colour: "Black", size: "S", price: 18000, stock: 60 },
      { sku: "SQ-CLR-M", colour: "Clear", size: "M", price: 18500, stock: 35 }
    ],
    reviews: [{ customer: "Tunde", rating: 4, comment: "Less eye strain at work" }]
  },
  {
    sku: "AV-003", name: "Aviator Hybrid", category: "Photochromic Glasses",
    lens: { type: "PHOTOCHROMIC", tint: "brown", transition_seconds: 45, uv400: true },
    variants: [{ sku: "AV-GLD-L", colour: "Gold", size: "L", price: 30000, stock: 12 }],
    reviews: []
  }
]);

print("===== 2. INSERT: orders with embedded items, payment and delivery =====");
db.orders.insertMany([
  {
    orderId: 1001, customer: { id: 1, name: "Ada", email: "ada@mail.com" },
    items: [
      { sku: "CR-BLK-M", name: "Classic Round", lens_type: "PHOTOCHROMIC", qty: 1, price: 25000 },
      { sku: "SQ-BLK-S", name: "Square Office", lens_type: "ANTI_BLUE_LIGHT", qty: 2, price: 18000 }
    ],
    total: 61000, status: "PAID",
    payment: { method: "TRANSFER", status: "SUCCESS" },
    delivery: { status: "SHIPPED", address: "12 Sample Street, Abuja" },
    createdAt: new Date()
  },
  {
    orderId: 1002, customer: { id: 2, name: "Tunde", email: "tunde@mail.com" },
    items: [{ sku: "AV-GLD-L", name: "Aviator Hybrid", lens_type: "PHOTOCHROMIC", qty: 1, price: 30000 }],
    total: 30000, status: "PENDING",
    payment: { method: "PAY_ON_DELIVERY", status: "PENDING" },
    delivery: { status: "PROCESSING", address: "5 Example Road, Lagos" },
    createdAt: new Date()
  }
]);

print("===== 3. QUERY: photochromic glasses with a variant under 26000 =====");
printjson(db.products.find(
  { "lens.type": "PHOTOCHROMIC", "variants.price": { $lt: 26000 } },
  { name: 1, "lens.tint": 1, _id: 0 }
).toArray());

print("===== 4. QUERY: anti-blue light glasses filtering at least 40% =====");
printjson(db.products.find(
  { "lens.blue_light_filter_pct": { $gte: 40 } },
  { name: 1, "lens.blue_light_filter_pct": 1, _id: 0 }
).toArray());

print("===== 5. AGGREGATION: revenue and units by lens type =====");
printjson(db.orders.aggregate([
  { $unwind: "$items" },
  { $group: { _id: "$items.lens_type",
              units: { $sum: "$items.qty" },
              revenue: { $sum: { $multiply: ["$items.qty", "$items.price"] } } } },
  { $sort: { revenue: -1 } }
]).toArray());

print("===== 6. AGGREGATION: average rating per frame =====");
printjson(db.products.aggregate([
  { $unwind: "$reviews" },
  { $group: { _id: "$name", avg_rating: { $avg: "$reviews.rating" }, reviews: { $sum: 1 } } }
]).toArray());

print("===== 7. INDEXING: generate 5,000 products, compare before/after =====");
var docs = [];
for (var i = 1; i <= 5000; i++) {
  docs.push({
    sku: "GEN-" + i, name: "Generated Frame " + i,
    category: (i % 2 === 0) ? "Photochromic Glasses" : "Anti-Blue Light Glasses",
    lens: { type: (i % 2 === 0) ? "PHOTOCHROMIC" : "ANTI_BLUE_LIGHT" },
    variants: [{ sku: "GEN-V" + i, colour: "Black", size: "M",
                 price: 15000 + Math.floor(Math.random() * 30000), stock: Math.floor(Math.random() * 100) }],
    reviews: []
  });
}
db.products.insertMany(docs);

var q = { "lens.type": "PHOTOCHROMIC", "variants.price": { $lt: 20000 } };

var before = db.products.find(q).explain("executionStats");
print("BEFORE INDEX -> stage: " + before.queryPlanner.winningPlan.stage +
      ", docs examined: " + before.executionStats.totalDocsExamined +
      ", returned: " + before.executionStats.nReturned +
      ", time ms: " + before.executionStats.executionTimeMillis);

db.products.createIndex({ "lens.type": 1, "variants.price": 1 });

var after = db.products.find(q).explain("executionStats");
print("AFTER INDEX  -> plan: " + JSON.stringify(after.queryPlanner.winningPlan).substring(0, 200));
print("AFTER INDEX  -> docs examined: " + after.executionStats.totalDocsExamined +
      ", returned: " + after.executionStats.nReturned +
      ", time ms: " + after.executionStats.executionTimeMillis);
