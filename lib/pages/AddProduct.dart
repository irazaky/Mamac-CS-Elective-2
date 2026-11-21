import 'package:cs_elective_2/models/product.dart';
import 'package:cs_elective_2/providers/category_provider.dart';
import 'package:cs_elective_2/utils/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/product_provider.dart';

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _imageUrl = TextEditingController();
  int? _categoryId;
  bool _saving = false;
  bool _uploading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final p = widget.product;
    if (p != null) {
      _name.text = p.name;
      _desc.text = p.description ?? '';
      _price.text = p.price.toString();
      _stock.text = p.stock.toString();
      _imageUrl.text = p.imageUrl ?? '';
      // 0 means the category was deleted, so nothing is selected
      _categoryId = p.categoryId == 0 ? null : p.categoryId;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _stock.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  // pick an image, upload it to Supabase Storage and put its link in the field
  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final url = await ref
          .read(productProvider.notifier)
          .uploadImage(bytes, file.name);
      if (mounted) setState(() => _imageUrl.text = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${errorMessage(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // now works for both adding and editing products
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final notifier = ref.read(productProvider.notifier);

      // we have 2 methods for creating & updating, hence the if/else
      if (_isEditing) {
        await notifier.updateProduct(
          widget.product!.copyWith(
            name: _name.text.trim(),
            description: _desc.text.trim(),
            price: double.parse(_price.text.trim()),
            stock: int.parse(_stock.text.trim()),
            categoryId: _categoryId!,
            imageUrl: _imageUrl.text.trim(),
          ),
        );
      } else {
        await ref
            .read(productProvider.notifier)
            .addProduct(
              Product(
                id: 0,
                name: _name.text.trim(),
                description: _desc.text.trim(),
                price: double.parse(_price.text.trim()),
                stock: int.parse(_stock.text.trim()),
                categoryId: _categoryId!,
                imageUrl: _imageUrl.text.trim(),
              ),
            );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${errorMessage(e)}')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Product' : 'Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person), // left side, inside the field
                  // suffixIcon: Icon(Icons.clear),    // right side, inside the field
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _price,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  return (n == null || n < 0) ? 'Enter a valid price' : null;
                },
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _stock,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  return (n == null || n < 0) ? 'Enter a valid stock' : null;
                },
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _imageUrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}), // refresh the preview
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _uploading ? null : _pickImage,
                icon: _uploading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(_uploading ? 'Uploading...' : 'Upload image'),
              ),
              if (_imageUrl.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 120,
                    child: Image.network(
                      _imageUrl.text.trim(),
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              categoriesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Could not load categories: $e'),
                    TextButton(
                      onPressed: () => ref.invalidate(categoriesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
                data: (categories) => DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) => v == null ? 'Select a category' : null,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
