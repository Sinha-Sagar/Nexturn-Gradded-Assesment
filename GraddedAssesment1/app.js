const fs = require('fs');
const filePath = 'data.json'

// Task-1: Parsing JSON
function readData(filePath){
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            console.log(err);
        } else {
            const jsonData = JSON.parse(data);
            console.log("The data is: \n", jsonData);
        }
    });
}

// Task-2: Adding new Products
function addProduct(filePath, Product){
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            console.log(err);
            return;
        } else {
            const jsonData = JSON.parse(data);
            jsonData.push(Product);

            const Data = JSON.stringify(jsonData);

            fs.writeFile(filePath, Data, (err) => {
                if (err) {
                    console.log(err);
                } else {
                    console.log('Data written to file');
                }
            });
        }
    });
}

// Task-3: Update the price of a product:
function updateProduct(filePath, ProductId, newPrice){
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            console.log(err);
            return;
        } else {
            const jsonData = JSON.parse(data);
            const product = jsonData.find(p => p.id === ProductId);
            if (product) {
                product.price = newPrice;
                const Data = JSON.stringify(jsonData);

                fs.writeFile(filePath, Data, (err) => {
                    if (err) {
                        console.log(err);
                    } else {
                        console.log('Product price updated successfully. Updated product: ', product);
                    }
                });
            } else {
                console.log("Product not found.");
            }
        }
    });
}

// Task-4: Filter products based on availability:
function filterProductOnAvailability(filePath){
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            console.log(err);
            return;
        } else {
            const jsonData = JSON.parse(data);
            const availableProducts = jsonData.filter(p => p.available === true);
            console.log("Available products:", availableProducts);
            return availableProducts;
        }
    });
}

// Task-5: Filter products by category
function filterProductOnCategory(filePath, category){
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            console.log(err);
            return;
        } else {
            const jsonData = JSON.parse(data);
            const categories = jsonData.filter(p => p.category === category);
            console.log("Products of the category, ", category, "are : ", categories);
            return categories;
        }
    });
}

readData(filePath);
// addProduct(filePath, {"id":6,"name":"Formals","category":"Fashion","price":3000,"available":true});
// updateProduct(filePath, 5, 1700);
// filterProductOnAvailability(filePath);
// filterProductOnCategory(filePath, "Fashion");