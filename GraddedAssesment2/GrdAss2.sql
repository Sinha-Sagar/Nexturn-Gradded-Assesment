// 1.1 Create the collections

	db.createCollection("customers");
	
	db.createCollection("orders");
	
	db.customers.insertMany([
	  {
		"name": "John Doe", 
		"email": "johndoe@example.com", 
		"address": { "street": "123 Main St", "city": "Springfield", "zipcode": "12345" }, 
		"phone": "555-1234", 
		"registration_date": ISODate("2023-01-01T12:00:00Z")
	  },
	  {
		"name": "Sagar",
		"email": "sinhasagar@example.com",
		"address": { "street": "456", "city": "Greenfield", "zipcode": "67890" },
		"phone": "555-6789",
		"registration_date": ISODate("2023-02-10T09:30:00Z")
	  },
	  {
		"name": "Alice Johnson",
		"email": "alicej@example.com",
		"address": { "street": "789 Oak St", "city": "Lincoln", "zipcode": "24680" },
		"phone": "555-2468",
		"registration_date": ISODate("2023-03-15T14:15:00Z")
	  },
	  {
		"name": "Bob Williams",
		"email": "bobwilliams@example.com",
		"address": { "street": "101 Maple St", "city": "Riverdale", "zipcode": "13579" },
		"phone": "555-1357",
		"registration_date": ISODate("2023-04-05T16:45:00Z")
	  },
	  {
		"name": "Emily Davis",
		"email": "emilyd@example.com",
		"address": { "street": "202 Birch St", "city": "Summerville", "zipcode": "11223" },
		"phone": "555-1122",
		"registration_date": ISODate("2023-05-20T11:00:00Z")
	  }
	]);
	
	db.orders.insertMany([
		  {
			"order_id": "ORD123456", 
			"customer_id": ObjectId('673334589a8600cc95d9e08d'), 
			"order_date": ISODate("2023-05-15T14:00:00Z"), 
			"status": "shipped", 
			"items": [ 
				{ "product_name": "Laptop", "quantity": 1, "price": 1500 }, 
				{ "product_name": "Mouse", "quantity": 2, "price": 25 } 
			], 
			"total_value": 1550 
		  },
		  {
			"order_id": "ORD123457",
			"customer_id": ObjectId('673334589a8600cc95d9e08e'),
			"order_date": ISODate("2023-06-10T10:30:00Z"),
			"status": "processing",
			"items": [
			  { "product_name": "Tablet", "quantity": 1, "price": 300 },
			  { "product_name": "Keyboard", "quantity": 1, "price": 50 }
			],
			"total_value": 350
		  },
		  {
			"order_id": "ORD123458",
			"customer_id": ObjectId('673334589a8600cc95d9e08f'),
			"order_date": ISODate("2023-07-05T12:15:00Z"),
			"status": "shipped",
			"items": [
			  { "product_name": "Smartphone", "quantity": 1, "price": 800 },
			  { "product_name": "Charger", "quantity": 2, "price": 25 }
			],
			"total_value": 850
		  },
		  {
			"order_id": "ORD123459",
			"customer_id": ObjectId('673334589a8600cc95d9e090'),
			"order_date": ISODate("2023-08-20T15:00:00Z"),
			"status": "delivered",
			"items": [
			  { "product_name": "Monitor", "quantity": 1, "price": 200 },
			  { "product_name": "HDMI Cable", "quantity": 1, "price": 15 }
			],
			"total_value": 215
		  },
		  {
			"order_id": "ORD123460",
			"customer_id": ObjectId('673334589a8600cc95d9e091'),
			"order_date": ISODate("2023-09-10T09:00:00Z"),
			"status": "pending",
			"items": [
			  { "product_name": "Headphones", "quantity": 2, "price": 100 },
			  { "product_name": "Mouse Pad", "quantity": 1, "price": 20 }
			],
			"total_value": 220
		  }
]);

// 1.2 Find Orders for a Specific Customer:
	
	db.orders.find({ "customer_id": ObjectId('673334589a8600cc95d9e08d')},  { "items": 1, "_id": 0 } );
	
// 1.3 Find the Customer for a Specific Order:
	
	let order = db.orders.findOne({ "order_id": "ORD123456" });
	db.customers.findOne({ "_id": order.customer_id });
	
// 1.4 Update Order Status:

	db.orders.updateOne({ "order_id": "ORD123456" }, { $set: { "status": "delivered" } });
	
// 1.5 Delete an Order:

	db.orders.deleteOne({ "order_id": "ORD123456" });
	
/* ------------------------------------------------------------------------------------------------------------ */

//2.1 Calculate Total Value of All Orders by Customer:

	db.orders.aggregate([
	  { $group: { _id: "$customer_id", totalOrderValue: { $sum: "$total_value" } } },
	  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customer_info" } },
	  { $unwind: "$customer_info" },
	  { $project: { _id: 0, "customer_info.name": 1, totalOrderValue: 1 } }
	]);

//2.2. Group Orders by Status:

	db.orders.aggregate([
		{ $group: { _id: "$status", count: { $sum: 1 } } }
	]);

//2.3. List Customers with Their Recent Orders:

	db.orders.aggregate([
	  { $sort: { "order_date": -1 } },
	  { $group: { _id: "$customer_id", recentOrder: { $first: "$$ROOT" } } },
	  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customer_info" } },
	  { $unwind: "$customer_info" },
	  { $project: { "customer_info.name": 1, "customer_info.email": 1, "recentOrder.order_id": 1, "recentOrder.total_value": 1 } }
	]);
	
//2.4. Find the Most Expensive Order by Customer:

	db.orders.aggregate([
	  { $sort: { "total_value": -1 } },
	  { $group: { _id: "$customer_id", mostExpensiveOrder: { $first: "$$ROOT" } } },
	  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customer_info" } },
	  { $unwind: "$customer_info" },
	  { $project: { "customer_info.name": 1, "mostExpensiveOrder.order_id": 1, "mostExpensiveOrder.total_value": 1 } }
	]);
	
	
/* ------------------------------------------------------------------------------------------------------------ */

//3.1 Find All Customers Who Placed Orders in the Last Month

	let lastMonth = ISODate("2023-07-05T12:15:00Z");

	db.orders.aggregate([
	  { $match: { "order_date": { $gte: lastMonth } } },
	  { $group: { _id: "$customer_id", recentOrderDate: { $max: "$order_date" } } },
	  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customer_info" } },
	  { $unwind: "$customer_info" },
	  { $project: { "customer_info.name": 1, "customer_info.email": 1, recentOrderDate: 1 } }
	]);


//3.2.	Find All Products Ordered by a Specific Customer:

	let customer = db.customers.findOne({ "name": "Sagar" });

	db.orders.aggregate([
	  { $match: { "customer_id": customer._id } },
	  { $unwind: "$items" },
	  { $group: { _id: "$items.product_name", totalQuantity: { $sum: "$items.quantity" } } }
	]);


//3.3. Find the Top 3 Customers with the Most Expensive Total Orders:

	db.orders.aggregate([
	  { $group: { _id: "$customer_id", totalOrderValue: { $sum: "$total_value" } } },
	  { $sort: { totalOrderValue: -1 } },
	  { $limit: 3 },
	  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customer_info" } },
	  { $unwind: "$customer_info" },
	  { $project: { "customer_info.name": 1, totalOrderValue: 1 } }
	]);


//3.4. Add a New Order for an Existing Customer:
	
	let customer = db.customers.findOne({ "name": "Sagar" });

	db.orders.insertOne({
	  "order_id": "ORD123457",
	  "customer_id": customer._id,
	  "order_date": ISODate("2023-11-12T10:00:00Z"),
	  "status": "pending",
	  "items": [
		{ "product_name": "Smartphone", "quantity": 1, "price": 800 },
		{ "product_name": "Headphones", "quantity": 1, "price": 150 }
	  ],
	  "total_value": 950
	});

	

/* ------------------------------------------------------------------------------------------------------------ */
//4.1. Find All Customers Who Placed Orders in the Last Month:

	db.customers.aggregate([
	  { $lookup: { from: "orders", localField: "_id", foreignField: "customer_id", as: "orders" } },
	  { $match: { "orders": { $size: 0 } } },
	  { $project: { "name": 1, "email": 1 } }
	]);
	
//4.2. Calculate the Average Number of Items Ordered per Order:

	db.orders.aggregate([
	  { $unwind: "$items" },
	  { $group: { _id: "$_id", itemCount: { $sum: 1 } } },
	  { $group: { _id: null, averageItemsPerOrder: { $avg: "$itemCount" } } },
	  { $project: { _id: 0, averageItemsPerOrder: 1 } }
	]);
	
//4.3. Join Customer and Order Data Using $lookup:

	db.orders.aggregate([
	  { $lookup: { from: "customers", localField: "customer_id", foreignField: "_id", as: "customer_info" } },
	  { $unwind: "$customer_info" },
	  { $project: { "customer_info.name": 1, "customer_info.email": 1, "order_id": 1, "total_value": 1, "order_date": 1 } }
	]);




