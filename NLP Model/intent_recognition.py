import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import MultinomialNB
from sklearn.metrics import classification_report
import joblib
from flask import Flask, request, jsonify
from werkzeug.serving import run_simple

from flask_cors import CORS

#CORS(app)  # Enable CORS for all routes


# Step 1: Prepare and Train the Model
# Updated dataset (balanced)
data = [
    # Check Availability Intent
    {"text": "Can you check if bananas are available?", "intent": "check_availability"},
    {"text": "Are there bananas in stock?", "intent": "check_availability"},
    {"text": "Do you have bananas right now?", "intent": "check_availability"},
    {"text": "Check for bananas, please.", "intent": "check_availability"},
    {"text": "Look up bananas and let me know if they're available.", "intent": "check_availability"},
    {"text": "Is milk available in the store?", "intent": "check_availability"},
    {"text": "Can you see if there’s any bread left?", "intent": "check_availability"},
    {"text": "Are apples in stock?", "intent": "check_availability"},
    {"text": "Do you have eggs in the inventory?", "intent": "check_availability"},
    {"text": "Look for oranges in the store.", "intent": "check_availability"},

    # Place Order Intent
    {"text": "Can you order bananas for me?", "intent": "place_order"},
    {"text": "I’d like to order some bananas.", "intent": "place_order"},
    {"text": "Place an order for bananas.", "intent": "place_order"},
    {"text": "Please get me some bananas.", "intent": "place_order"},
    {"text": "Can you buy bananas if they're available?", "intent": "place_order"},
    {"text": "Order a pack of milk for me.", "intent": "place_order"},
    {"text": "I need to buy some apples.", "intent": "place_order"},
    {"text": "Please place an order for bread.", "intent": "place_order"},
    {"text": "Add eggs to my cart and order them.", "intent": "place_order"},
    {"text": "Can you order some oranges?", "intent": "place_order"},

    # Ask Price Intent
    {"text": "How much do bananas cost?", "intent": "ask_price"},
    {"text": "What’s the price of a pack of bananas?", "intent": "ask_price"},
    {"text": "Can you tell me the price of bananas?", "intent": "ask_price"},
    {"text": "Check the price of bananas for me.", "intent": "ask_price"},
    {"text": "What's the cost of a bunch of bananas?", "intent": "ask_price"},
    {"text": "How much are apples?", "intent": "ask_price"},
    {"text": "What's the cost of eggs?", "intent": "ask_price"},
    {"text": "Check the price of milk.", "intent": "ask_price"},
    {"text": "What’s the price for a loaf of bread?", "intent": "ask_price"},
    {"text": "Can you find out the price of oranges?", "intent": "ask_price"},

    # Cancel Order Intent
    {"text": "Cancel my order for bananas.", "intent": "cancel_order"},
    {"text": "I’d like to cancel my banana order.", "intent": "cancel_order"},
    {"text": "Can you stop the banana purchase?", "intent": "cancel_order"},
    {"text": "Don’t order bananas anymore.", "intent": "cancel_order"},
    {"text": "Cancel the banana order if it’s not too late.", "intent": "cancel_order"},
    {"text": "Please cancel my milk order.", "intent": "cancel_order"},
    {"text": "I need to stop my bread order.", "intent": "cancel_order"},
    {"text": "Cancel the purchase of apples.", "intent": "cancel_order"},
    {"text": "Can you remove eggs from my cart?", "intent": "cancel_order"},
    {"text": "Don’t go ahead with the orange order.", "intent": "cancel_order"}
]

# Convert dataset into a DataFrame
df = pd.DataFrame(data)

# Preprocessing: Features and Labels
X = df['text']  # Input
y = df['intent']  # Labels

# Use TfidfVectorizer
vectorizer = TfidfVectorizer()
X_vectors = vectorizer.fit_transform(X)

# Train/Test Split
X_train, X_test, y_train, y_test = train_test_split(X_vectors, y, test_size=0.2, random_state=42)

# Train the Multinomial Naive Bayes Model
model = MultinomialNB(alpha=0.5)
model.fit(X_train, y_train)

# Evaluate the model
y_pred = model.predict(X_test)
print("Classification Report:")
print(classification_report(y_test, y_pred, zero_division=0))

# Save the model and vectorizer
joblib.dump(model, "ml_model.pkl")
joblib.dump(vectorizer, "vectorizer.pkl")
print("Model and vectorizer saved successfully.")

# Flask API to serve predictions
app = Flask(__name__)

@app.route("/predict", methods=["POST"])
def predict():
    # Parse the JSON request
    data = request.get_json()
    if not data or "text" not in data:
        return jsonify({"error": "Invalid request. 'text' field is required."}), 400

    # Input text
    input_text = data["text"]

    # Transform input text using the vectorizer
    input_vector = vectorizer.transform([input_text])

    # Predict the intent
    prediction = model.predict(input_vector)

    # Return the prediction
    return jsonify({"intent": prediction[0]}), 200

if __name__ == "__main__":
    run_simple("0.0.0.0", 6001, app, use_debugger=True, use_reloader=False)
