import 'package:flutter/material.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/app_support.dart';
import 'package:grainapp/market_data.dart';
import 'package:grainapp/market_post.dart';
import 'package:grainapp/post_widgets.dart';
import 'package:grainapp/posts.dart';
import 'package:grainapp/product_catalog.dart';
import 'package:grainapp/signup_firebase.dart';

class MyPost extends StatefulWidget {
  const MyPost({super.key, this.existingPost});

  final MarketPost? existingPost;

  @override
  State<MyPost> createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  static const String _otherProductLabel = 'Other';

  final ProductCatalogService _productCatalogService = ProductCatalogService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _explainController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _customProductController =
      TextEditingController();

  String _postType = 'sell';
  String? _selectedProduct;
  String? _selectedRegion;
  String? _selectedDistrict;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingPost != null;

  @override
  void initState() {
    super.initState();
    final existingPost = widget.existingPost;
    if (existingPost == null) {
      return;
    }

    _postType = existingPost.postType;
    _selectedProduct = existingPost.title;
    _selectedRegion =
        existingPost.region.trim().isEmpty ? null : existingPost.region;
    _selectedDistrict =
        existingPost.district.trim().isEmpty ? null : existingPost.district;
    _quantityController.text = existingPost.quantity;
    if (existingPost.pricePerKg != null) {
      final value = existingPost.pricePerKg!;
      _priceController.text =
          value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
    }
    _phoneController.text = existingPost.phone;
    _explainController.text = existingPost.description;
    _streetController.text = existingPost.street;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _explainController.dispose();
    _streetController.dispose();
    _customProductController.dispose();
    super.dispose();
  }

  Stream<List<String>> _productStream() {
    return _productCatalogService.watchProductLabels();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedProduct = _selectedProduct == _otherProductLabel
        ? _customProductController.text.trim()
        : _selectedProduct?.trim();

    if (selectedProduct == null || selectedProduct.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chagua bidhaa kwanza.'),
        ),
      );
      return;
    }

    final parsedPrice = double.tryParse(_priceController.text.trim());
    if (parsedPrice == null || parsedPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Weka bei sahihi kwa kilo.',
          ),
        ),
      );
      return;
    }

    if (_selectedRegion == null || _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chagua mkoa na wilaya.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final submittedType = _postType;
    final result = await userPost(
      street: _streetController.text.trim(),
      quantity: _quantityController.text.trim(),
      phone: _phoneController.text.trim(),
      explanation: _explainController.text.trim(),
      productName: selectedProduct,
      pricePerKg: parsedPrice,
      region: _selectedRegion!,
      districtName: _selectedDistrict!,
      postType: submittedType,
      postId: widget.existingPost?.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (result == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? submittedType == 'buy'
                    ? 'Ombi la kununua limeboreshwa.'
                    : 'Tangazo la kuuza limeboreshwa.'
                : submittedType == 'buy'
                    ? 'Ombi la kununua limetumwa.'
                    : 'Tangazo la kuuza limechapishwa.',
          ),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ProductCard()),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Imeshindikana kuhifadhi tangazo.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final districts = _selectedRegion == null
        ? const <String>[]
        : districtsForRegion(_selectedRegion!);

    return Scaffold(
      appBar: AppBar(
        title: MarketPageTitle(
          title: _isEditing
              ? bi('Hariri Tangazo', 'Edit Post')
              : bi('Unda Tangazo', 'Create Post'),
          subtitle: _isEditing
              ? bi(
                  'Boresha taarifa za tangazo lako na uhifadhi mabadiliko.',
                  'Update your listing details and save changes.',
                )
              : bi(
                  'Unda ombi la kununua au tangazo la kuuza kwa hatua chache.',
                  'Create a buy request or sell offer in a few steps.',
                ),
        ),
        actions: const <Widget>[ThemeModeButton()],
      ),
      body: MarketBackground(
        child: SafeArea(
          child: StreamBuilder<List<String>>(
            stream: _productStream(),
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              final productItems = <String>[
                ...snapshot.data ?? const <String>[]
              ];
              if (_selectedProduct != null &&
                  _selectedProduct != _otherProductLabel &&
                  !productItems.contains(_selectedProduct)) {
                productItems.insert(0, _selectedProduct!);
              }
              if (!productItems.contains(_otherProductLabel)) {
                productItems.add(_otherProductLabel);
              }

              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final fieldWidth = isWide
                      ? (constraints.maxWidth - 52) / 2
                      : constraints.maxWidth;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        MarketPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SectionHeader(
                                icon: _isEditing
                                    ? Icons.edit_note_rounded
                                    : Icons.add_business_rounded,
                                title: _isEditing
                                    ? bi('Boresha tangazo',
                                        'Update your listing')
                                    : bi('Tangazo la haraka', 'Quick listing'),
                                subtitle: _isEditing
                                    ? bi(
                                        'Badili bidhaa, eneo na mawasiliano kabla ya kuhifadhi.',
                                        'Adjust the product, location, and contact details before saving.',
                                      )
                                    : bi(
                                        'Tuma ombi la kununua au tangazo la kuuza bila picha.',
                                        'Post a buy request or a sell offer without images.',
                                      ),
                              ),
                              const SizedBox(height: 18),
                              SegmentedButton<String>(
                                style: SegmentedButton.styleFrom(
                                  backgroundColor: palette.panelSoft,
                                  foregroundColor: onSurface,
                                  selectedBackgroundColor:
                                      palette.accent.withValues(alpha: 0.2),
                                  selectedForegroundColor: onSurface,
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
                                        initialValue: productItems
                                                .contains(_selectedProduct)
                                            ? _selectedProduct
                                            : null,
                                        dropdownColor: palette.panel,
                                        items: productItems
                                            .map(
                                              (String product) =>
                                                  DropdownMenuItem<String>(
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
                                            return 'Chagua bidhaa.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    if (_selectedProduct == _otherProductLabel)
                                      SizedBox(
                                        width: fieldWidth,
                                        child: TextFormField(
                                          controller: _customProductController,
                                          decoration: const InputDecoration(
                                            labelText: 'Custom product',
                                            prefixIcon:
                                                Icon(Icons.edit_rounded),
                                          ),
                                          validator: (String? value) {
                                            if (_selectedProduct ==
                                                    _otherProductLabel &&
                                                (value == null ||
                                                    value.trim().isEmpty)) {
                                              return 'Weka jina la bidhaa.';
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
                                          labelText: 'Kiasi (kg)',
                                          prefixIcon:
                                              Icon(Icons.scale_outlined),
                                        ),
                                        validator: (String? value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Weka kiasi.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: fieldWidth,
                                      child: TextFormField(
                                        controller: _priceController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'Price per kg (TZS)',
                                          prefixIcon:
                                              Icon(Icons.payments_outlined),
                                        ),
                                        validator: (String? value) {
                                          final parsed = double.tryParse(
                                              value?.trim() ?? '');
                                          if (parsed == null || parsed <= 0) {
                                            return 'Weka bei sahihi.';
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
                                          labelText: 'Phone',
                                          prefixIcon: Icon(Icons.call_rounded),
                                        ),
                                        validator: (String? value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Weka namba ya simu.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: fieldWidth,
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _selectedRegion,
                                        dropdownColor: palette.panel,
                                        items: marketRegions
                                            .map(
                                              (String region) =>
                                                  DropdownMenuItem<String>(
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
                                          prefixIcon:
                                              Icon(Icons.public_rounded),
                                        ),
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Chagua mkoa.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: fieldWidth,
                                      child: DropdownButtonFormField<String>(
                                        initialValue: districts
                                                .contains(_selectedDistrict)
                                            ? _selectedDistrict
                                            : null,
                                        dropdownColor: palette.panel,
                                        items: districts
                                            .map(
                                              (String district) =>
                                                  DropdownMenuItem<String>(
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
                                          prefixIcon:
                                              Icon(Icons.location_city_rounded),
                                        ),
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Chagua wilaya.';
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
                                          labelText: 'Street',
                                          prefixIcon:
                                              Icon(Icons.home_work_outlined),
                                        ),
                                        validator: (String? value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Weka mtaa wako.';
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
                                          labelText: 'Maelezo',
                                          alignLabelWithHint: true,
                                          prefixIcon: Icon(Icons.notes_rounded),
                                        ),
                                        validator: (String? value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Ongeza maelezo mafupi.';
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
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : Icon(
                                            _isEditing
                                                ? Icons.save_outlined
                                                : Icons.rocket_launch_outlined,
                                          ),
                                    label: Text(_isSubmitting
                                        ? _isEditing
                                            ? 'Saving...'
                                            : 'Posting...'
                                        : _isEditing
                                            ? 'Save changes'
                                            : 'Publish'),
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
