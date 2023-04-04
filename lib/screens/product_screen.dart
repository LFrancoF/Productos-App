import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:productos_app/providers/product_form_provider.dart';
import 'package:provider/provider.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/ui/input_decorations.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';

class ProductScreen extends StatelessWidget {
   
  const ProductScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    
    final productService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(productService.selectedProduct),
      child: _ProductScreenBody(productService: productService)
    );
  }
}

class _ProductScreenBody extends StatefulWidget {
  const _ProductScreenBody({
    super.key,
    required this.productService,
  });

  final ProductsService productService;

  @override
  State<_ProductScreenBody> createState() => _ProductScreenBodyState();
}

class _ProductScreenBodyState extends State<_ProductScreenBody> {
  @override
  Widget build(BuildContext context) {

    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Stack(
              children: [

                ProductImage(url: widget.productService.selectedProduct.picture),

                Positioned(
                  top: 60, left: 20,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.elliptical(20, 30), right: Radius.circular(10)),
                    child: Container(
                      color: Colors.black.withOpacity(0.25),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_sharp, size: 40, color: Colors.white,)
                      ),
                    ),
                  )
                ),

                Positioned(
                  top: 60, right: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.black.withOpacity(0.25),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: IconButton(
                          onPressed: ()async{
                            
                            final option = await _showMyDialog(context);

                            if (option == null) return; //si cancelamos ya no hacemos nada

                            final picker = ImagePicker();
                            final XFile? pickedfile = await picker.pickImage(
                              source: (option == 1)   //depende que seleccionamos en el cuadro de dialogo nos abrira la camara o galeria
                              ? ImageSource.camera
                              : ImageSource.gallery,
                              imageQuality: 100
                            );

                            if (pickedfile == null) return;  //si cancelamos al tomar foto o seleccionar de galeria no hacemos nada

                            widget.productService.updateSelectedProductImage(pickedfile.path);

                          },
                          icon: const Icon(Icons.camera_alt_outlined, size: 40, color: Colors.white,)
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),

            const _ProductForm(),
            
            const SizedBox(height: 50)
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: (widget.productService.isSaving)
          ? null

          : () async{
          
          if (!productForm.isValidForm()) return;
          final String? imageURL = await widget.productService.uploadImage();
          if (imageURL != null) productForm.product.picture = imageURL;
          await widget.productService.saveOrCreateProduct(productForm.product);

          if (!mounted) return;
          Navigator.of(context).pop();
          
          },
        child: (widget.productService.isSaving)
          ? const CircularProgressIndicator(color: Colors.white,)
          : const Icon(Icons.save_outlined),
      ),
    );
  }
}

//Funcion para llamar el widget de dialogo para escoger entre camara o galeria
Future<int?> _showMyDialog(context) async {
  return showDialog<int>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (context) => const DialogImage()
  );
}

class _ProductForm extends StatelessWidget {
  const _ProductForm();

  @override
  Widget build(BuildContext context) {

    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: _buildBoxDecoration(),
        child: Form(
          key: productForm.formkey,
          child: Column(
            children: [
              const SizedBox(height: 10),

              TextFormField(
                initialValue: product.name,
                onChanged: (value) => product.name = value,
                validator: (value) {
                  return (value == null || value.isEmpty)
                  ? 'El nombre es obligatorio'
                  : null;
                },
                decoration: InputDecorations.authInputDecoration(
                  hintText: 'Nombre del Producto',
                  labelText: 'Nombre'
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                initialValue: product.price.toString(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
                ],
                onChanged: (value) {
                  (double.tryParse(value) == null)
                  ? product.price = 0
                  : product.price = double.parse(value);
                },
                keyboardType: TextInputType.number,
                decoration: InputDecorations.authInputDecoration(
                  hintText: '\$150',
                  labelText: 'Precio'
                ),
              ),

              const SizedBox(height: 30),

              SwitchListTile.adaptive(
                value: product.available,
                title: const Text('Disponible'),
                activeColor: Colors.indigo,
                onChanged: productForm.updateAvailability   // es lo mismo que: (value) => productForm.updateAvailability(value),
              ),

              const SizedBox(height: 30),

            ],
          )
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        offset: const Offset(0, 5),
        blurRadius: 5
      )
    ]
  );
}