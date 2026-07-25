import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int index;
  final VoidCallback? onClickCard, onClickDelete;
  const ProductCard(
      {super.key,
      required this.product,
      required this.index,
      this.onClickCard,
      this.onClickDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: ListTile(
        onTap: onClickCard,
        leading: Text("${index + 1}", style: TextStyle(fontSize: 18)),
        title: Text("${product.name}", style: TextStyle(fontSize: 22)),
        subtitle: Text(
          "Price: \$ ${product.price} • ${product.category?.name ?? ""}",
        ),
        trailing: IconButton(
          onPressed: onClickDelete,
          icon: Icon(Icons.delete, color: Colors.red),
        ),
      ),
    );
  }
}
