const express = require('express');
const fs = require('fs');

const app = express();
const PORT = 3001;

let menuItems = []; // Array to store menu items

// Middleware to parse JSON
app.use(express.json());

app.post('/menu', (req, res) => {
  const newItem = req.body;

  // Read the existing data from the file
  fs.readFile('dishes.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).send('Error reading data');
    }

    // Parse the existing data
    const parsedData = JSON.parse(data);
    const menu = parsedData.menu;

    // Add the new item to the menu
    menu.push(newItem);

    // Write the updated data back to the file
    fs.writeFile('dishes.json', JSON.stringify(parsedData, null, 2), (writeErr) => {
      if (writeErr) {
        return res.status(500).send('Error saving data');
      }

      res.status(201).send('Menu item added');
    });
  });
});


// Endpoint to get all menu items
app.get('/menu', (req, res) => {
  fs.readFile('dishes.json', 'utf8', (err, data) => {
    if (err) {
      res.status(500).send('Error reading data');
    } else {
      const menu = JSON.parse(data).menu;
      res.json(menu);
    }
  });
});



// Endpoint to get a menu item by dish name
app.get('/menu/:dish_name', (req, res) => {
  const dishName = req.params.dish_name;

   fs.readFile('dishes.json', 'utf8', (err, data) => {
    console.log(err, data)
//     if (err) {
//       res.status(500).send('Error reading data');
//     }else {
      const menu = JSON.parse(data).menu;
      const dish = menu.find(d => d.dish_name.toLowerCase() === dishName.toLowerCase());
      if (dish) {
        res.json(dish);
      } else {
        res.status(404).send('Dish not found');
      }
    // }
  });
});




app.put('/menu/:dish_name', (req, res) => {
  const dishName = req.params.dish_name;
  const updatedData = req.body; // New data to update the item

  // Read the existing data from the file
  fs.readFile('dishes.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).send('Error reading data');
    }

    // Parse the existing data
    const parsedData = JSON.parse(data);
    let menu = parsedData.menu;

    // Find the menu item to update
    const index = menu.findIndex(d => d.dish_name.toLowerCase() === dishName.toLowerCase());

    if (index !== -1) {
      // Update the dish with the new data
      menu[index] = { ...menu[index], ...updatedData };

      // Write the updated data back to the file
      fs.writeFile('dishes.json', JSON.stringify(parsedData, null, 2), (writeErr) => {
        if (writeErr) {
          return res.status(500).send('Error saving updated data');
        }

        res.status(200).send('Menu item updated');
      });
    } else {
      res.status(404).send('Dish not found');
    }
  });
});




// Method for ordering the quantity of the dish 
app.post('/order', (req, res) => {
  const { dish_name, quantity } = req.body;

  // Check for missing fields in the request body
  if (!dish_name || quantity === undefined) {
    return res.status(400).send('Dish name and quantity are required');
  }

  // Read the existing data from the file
  fs.readFile('dishes.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).send('Error reading data');
    }

    // Parse the existing data
    const parsedData = JSON.parse(data);
    let menu = parsedData.menu;

    // Find the dish by name
    const dishIndex = menu.findIndex(
      (d) => d.dish_name.toLowerCase() === dish_name.toLowerCase()
    );

    if (dishIndex === -1) {
      // If dish is not found
      return res.status(404).send('Dish not found');
    }

    const dish = menu[dishIndex];

    // Check if enough quantity is available
    if (dish.quantity_available < quantity) {
      return res.status(400).send(`Not enough quantity available. Only ${dish.quantity_available} left.`);
    }

    // Deduct the ordered quantity
    dish.quantity_available -= quantity;

    // Write the updated data back to the file
    fs.writeFile('dishes.json', JSON.stringify(parsedData, null, 2), (writeErr) => {
      if (writeErr) {
        return res.status(500).send('Error saving updated data');
      }

      res.status(200).send(`Order placed successfully. ${dish.quantity_available} ${dish_name}(s) remaining.`);
    });
  });
});


// DELETE endpoint to remove a menu item by dish name
app.delete('/menu/:dish_name', (req, res) => {
  const dishName = req.params.dish_name;

  // Read the existing data from the file
  fs.readFile('dishes.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).send('Error reading data');
    }

    // Parse the existing data
    const parsedData = JSON.parse(data);
    let menu = parsedData.menu;

    // Find the menu item to delete
    const index = menu.findIndex(d => d.dish_name.toLowerCase() === dishName.toLowerCase());

    if (index !== -1) {
      // Remove the item from the menu
      menu.splice(index, 1);

      // Write the updated data back to the file
      fs.writeFile('dishes.json', JSON.stringify(parsedData, null, 2), (writeErr) => {
        if (writeErr) {
          return res.status(500).send('Error saving updated data');
        }

        res.status(200).send('Menu item deleted');
      });
    } else {
      res.status(404).send('Dish not found');
    }
  });
});




// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
