# Stock Price Prediction — Frontend

Flutter Web app that visualizes stock prices, moving averages, and LSTM model predictions.  
It fetches data from the [stock-price-prediction-backend](../stock_price_prediction_backend) which runs on Render.

## Project Structure

```
stock_price_prediction_frontend/
├── lib/
│   ├── main.dart
│   ├── controllers/        # GetX state management
│   ├── models/             # StockData model
│   ├── screens/            # Dashboard UI
│   ├── services/           # ApiService (HTTP calls to backend)
│   ├── theme/              # App theme
│   └── widgets/            # Chart & table widgets
├── web/                    # Flutter web shell
├── android/                # Android build config
├── pubspec.yaml
├── vercel.json             # Vercel SPA routing config
└── .github/workflows/
    └── deploy.yml          # Build → Deploy to Vercel on push to main
```

## Local Development

### 1. Start the backend first

```bash
# In the stock_price_prediction_backend directory:
uvicorn api.predict:app --reload
# API will be at http://127.0.0.1:8000
```

### 2. Run the Flutter app

```bash
flutter pub get
flutter run -d chrome
```

The app auto-detects `localhost` and routes API calls to `http://127.0.0.1:8000`.

## Configuration

Edit `lib/services/api_service.dart` and update `_productionBackendUrl` with your Render URL:

```dart
static const String _productionBackendUrl =
    "https://YOUR-APP-NAME.onrender.com"; // ← paste your Render URL here
```

## Deploy Frontend to Vercel

### Option A — GitHub Actions (Automated)

1. Push this folder to a **new GitHub repository**
2. In Vercel: **New Project** → import the repo → set **Output Directory** to `build/web`
3. Add these GitHub secrets (from Vercel dashboard):
   - `VERCEL_TOKEN`
   - `VERCEL_ORG_ID`
   - `VERCEL_PROJECT_ID`
4. Push to `main` — the workflow auto-builds and deploys

### Option B — Vercel CLI (Manual)

```bash
flutter build web --release
cd build/web
npx vercel --prod
```
