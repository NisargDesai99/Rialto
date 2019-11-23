import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rialto/data/product.dart';
import 'package:rialto/pages/main/item/interested_users_view.dart';
import 'package:rialto/utils/text_utilities.dart';
import 'package:transparent_image/transparent_image.dart';

class ProductsView extends StatefulWidget {
  final Firestore firestore = Firestore.instance;

  ProductsView({Key key}) : super(key: key);

  _ProductsViewState createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final List<Product> _products = new List();
  Key _scrollKey = new PageStorageKey('scroll-preservation');

  @override
  void initState() {
    super.initState();
    print('init');
    CollectionReference itemsReference = widget.firestore.collection('items');
    itemsReference.snapshots().forEach((snapshot) {
      snapshot.documents.forEach((documentSnapshot) {
        _products.add(new Product(
          name: documentSnapshot.data['name'],
          price: double.parse("${documentSnapshot.data['price']}"),
          documentId: documentSnapshot.reference.documentID,
          description: documentSnapshot.data['description'],
          image: documentSnapshot.data['image'],
          sellerEmail: documentSnapshot.data['seller'],
        ));
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: _scrollKey,
      itemCount: _products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery
                .of(context)
                .size
                .height / 1),
      ),
      itemBuilder: (BuildContext context, int index) {
        return _SingleProductView(_products[index]);
      },
    );
  }
}

class _SingleProductView extends StatelessWidget {
  final Product _product;

  _SingleProductView(this._product);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, top: 10.0, bottom: 8.0),
      child: Card(
        elevation: 6.0,
        color: Colors.cyanAccent,
        child: Hero(
          tag: _product.name,
          child: Material(
            child: InkWell(
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.contain, // otherwise the logo will be tiny
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation(
                                    Colors.redAccent,
                                  ),
                                ),
                              ),
                              Center(
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: _product.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Text(
                      getTextWithCap(_product.name, 15),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      "\$${_product.price}",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    FlatButton(
                      color: Colors.redAccent,
                      onPressed: () async {
                        DocumentSnapshot snapshot = await Firestore.instance
                            .collection('items')
                            .document(_product.documentId)
                            .get();
                        // todo simplify this with helper class for firestore
                        Map namesForEmail = snapshot.data['names_for_email'];
                        if (_product.sellerEmail == "a@utdallas.edu") {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  content: InterestedUsersView(snapshot),
                                );
                              });
                        } else {
                          namesForEmail['a@utdallas.edu'] = 'Arham Siddiqui';
                          snapshot.reference.updateData({
                            'names_for_email': namesForEmail,
                          });
                          Scaffold.of(context).showSnackBar(
                            new SnackBar(
                              content: new Text(
                                  "You have marked this item as interested!"),
                            ),
                          );
                        }
                      },
                      child: Text(
                        _product.sellerEmail == 'a@utdallas.edu'
                            ? "View Interested"
                            : "Interested",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                )
//          child: GridTile(
//            footer: Container(
//              color: Colors.white70,
//              child: ListTile(
//                leading: Text(prodName, style:TextStyle(fontWeight: FontWeight.bold),
//                ),
//                title: Text("\$$prodPrice", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),
//                ),
//              ),
//            ),
//
//            child: Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Image.asset(prodImage, fit:BoxFit.cover),
//            ),
//          ),
            ),
          ),
        ),
      ),
    );
  }
}
