Sure, here's a README for your Spencer Expense Tracker app:

---

# Spencer Expense Tracker

Spencer Expense Tracker is a simple software solution designed to help users track their expenses. It consists of two main components: a Flutter-based frontend for the user interface and a FastAPI backend for handling data storage and retrieval.

## Getting Started

To run the Spencer Expense Tracker app, you'll need to set up both the frontend and backend components.

### Frontend Setup (Flutter)

1. Navigate to the `spencer_frontend` directory.
   ```
   cd spencer_frontend
   ```

2. Ensure you have Flutter installed. If not, follow the instructions at [Flutter.dev](https://flutter.dev/docs/get-started/install) to install it.

3. Install dependencies using Flutter's package manager, `pub`.
   ```
   flutter pub get
   ```

4. Connect your device or start a simulator(preferebly chrome).
   ```
   flutter devices
   flutter emulators --launch <emulator_id>
   ```

5. Run the application.
   ```
   flutter run <device>
   ```

### Backend Setup (FastAPI)

1. Navigate to the `spencer_backend` directory.
   ```
   cd spencer_backend
   ```

2. Make sure you have Python installed. If not, download and install it from [python.org](https://www.python.org/downloads/).

3. Create a virtual environment (optional but recommended).
   ```
   python -m venv venv
   ```

4. Activate the virtual environment.
   - **Windows:**
     ```
     venv\Scripts\activate
     ```
   - **Unix/Linux:**
     ```
     source venv/bin/activate
     ```

5. Install dependencies using pip.
   ```
   pip install -r requirements.txt
   ```

6. Run the FastAPI server.
   ```
   uvicorn main:app --reload
   ```

## Usage

Once both the frontend and backend are running:

1. Open the Spencer Expense Tracker app on your device or simulator.
2. Use the app interface to add, view, edit, and delete expenses.
3. The changes made in the app will be reflected in the backend server.
4. Access the data via API endpoints provided by the FastAPI backend.

## Contributing

Contributions to Spencer Expense Tracker are welcome! Feel free to submit bug reports, feature requests, or pull requests to help improve the app.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



## Data Structures Used

In this project I used ArrayList, Maps/Dictionary and Sets in both frontend and backend.
For example if you navigate to spencer-backend/routes/expenses.py, you will see all three data structures implemented

If you also navigate to spencer_frontend/lib/screens/budget_page.dart youll see that i implemented a Stack to retreive data