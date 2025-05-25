class ApiEndpoints {
  static const String baseUrl = "https://localhost:44320/api";

  // Crop
  static const String getCrops = "$baseUrl/Crop";
  static const String postCrop = "$baseUrl/Crop";
  static String deleteCrop(String cropId) => "$baseUrl/Crop/$cropId";
  static String updateCrop(String cropId) => "$baseUrl/Crop/$cropId";

  // Crop Disease
  static const String getCropDiseases = "$baseUrl/CropDisease";
  static const String postCropDisease = "$baseUrl/CropDisease";
  static String deleteCropDisease(String cdid) => "$baseUrl/CropDisease/$cdid";
  static String updateCropDisease(String cdid) => "$baseUrl/CropDisease/$cdid";

  // Crop Shop
  static const String getCropShops = "$baseUrl/CropShop";
  static const String postCropShop = "$baseUrl/CropShop";
  static String getCropShopById(String id) => "$baseUrl/CropShop/$id";
  static String updateCropShop(String id) => "$baseUrl/CropShop/$id";
  static String deleteCropShop(String id) => "$baseUrl/CropShop/$id";

  // Disease
  static const String getDiseases = "$baseUrl/Disease";
  static const String postDisease = "$baseUrl/Disease";
  static String getDiseaseById(String id) => "$baseUrl/Disease/$id";
  static String updateDisease(String id) => "$baseUrl/Disease/$id";
  static String deleteDisease(String id) => "$baseUrl/Disease/$id";

  // Farmer
  static const String getFarmers = "$baseUrl/Farmer/full";
  static const String postFarmer = "$baseUrl/Farmer";
  static String getFarmer(String Email) => "$baseUrl/Farmer/$Email";
  static String deleteFarmer(String farmerID) => "$baseUrl/Farmer/$farmerID";
  static String updateFarmer(String farmerID) => "$baseUrl/Farmer/$farmerID";

  // Fertilizer
  static const String getFertilizers = "$baseUrl/Fertilizer";
  static const String postFertilizer = "$baseUrl/Fertilizer";
  static String deleteFertilizer(String fertilizerID) =>
      "$baseUrl/Fertilizer/$fertilizerID";
  static String updateFertilizer(String fertilizerID) =>
      "$baseUrl/Fertilizer/$fertilizerID";

  // Growing Crop
  static const String getGrowingCrops = "$baseUrl/GrowingCrop";
  static const String postGrowingCrop = "$baseUrl/GrowingCrop";
  static String getGrowingCropById(int farmerID) => "$baseUrl/GrowingCrop/$farmerID";
  static String updateGrowingCrop(String id) => "$baseUrl/GrowingCrop/$id";
  static String deleteGrowingCrop(String id) => "$baseUrl/GrowingCrop/$id";

  // Inspector
  static const String getInspectors = "$baseUrl/Inspector";
  static const String postInspector = "$baseUrl/Inspector";
  static String getInspectorById(String id) => "$baseUrl/Inspector/$id";
  static String updateInspector(String id) => "$baseUrl/Inspector/$id";
  static String deleteInspector(String id) => "$baseUrl/Inspector/$id";

  // Item
  static const String getItems = "$baseUrl/Item";
  static const String postItem = "$baseUrl/Item";
  static String getItemById(String id) => "$baseUrl/Item/$id";
  static String updateItem(String id) => "$baseUrl/Item/$id";
  static String deleteItem(String id) => "$baseUrl/Item/$id";

  // Market Data
  static const String getMarketData = "$baseUrl/MarketData";
  static const String postMarketData = "$baseUrl/MarketData";
  static String getMarketDataById(String id) => "$baseUrl/MarketData/$id";
  static String updateMarketData(String id) => "$baseUrl/MarketData/$id";
  static String deleteMarketData(String id) => "$baseUrl/MarketData/$id";

  // Pesticide
  static const String getPesticides = "$baseUrl/Pesticide";
  static const String postPesticide = "$baseUrl/Pesticide";
  static String getPesticideById(String id) => "$baseUrl/Pesticide/$id";
  static String updatePesticide(String id) => "$baseUrl/Pesticide/$id";
  static String deletePesticide(String id) => "$baseUrl/Pesticide/$id";

  // Request
  static const String getRequests = "$baseUrl/Request";
  static const String postRequest = "$baseUrl/Request";
  static String getRequestById(String id) => "$baseUrl/Request/$id";
  static String updateRequest(String id) => "$baseUrl/Request/$id";
  static String deleteRequest(String id) => "$baseUrl/Request/$id";

  // Shop
  static const String getShops = "$baseUrl/Shop";
  static String getShopById(String id) => "$baseUrl/Shop/$id";
  static String updateShop(String id) => "$baseUrl/Shop/$id";
  static String deleteShop(String id) => "$baseUrl/Shop/$id";

  // User
  static const String registerUser = "$baseUrl/User/Register";
  static const String loginUser = "$baseUrl/User/Login";
}
