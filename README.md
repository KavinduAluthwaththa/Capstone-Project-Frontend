# Smart Agriculture Platform - Frontend

A comprehensive Flutter-based mobile application that connects farmers with agricultural shops and provides AI-powered farming assistance. This platform serves as a bridge between farmers and shop owners while offering intelligent agricultural solutions.

## 🌾 Features

### For Farmers
- **Crop Disease Identification**: AI-powered plant disease detection using image analysis
- **Crop Recommendation System**: Get personalized crop suggestions based on soil conditions, weather, and location
- **Fertilizer Calculator**: Calculate optimal fertilizer requirements for different crops
- **Crop Management**: Track and manage growing crops
- **Shop Discovery**: Find nearby agricultural shops and browse their inventory
- **Order Management**: Place and track orders for agricultural supplies
- **Weather Integration**: Real-time weather data for informed farming decisions
- **AI Chatbot**: Get instant answers to agricultural questions

### For Shop Owners
- **Farmer Network**: Connect with local farmers and manage customer relationships
- **Order Management**: Receive, process, and track customer orders
- **Inventory Management**: Manage shop inventory and product listings
- **Analytics Dashboard**: Monitor business performance and customer interactions
- **Profile Management**: Maintain detailed shop information and contact details

### Shared Features
- **Authentication System**: Secure login and registration for both user types
- **Dark/Light Theme**: Customizable UI themes for better user experience
- **Profile Management**: Comprehensive user profile management
- **Real-time Chat**: Communication between farmers and shop owners
- **Weather Dashboard**: Current weather conditions and forecasts

## 🛠️ Technology Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **AI Integration**: Google Generative AI (Gemini)
- **Image Processing**: Image Picker for crop disease analysis
- **HTTP Client**: HTTP package for API communication
- **Local Storage**: SharedPreferences
- **UI Components**: 
  - Google Fonts for typography
  - Lottie animations
  - Pie charts for data visualization
  - Custom Material Design components

## 📱 Screenshots & Demo

The app features a modern, intuitive interface with:
- Splash screen with brand identity
- Role-based navigation (Farmer/Shop Owner)
- Weather-integrated dashboards
- AI-powered crop analysis interface
- Order management systems
- Chat interfaces

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.7.0)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/KavinduAluthwaththa/Capstone-Project-Frontend.git
   cd Capstone-Project-Frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   Create a `.env` file in the root directory with the following variables:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   API_BASE_URL=your_backend_api_url
   WEATHER_API_KEY=your_weather_api_key
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**Web:**
```bash
flutter build web
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── accounts/                 # Authentication screens
│   ├── login.dart
│   └── register.dart
├── farmer_area/              # Farmer-specific features
│   ├── FarmerMainPage.dart
│   ├── CropSuggest.dart
│   ├── AddGrowingCrop.dart
│   ├── MyCrops.dart
│   ├── MyOrders.dart
│   ├── ShopList.dart
│   └── ShopProfile.dart
├── shop_owner_area/          # Shop owner features
│   ├── ShopMainPage.dart
│   ├── FarmersList.dart
│   ├── FarmerProfile.dart
│   ├── AddOrders.dart
│   └── MyOrders.dart
├── shared/                   # Shared components
│   ├── Splash.dart
│   ├── Chatbot.dart
│   ├── DiseaseIdentification.dart
│   ├── FertilizerCalculation.dart
│   ├── ProfilePage.dart
│   ├── Chat.dart
│   └── settings.dart
├── models/                   # Data models
├── services/                 # App services
└── constraints/              # API endpoints & constants
```

## 🔧 Configuration

### API Integration
The app integrates with a backend API for:
- User authentication
- Crop data management
- Disease identification
- Order processing
- Weather data

Update the API endpoints in `lib/constraints/api_endpoint.dart`

### AI Features Configuration
- **Disease Identification**: Uses machine learning models for plant disease detection
- **Crop Recommendation**: Analyzes soil and weather data for optimal crop suggestions
- **Chatbot**: Powered by Google Generative AI (Gemini) for agricultural assistance

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📋 Development Guidelines

- Follow Flutter best practices and conventions
- Use meaningful commit messages
- Ensure proper error handling
- Add comments for complex logic
- Test thoroughly before submitting PR

## 🔮 Future Enhancements

- [ ] Offline mode support
- [ ] Push notifications
- [ ] Advanced analytics
- [ ] Multi-language support
- [ ] IoT sensor integration
- [ ] Marketplace expansion

## 📄 License

This project is part of a capstone project. Please contact the repository owner for licensing information.

## 👥 Team

Developed as part of a capstone project by:
- **Frontend Lead**: KavinduAluthwaththa

## 📞 Support

For support, email [kavindu18602@gmail.com] or create an issue in this repository.

---

**Note**: This application requires a backend API to be fully functional. Make sure to access the corresponding backend services at [https://github.com/KavinduAluthwaththa/Capstone-Project-Backend] and update the API endpoints accordingly.
