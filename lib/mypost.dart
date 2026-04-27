import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/market_data.dart';
import 'package:grainapp/post_widgets.dart';
import 'package:grainapp/posts.dart';
import 'package:grainapp/signupFirebase.dart';

class MyPost extends StatefulWidget {
  const MyPost({super.key});

  @override
  State<MyPost> createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _explainController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _customProductController = TextEditingController();

  String _postType = 'sell';
  String? _selectedProduct;
  String? _selectedRegion;
  String? _selectedDistrict;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _phoneController.dispose();
    _explainController.dispose();
    _streetController.dispose();
    _customProductController.dispose();
    super.dispose();
  }

  Stream<List<String>> _productStream() {
    return FirebaseFirestore.instance.collection('product').snapshots().map((snapshot) {
      final products = <String>{};
      for (final doc in snapshot.docs) {
        for (final value in doc.data().values) {
          final item = value.toString().trim();
          if (item.isNotEmpty) {
            products.add(item);
          }
        }
      }
      final list = products.toList()..sort();
      return list;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedProduct = _selectedProduct == 'Other'
        ? _customProductController.text.trim()
        : _selectedProduct?.trim();

    if (selectedProduct == null || selectedProduct.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose or enter a product first.')),
      );
      return;
    }

    if (_selectedRegion == null || _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose your region and district.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await userPost(
      street: _streetController.text.trim(),
      quantity: _quantityController.text.trim(),
      phone: _phoneController.text.trim(),
      explanation: _explainController.text.trim(),
      productName: selectedProduct,
      region: _selectedRegion!,
      districtName: _selectedDistrict!,
      postType: _postType,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (result == 0) {
      _formKey.currentState?.reset();
      _quantityController.clear();
      _phoneController.clear();
      _explainController.clear();
      _streetController.clear();
      _customProductController.clear();
      setState(() {
        _selectedProduct = null;
        _selectedRegion = null;
        _selectedDistrict = null;
        _postType = 'sell';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _postType == 'buy'
                ? 'Buy request posted successfully.'
                : 'Sell post published successfully.',
          ),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ProductCard()),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to save the post. Try again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final districts = _selectedRegion == null ? const <String>[] : districtsForRegion(_selectedRegion!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: MarketBackground(
        child: SafeArea(
          child: StreamBuilder<List<String>>(
            stream: _productStream(),
            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              final productItems = <String>[...snapshot.data ?? const <String>[]];
              if (!productItems.contains('Other')) {
                productItems.add('Other');
              }

              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final fieldWidth = isWide ? (constraints.maxWidth - 52) / 2 : constraints.maxWidth;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 500),
                          tween: Tween<double>(begin: 0.96, end: 1),
                          builder: (BuildContext context, double value, Widget? child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(opacity: value.clamp(0, 1), child: child),
                            );
                          },
                          child: MarketPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SectionHeader(
                                  icon: Icons.add_business_rounded,
                                  title: 'Quick listing',
                                  subtitle: 'Post a buy request or a sell offer without images.',
                                ),
                                const SizedBox(height: 18),
                                SegmentedButton<String>(
                                  style: SegmentedButton.styleFrom(
                                    backgroundColor: AppColors.panelSoft,
                                    foregroundColor: Colors.white,
                                    selectedBackgroundColor: AppColors.accent.withOpacity(0.2),
                                    selectedForegroundColor: Colors.white,
                                  ),
                                  segments: const <ButtonSegment<String>>[
                                    ButtonSegment<String>(
                                      value: 'sell',
                                      icon: Icon(Icons.sell_outlined),
                                      label: Text('Sell'),
                                    ),
                                    ButtonSegment<String>(
                                      value: 'buy',
                                      icon: Icon(Icons.shopping_bag_outlined),
                                      label: Text('Buy'),
                                    ),
                                  ],
                                  selected: <String>{_postType},
                                  onSelectionChanged: (Set<String> values) {
                                    setState(() {
                                      _postType = values.first;
                                    });
                                  },
                                ),
                                const SizedBox(height: 22),
                                Form(
                                  key: _formKey,
                                  child: Wrap(
                                    spacing: 20,
                                    runSpacing: 20,
                                    children: <Widget>[
                                      SizedBox(
                                        width: fieldWidth,
                                        child: DropdownButtonFormField<String>(
                                          value: productItems.contains(_selectedProduct) ? _selectedProduct : null,
                                          dropdownColor: AppColors.panel,
                                          items: productItems
                                              .map(
                                                (String product) => DropdownMenuItem<String>(
                                                  value: product,
                                                  child: Text(product),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              _selectedProduct = value;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'Product',
                                            prefixIcon: Icon(Icons.grass_rounded),
                                          ),
                                          validator: (_) {
                                            if (_selectedProduct == null) {
                                              return 'Choose a product.';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      if (_selectedProduct == 'Other')
                                        SizedBox(
                                          width: fieldWidth,
                                          child: TextFormField(
                                            controller: _customProductController,
                                            decoration: const InputDecoration(
                                              labelText: 'Custom product',
                                              prefixIcon: Icon(Icons.edit_rounded),
                                            ),
                                            validator: (String? value) {
                                              if (_selectedProduct == 'Other' &&
                                                  (value == null || value.trim().isEmpty)) {
                                                return 'Enter the product name.';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: TextFormField(
                                          controller: _quantityController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Quantity (kg)',
                                            prefixIcon: Icon(Icons.scale_outlined),
                                          ),
                                          validator: (String? value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Enter quantity.';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: TextFormField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          decoration: const InputDecoration(
                                            labelText: 'Phone / WhatsApp',
                                            prefixIcon: Icon(Icons.call_rounded),
                                          ),
                                          validator: (String? value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Enter a phone number.';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedRegion,
                                          dropdownColor: AppColors.panel,
                                          items: marketRegions
                                              .map(
                                                (String region) => DropdownMenuItem<String>(
                                                  value: region,
                                                  child: Text(region),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              _selectedRegion = value;
                                              _selectedDistrict = null;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'Region',
                                            prefixIcon: Icon(Icons.public_rounded),
                                          ),
                                          validator: (String? value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Choose a region.';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: DropdownButtonFormField<String>(
                                          value: districts.contains(_selectedDistrict) ? _selectedDistrict : null,
                                          dropdownColor: AppColors.panel,
                                          items: districts
                                              .map(
                                                (String district) => DropdownMenuItem<String>(
                                                  value: district,
                                                  child: Text(district),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              _selectedDistrict = value;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'District',
                                            prefixIcon: Icon(Icons.location_city_rounded),
                                          ),
                                          validator: (String? value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Choose a district.';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: TextFormField(
                                          controller: _streetController,
                                          decoration: const InputDecoration(
                                            labelText: 'Street / Mtaa',
                                            prefixIcon: Icon(Icons.home_work_outlined),
                                          ),
                                          validator: (String? value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Enter your street.';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: constraints.maxWidth,
                                        child: TextFormField(
                                          controller: _explainController,
                                          maxLines: 5,
                                          decoration: const InputDecoration(
                                            labelText: 'Description',
                                            alignLabelWithHint: true,
                                            prefixIcon: Icon(Icons.notes_rounded),
                                          ),
                                          validator: (String? value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Add a short description.';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: <Widget>[
                                    FilledButton.icon(
                                      onPressed: _isSubmitting ? null : _submit,
                                      icon: _isSubmitting
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.rocket_launch_outlined),
                                      label: Text(_isSubmitting ? 'Posting...' : 'Publish'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: _isSubmitting
                                          ? null
                                          : () {
                                              Navigator.of(context).pop();
                                            },
                                      icon: const Icon(Icons.arrow_back_rounded),
                                      label: const Text('Back'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
