import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_theme.dart';
import '../../models/food_item.dart';
import '../../repositories/food_repository.dart';
import '../../widgets/custom_app_bar.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({Key? key}) : super(key: key);

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<FoodItem> _searchResults = [];
  List<FoodItem> _favoriteItems = [];
  List<FoodItem> _recentItems = [];

  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final foodRepository = context.read<FoodRepository>();
      final favorites = await foodRepository.getFavoriteFoods();
      final recentItems = await foodRepository.getRecentFoods();

      setState(() {
        _favoriteItems = favorites;
        _recentItems = recentItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu thực phẩm: $e')),
      );
    }
  }

  Future<void> _searchFood(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final foodRepository = context.read<FoodRepository>();
      final results = await foodRepository.searchFood(query);

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tìm kiếm thực phẩm: $e')),
      );
    }
  }

  void _toggleFavorite(FoodItem foodItem) async {
    try {
      final foodRepository = context.read<FoodRepository>();

      if (foodItem.id != null) {
        await foodRepository.toggleFavorite(foodItem.id!);
        // Refresh favorites
        final favorites = await foodRepository.getFavoriteFoods();
        setState(() {
          _favoriteItems = favorites;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật yêu thích: $e')),
      );
    }
  }

  void _selectFood(FoodItem foodItem) {
    Navigator.pop(context, foodItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Tìm kiếm thực phẩm',
        showBackButton: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm thực phẩm...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchFood('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _searchFood,
                ),
              ),

              // Tab bar
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.secondaryTextColor,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'Tìm kiếm'),
                  Tab(text: 'Yêu thích'),
                  Tab(text: 'Gần đây'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Search Results Tab
          _buildSearchResultsTab(),

          // Favorites Tab
          _buildFavoritesTab(),

          // Recent Tab
          _buildRecentTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCustomFoodDialog();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchResultsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              size: 64,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Tìm kiếm món ăn',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập vào ô tìm kiếm để tìm món ăn',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.no_food,
              size: 64,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thử từ khóa khác hoặc thêm món mới',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildFoodItemCard(_searchResults[index]);
      },
    );
  }

  Widget _buildFavoritesTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_favoriteItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 64,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có món ăn yêu thích',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thêm món ăn vào yêu thích để truy cập nhanh',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _favoriteItems.length,
      itemBuilder: (context, index) {
        return _buildFoodItemCard(_favoriteItems[index]);
      },
    );
  }

  Widget _buildRecentTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_recentItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 64,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có món ăn gần đây',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Các món ăn bạn nhập sẽ xuất hiện ở đây',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _recentItems.length,
      itemBuilder: (context, index) {
        return _buildFoodItemCard(_recentItems[index]);
      },
    );
  }

  Widget _buildFoodItemCard(FoodItem foodItem) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _selectFood(foodItem),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Food icon
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 16),

              // Food details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItem.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (foodItem.brand != null)
                      Text(
                        foodItem.brand!,
                        style: const TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${foodItem.caloriesPer100g.toStringAsFixed(0)} kcal | P: ${foodItem.proteinPer100g.toStringAsFixed(1)}g | C: ${foodItem.carbsPer100g.toStringAsFixed(1)}g | F: ${foodItem.fatPer100g.toStringAsFixed(1)}g',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Favorite button
              IconButton(
                icon: Icon(
                  foodItem.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: foodItem.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () => _toggleFavorite(foodItem),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCustomFoodDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    final TextEditingController proteinController = TextEditingController();
    final TextEditingController carbsController = TextEditingController();
    final TextEditingController fatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm món ăn mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên món ăn*',
                ),
              ),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calo (100g)*',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: proteinController,
                decoration: const InputDecoration(
                  labelText: 'Protein (g per 100g)*',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carbsController,
                decoration: const InputDecoration(
                  labelText: 'Carbs (g per 100g)*',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fatController,
                decoration: const InputDecoration(
                  labelText: 'Chất béo (g per 100g)*',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate inputs
              if (nameController.text.isEmpty ||
                  caloriesController.text.isEmpty ||
                  proteinController.text.isEmpty ||
                  carbsController.text.isEmpty ||
                  fatController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                );
                return;
              }

              try {
                final double calories = double.parse(caloriesController.text);
                final double protein = double.parse(proteinController.text);
                final double carbs = double.parse(carbsController.text);
                final double fat = double.parse(fatController.text);

                // Create food item
                final foodItem = FoodItem(
                  name: nameController.text,
                  caloriesPer100g: calories,
                  proteinPer100g: protein,
                  carbsPer100g: carbs,
                  fatPer100g: fat,
                );

                // Add to database
                final foodRepository = context.read<FoodRepository>();
                final id = await foodRepository.addFoodItem(foodItem);

                // Return the food item with ID
                Navigator.pop(context);
                _selectFood(foodItem.copyWith(id: id));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi thêm món ăn: $e')),
                );
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}