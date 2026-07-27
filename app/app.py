from flask import Flask, jsonify, request

app = Flask(__name__)
notes = []

@app.route("/")
def home():
    return jsonify({"status": "ok", "message": "Notes API running"})

@app.route("/notes", methods=["GET"])
def get_notes():
    return jsonify(notes)

@app.route("/notes", methods=["POST"])
def add_note():
    data = request.get_json()
    note = {"id": len(notes) + 1, "text": data.get("text", "")}
    notes.append(note)
    return jsonify(note), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
