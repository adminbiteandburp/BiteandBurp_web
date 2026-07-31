import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class WaiterMenuView extends StatefulWidget {
  final String hotelId;

  const WaiterMenuView({super.key, required this.hotelId});

  @override
  State<WaiterMenuView> createState() => _WaiterMenuViewState();
}

class _WaiterMenuViewState extends State<WaiterMenuView> {
  String selectedTable = "Table 1";

  // 🌟 LIVE MENU DATA & CATEGORIES
  List<Map<String, dynamic>> liveMenu = [];
  List<String> categories = ["All"];
  String selectedCategory = "All";
  Map<String, String> categoryNameMap = {};

  @override
  void initState() {
    super.initState();
    _fetchLiveMenu();
  }

  void _fetchLiveMenu() {
    // 🌟 Listen to Categories collection to map Category IDs to human-readable names
    FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.hotelId)
        .collection('categories')
        .snapshots()
        .listen((catSnapshot) {
          Map<String, String> newCategoryMap = {};
          for (var doc in catSnapshot.docs) {
            var cData = doc.data();
            String name =
                cData['name'] ??
                cData['categoryName'] ??
                cData['title'] ??
                doc.id;
            newCategoryMap[doc.id] = name;
          }
          if (mounted) {
            setState(() {
              categoryNameMap = newCategoryMap;
            });
          }
        });

    FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.hotelId)
        .collection('products')
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;

          List<Map<String, dynamic>> fetchedItems = [];
          Set<String> catSet = {"All"};

          // 🌟 FIX: Fetching 100% REAL data from Firestore documents
          for (var doc in snapshot.docs) {
            var data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;

            // 🌟 Category Name Resolution Logic
            String rawId = (data['categoryId'] ?? '').toString().trim();
            String rawCat = (data['category'] ?? '').toString().trim();
            String resolvedCategory =
                data['categoryName'] ??
                categoryNameMap[rawId] ??
                categoryNameMap[rawCat] ??
                (rawCat.isNotEmpty && rawCat != rawId ? rawCat : null) ??
                (rawCat.isNotEmpty
                    ? rawCat
                    : (rawId.isNotEmpty ? rawId : 'Others'));

            data['category'] = resolvedCategory;
            fetchedItems.add(data);

            if (resolvedCategory.isNotEmpty) {
              catSet.add(resolvedCategory);
            }
          }

          // 🌟 NAYA FIX: 5 Mock Items for Localhost Testing (Corrected to List format to prevent Type Error)
          final List<Map<String, dynamic>> mockItems = [
            {
              "id": "mock_1",
              "name": "Mock Test Burger",
              "price": 30.0,
              "category": "Testing",
              "isVeg": true,
              "variants": [
                {"name": "Small", "price": 0.0},
                {"name": "Medium", "price": 15.0},
                {"name": "Large", "price": 30.0},
                {"name": "Jumbo", "price": 50.0},
              ],
              "addOns": [
                {"name": "Extra Cheese", "price": 10.0},
                {"name": "Mayo", "price": 5.0},
              ],
            },
            {
              "id": "mock_2",
              "name": "Mock Test Pizza",
              "price": 30.0,
              "category": "Testing",
              "isVeg": true,
              "variants": [
                {"name": "Regular", "price": 0.0},
                {"name": "Medium", "price": 40.0},
                {"name": "Large", "price": 80.0},
                {"name": "Cheese Burst", "price": 120.0},
              ],
              "addOns": [
                {"name": "Olives", "price": 15.0},
                {"name": "Jalapeno", "price": 15.0},
                {"name": "Extra Dip", "price": 10.0},
              ],
            },
            {
              "id": "mock_3",
              "name": "Mock Test Pasta",
              "price": 30.0,
              "category": "Testing",
              "isVeg": true,
              "variants": [
                {"name": "Half", "price": 0.0},
                {"name": "Full", "price": 40.0},
                {"name": "Family", "price": 90.0},
                {"name": "Party", "price": 150.0},
              ],
              "addOns": [
                {"name": "Garlic Bread", "price": 25.0},
                {"name": "Extra Veggies", "price": 20.0},
              ],
            },
            {
              "id": "mock_4",
              "name": "Mock Test Coffee",
              "price": 30.0,
              "category": "Testing",
              "isVeg": true,
              "variants": [
                {"name": "Hot", "price": 0.0},
                {"name": "Cold", "price": 10.0},
                {"name": "Frappe", "price": 30.0},
                {"name": "Irish", "price": 50.0},
              ],
              "addOns": [
                {"name": "Extra Shot", "price": 20.0},
                {"name": "Whipped Cream", "price": 15.0},
              ],
            },
            {
              "id": "mock_5",
              "name": "Mock Test Shake",
              "price": 30.0,
              "category": "Testing",
              "isVeg": true,
              "variants": [
                {"name": "Classic", "price": 0.0},
                {"name": "Thick", "price": 20.0},
                {"name": "Monster", "price": 50.0},
                {"name": "Freakshake", "price": 100.0},
              ],
              "addOns": [
                {"name": "Ice Cream Scoop", "price": 20.0},
                {"name": "Choco Chips", "price": 10.0},
              ],
            },
          ];
          fetchedItems.addAll(mockItems);
          catSet.add("Testing");

          // 🌟 UPDATE UI STATE
          setState(() {
            liveMenu = fetchedItems;
            categories = catSet.toList();
          });
        });
  }

  Map<String, int> cart = {};
  Map<String, double> itemPrices = {};
  // 🌟 NAYA FIX: Memory for Notes & Instructions
  Map<String, String> itemNotes = {};
  Map<String, bool> showNoteField = {};
  String overallNote = "";
  bool showOverallNote = false;
  bool isFiringKOT = false;

  final List<String> availableTables = [
    "Table 1",
    "Table 2",
    "Table 3",
    "Table 4",
    "Table 5",
    "Table 6",
    "Table 7",
    "Table 8",
    "Table 9",
    "Table 10",
  ];

  double get cartTotal {
    double total = 0;
    cart.forEach((itemName, qty) {
      total += (itemPrices[itemName] ?? 0) * qty;
    });
    return total;
  }

  void _updateCart(String itemName, double price, int change) {
    setState(() {
      int currentQty = cart[itemName] ?? 0;
      int newQty = currentQty + change;
      if (newQty <= 0) {
        cart.remove(itemName);
      } else {
        cart[itemName] = newQty;
        itemPrices[itemName] = price;
      }
    });
  }

  // Real KOT Fire pushing data to POS App Firestore
  Future<void> _fireKOT() async {
    if (cart.isEmpty) return;
    setState(() => isFiringKOT = true);

    Map<String, int> safeItems = Map<String, int>.from(cart);
    double totalAmount = 0.0;
    Map<String, dynamic> formattedItems = {};
    cart.forEach((key, value) {
      totalAmount += (itemPrices[key] ?? 0.0) * value;
      formattedItems[key] = {
        'quantity': value,
        'price': itemPrices[key] ?? 0.0,
        // 🌟 FIX: Sending Actual Item Note
        'note': itemNotes[key] ?? '',
      };
    });

    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.hotelId)
        .collection('live_orders')
        .add({
          'tableId': selectedTable.replaceAll('Table ', '').trim(),
          'tableName': selectedTable,
          'totalAmount': totalAmount,
          'items': formattedItems,
          // 🌟 FIX: Sending Overall Instructions to POS
          'overallNote': overallNote,
          'time': FieldValue.serverTimestamp(),
          'status': 'Auto-Accept',
        });

    setState(() {
      itemNotes.clear();
      showNoteField.clear();
      overallNote = "";
      showOverallNote = false;
      cart.clear();
      isFiringKOT = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.print, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "🔥 KOT Fired Successfully!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 🌟 NAYA FIX: 3x4 TABLE SELECTION GRID DIALOG
  void _showTableGridDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.all(20), // Screen borders se padding
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Jini height chahiye utni hi lega
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Table for KOT",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepPurple,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),

                // 🌟 THE 3-COLUMN GRID
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 🌟 3 Items per row
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0, // Square boxes
                          ),
                      itemCount: availableTables.length,
                      itemBuilder: (context, index) {
                        String table = availableTables[index];
                        bool isSelected = selectedTable == table;

                        // Default to green, you can sync this with firebase later
                        Color statusColor = Colors.green.shade500;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedTable = table;
                              cart.clear(); // 🌟 Table change hote hi purani table ka cart empty
                            });
                            Navigator.pop(context); // Dialog band karo
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurple.withOpacity(0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.table_restaurant_rounded,
                                  color: statusColor,
                                  size: 26,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  table,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🌟 NAYA FEATURE: Quick Notes & Presets Custom Popup
  void _showQuickNotesPopup(
    BuildContext context,
    StateSetter setModalState,
    String target,
  ) {
    // Some basic presets
    final List<String> presetNotes = [
      "Extra Spicy",
      "Less Spicy",
      "Make it Sweet",
      "No Onion/Garlic",
      "Jain Preparation",
      "Serve Hot",
      "Pack Separately",
      "Less Oil",
    ];

    TextEditingController customNoteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Quick Notes",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presetNotes.map((note) {
                    return InkWell(
                      onTap: () {
                        // Apply the note
                        setModalState(() {
                          if (target == "overall") {
                            overallNote = overallNote.isEmpty
                                ? note
                                : "$overallNote, $note";
                            showOverallNote = true;
                          } else {
                            itemNotes[target] =
                                (itemNotes[target] ?? "").isEmpty
                                ? note
                                : "${itemNotes[target]}, $note";
                            showNoteField[target] = true;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          note,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: customNoteCtrl,
                  decoration: InputDecoration(
                    hintText: "Or type custom note...",
                    hintStyle: GoogleFonts.poppins(fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Colors.deepPurple),
                      onPressed: () {
                        if (customNoteCtrl.text.trim().isNotEmpty) {
                          setModalState(() {
                            if (target == "overall") {
                              overallNote = overallNote.isEmpty
                                  ? customNoteCtrl.text
                                  : "$overallNote, ${customNoteCtrl.text}";
                              showOverallNote = true;
                            } else {
                              itemNotes[target] =
                                  (itemNotes[target] ?? "").isEmpty
                                  ? customNoteCtrl.text
                                  : "${itemNotes[target]}, ${customNoteCtrl.text}";
                              showNoteField[target] = true;
                            }
                          });
                          Navigator.pop(ctx);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🌟 NAYA FIX: 1. Cart Verification Bottom Sheet
  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        // 🌟 FIX: Wrapped with StatefulBuilder to allow dynamic UI updates inside bottom sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 15,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Verify Order",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Divider(),
                  // Render Cart Items
                  // FIX: Replaced barebones cart with Rich Customer Cart UI Parity
                  ...cart.entries.map((entry) {
                    String itemName = entry.key;
                    int qty = entry.value;
                    double price = itemPrices[itemName] ?? 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 🌟 FIX: Fully Interactive "Add note" Button from Customer UI
                              (!showNoteField.containsKey(itemName) ||
                                          !showNoteField[itemName]!) &&
                                      (itemNotes[itemName] ?? "").isEmpty
                                  ? InkWell(
                                      // 🌟 FIXED: Changed setState to setModalState for real-time Cart update
                                      onTap: () => setModalState(
                                        () => showNoteField[itemName] = true,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.edit_note,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Add note",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              Row(
                                children: [
                                  // Quantity Controls (+/-)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.deepPurple.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          // 🌟 FIXED: Added setModalState for real-time quantity update inside the cart
                                          onTap: () {
                                            _updateCart(itemName, price, -1);
                                            setModalState(() {});
                                          },
                                          child: const Icon(
                                            Icons.remove,
                                            size: 18,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "$qty",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        InkWell(
                                          // 🌟 FIXED: Added setModalState for real-time quantity update inside the cart
                                          onTap: () {
                                            _updateCart(itemName, price, 1);
                                            setModalState(() {});
                                          },
                                          child: const Icon(
                                            Icons.add,
                                            size: 18,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    "₹${(price * qty).toStringAsFixed(0)}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // 🌟 FIX: Item Note - Dynamic TextField to Saved Label Switch
                          if ((showNoteField[itemName] ?? false) ||
                              (itemNotes[itemName] ?? "").isNotEmpty)
                            (showNoteField[itemName] ?? false)
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SizedBox(
                                      height: 40,
                                      child: TextField(
                                        autofocus:
                                            (itemNotes[itemName] ?? "").isEmpty,
                                        onChanged: (val) => setModalState(
                                          () => itemNotes[itemName] = val,
                                        ),
                                        onSubmitted: (val) {
                                          if (val.trim().isNotEmpty)
                                            setModalState(
                                              () => showNoteField[itemName] =
                                                  false,
                                            );
                                        },
                                        controller:
                                            TextEditingController(
                                                text: itemNotes[itemName],
                                              )
                                              ..selection =
                                                  TextSelection.fromPosition(
                                                    TextPosition(
                                                      offset:
                                                          (itemNotes[itemName] ??
                                                                  "")
                                                              .length,
                                                    ),
                                                  ),
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "E.g. Less spicy...",
                                          filled: true,
                                          fillColor: Colors.black.withOpacity(
                                            0.05,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add_circle_outline,
                                                  size: 20,
                                                  color: Colors.deepPurple,
                                                ),
                                                onPressed: () =>
                                                    _showQuickNotesPopup(
                                                      context,
                                                      setModalState,
                                                      itemName,
                                                    ),
                                              ),
                                              (itemNotes[itemName] ?? "")
                                                      .trim()
                                                      .isEmpty
                                                  ? IconButton(
                                                      icon: const Icon(
                                                        Icons.close,
                                                        size: 18,
                                                        color: Colors.black45,
                                                      ),
                                                      onPressed: () {
                                                        FocusManager
                                                            .instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                        setModalState(() {
                                                          itemNotes[itemName] =
                                                              "";
                                                          showNoteField[itemName] =
                                                              false;
                                                        });
                                                      },
                                                    )
                                                  : IconButton(
                                                      icon: const Icon(
                                                        Icons.check_circle,
                                                        size: 22,
                                                        color: Colors.green,
                                                      ),
                                                      onPressed: () {
                                                        FocusManager
                                                            .instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                        setModalState(
                                                          () =>
                                                              showNoteField[itemName] =
                                                                  false,
                                                        ); // 🌟 Hides TextField, Shows Label
                                                      },
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "${itemNotes[itemName]}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.green.shade800,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => setModalState(
                                            () =>
                                                showNoteField[itemName] = true,
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        InkWell(
                                          onTap: () => setModalState(() {
                                            itemNotes[itemName] = "";
                                            showNoteField[itemName] = false;
                                          }),
                                          child: const Icon(
                                            Icons.delete,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                        ],
                      ),
                    );
                  }),
                  const Divider(),

                  // 🌟 NAYA FEATURE: Smart Cross-Sell Belt & Compact Note Button
                  Builder(
                    builder: (ctx) {
                      // Filter items strictly between Rs 10 to 50
                      final crossSellItems = liveMenu.where((item) {
                        double p =
                            double.tryParse(item['price'].toString()) ?? 0.0;
                        return p >= 10 && p <= 50;
                      }).toList();

                      return Row(
                        children: [
                          // 🌟 FIX: Instructions Button matching Customer Cart
                          if (!showOverallNote && overallNote.isEmpty)
                            InkWell(
                              onTap: () =>
                                  setModalState(() => showOverallNote = true),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.deepPurple.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_note,
                                      size: 16,
                                      color: Colors.deepPurple.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Instructions",
                                      style: GoogleFonts.poppins(
                                        color: Colors.deepPurple.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          if (!showOverallNote &&
                              overallNote.isEmpty &&
                              crossSellItems.isNotEmpty)
                            const SizedBox(width: 12),

                          // Horizontal Quick-Add Belt for Cross Sell
                          if (!showOverallNote &&
                              overallNote.isEmpty &&
                              crossSellItems.isNotEmpty)
                            Expanded(
                              child: SizedBox(
                                height: 35,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: crossSellItems.length,
                                  itemBuilder: (context, index) {
                                    final crossItem = crossSellItems[index];
                                    double itemPrice =
                                        double.tryParse(
                                          crossItem['price'].toString(),
                                        ) ??
                                        0.0;
                                    String itemName =
                                        crossItem['name'] ?? "Item";

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: InkWell(
                                        onTap: () {
                                          _updateCart(itemName, itemPrice, 1);
                                          setModalState(() {});
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                          ),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "$itemName • ₹${itemPrice.toStringAsFixed(0)}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Icons.add_circle,
                                                size: 14,
                                                color: Colors.deepPurple,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  // 🌟 FIX: Overall Note - Dynamic TextField to Saved Label Switch
                  if (showOverallNote || overallNote.isNotEmpty)
                    showOverallNote
                        ? TextField(
                            autofocus: overallNote.isEmpty,
                            onChanged: (val) =>
                                setModalState(() => overallNote = val),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty)
                                setModalState(() => showOverallNote = false);
                            },
                            controller: TextEditingController(text: overallNote)
                              ..selection = TextSelection.fromPosition(
                                TextPosition(offset: overallNote.length),
                              ),
                            style: GoogleFonts.poppins(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: "Overall cooking instructions...",
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      size: 20,
                                      color: Colors.deepPurple,
                                    ),
                                    onPressed: () => _showQuickNotesPopup(
                                      context,
                                      setModalState,
                                      "overall",
                                    ),
                                  ),
                                  overallNote.trim().isEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.black45,
                                          ),
                                          onPressed: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            setModalState(() {
                                              overallNote = "";
                                              showOverallNote = false;
                                            });
                                          },
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.check_circle,
                                            size: 22,
                                            color: Colors.green,
                                          ),
                                          onPressed: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            setModalState(
                                              () => showOverallNote = false,
                                            ); // 🌟 Hides TextField, Shows Label
                                          },
                                        ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Instructions: $overallNote",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => setModalState(
                                    () => showOverallNote = true,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                InkWell(
                                  onTap: () => setModalState(() {
                                    overallNote = "";
                                    showOverallNote = false;
                                  }),
                                  child: const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),

                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height:
                        55, // 🌟 FIX: Increased height for a thicker, premium button
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close cart sheet
                        _showKOTTableConfirmDialog(); // 🌟 Open table popup before firing KOT
                      },
                      style: ElevatedButton.styleFrom(
                        // FIX: Changed button color to Deep Purple for UI Parity
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "Confirm & Select Table",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🌟 PREMIUM VARIANTS & ADD-ONS POPUP (STANDARDIZED WITH CUSTOMER MENU)
  void _showCustomizationPopup(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    String? selectedVariant;
    bool showVariantError = false; // 🌟 YEH LINE ADD KARNI HAI
    List<String> selectedAddOns = [];

    // Safe parsing for variants (supports Map and List forms)
    Map<String, double> variantsMap = {};
    if (item['variants'] != null) {
      if (item['variants'] is Map) {
        (item['variants'] as Map).forEach(
          (k, v) =>
              variantsMap[k.toString()] = double.tryParse(v.toString()) ?? 0.0,
        );
      } else if (item['variants'] is List) {
        for (var v in item['variants']) {
          if (v is Map && v['name'] != null && v['price'] != null) {
            variantsMap[v['name'].toString()] =
                double.tryParse(v['price'].toString()) ?? 0.0;
          }
        }
      }
    }

    // Safe parsing for add-ons (supports Map and List forms)
    Map<String, double> addOnsMap = {};
    final addonData = item['addons'] ?? item['addOns'];
    if (addonData != null) {
      if (addonData is Map) {
        (addonData as Map).forEach(
          (k, v) =>
              addOnsMap[k.toString()] = double.tryParse(v.toString()) ?? 0.0,
        );
      } else if (addonData is List) {
        for (var a in addonData) {
          if (a is Map && a['name'] != null && a['price'] != null) {
            addOnsMap[a['name'].toString()] =
                double.tryParse(a['price'].toString()) ?? 0.0;
          }
        }
      }
    }

    double basePrice = (item['price'] ?? 0.0).toDouble();
    String itemName = item['name'] ?? 'Item';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itemName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1B2F),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Customize your order",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Variants List (Radio buttons)
                    if (variantsMap.isNotEmpty) ...[
                      Text.rich(
                        TextSpan(
                          text: "Select Variant",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1B2F),
                          ),
                          children: [
                            if (showVariantError)
                              const TextSpan(
                                text: " (Select 1 option)",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: variantsMap.entries.map((entry) {
                          bool isSelected = selectedVariant == entry.key;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() => selectedVariant = entry.key);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.deepPurple.withAlpha(15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.grey.shade300,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Radio<String>(
                                      value: entry.key,
                                      groupValue: selectedVariant,
                                      activeColor: Colors.deepPurple,
                                      onChanged: (val) {
                                        setModalState(
                                          () => selectedVariant = val,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        fontSize: 14,
                                        color: isSelected
                                            ? Colors.deepPurple.shade900
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "₹${entry.value}",
                                    style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 2. Add-ons List (Checkboxes)
                    if (addOnsMap.isNotEmpty) ...[
                      const Text(
                        "Add-ons",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1B2F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: addOnsMap.entries.map((entry) {
                          bool isSelected = selectedAddOns.contains(entry.key);
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  selectedAddOns.remove(entry.key);
                                } else {
                                  selectedAddOns.add(entry.key);
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.deepPurple.withAlpha(10)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.deepPurple.withAlpha(150)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: isSelected,
                                      activeColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (val) {
                                        setModalState(() {
                                          if (val == true) {
                                            selectedAddOns.add(entry.key);
                                          } else {
                                            selectedAddOns.remove(entry.key);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "+ ₹${entry.value.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 3. Add to Cart Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          if (variantsMap.isNotEmpty &&
                              selectedVariant == null) {
                            setModalState(() {
                              showVariantError = true;
                            });
                            return;
                          }
                          double finalPrice = basePrice;
                          String uniqueCartKey = itemName;

                          if (selectedVariant != null) {
                            finalPrice += variantsMap[selectedVariant] ?? 0.0;
                            uniqueCartKey += " - $selectedVariant";
                          }
                          if (selectedAddOns.isNotEmpty) {
                            finalPrice += selectedAddOns
                                .map((a) => addOnsMap[a] ?? 0.0)
                                .fold<double>(
                                  0.0,
                                  (accTotal, p) => accTotal + p,
                                );
                            uniqueCartKey += " + ${selectedAddOns.join(", ")}";
                          }

                          _updateCart(uniqueCartKey, finalPrice, 1);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Apply & Add to Cart",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🌟 NAYA FIX: 2. Table Selection Dialog JUST BEFORE sending KOT
  void _showKOTTableConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // FIX: Added Close Button to Table Popup Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🌟 FIX: Wrapped in Expanded to prevent layout overflow on mobile screens
                    Expanded(
                      child: Text(
                        "Send KOT To Which Table?",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.deepPurple,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Flexible(
                  child: SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: availableTables.length,
                      itemBuilder: (context, index) {
                        String table = availableTables[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context); // Close table dialog
                            setState(() {
                              selectedTable = table; // 🌟 Set target table
                            });
                            _fireKOT(); // 🔥 FINAL STEP: FIRE KOT TO APP/PRINTER
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.table_restaurant_rounded,
                                  color: Colors.orangeAccent,
                                  size: 26,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  table,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.deepPurple.withAlpha(50),
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Captain Pad",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              "ID: ${widget.hotelId}",
              style: const TextStyle(color: Colors.black54, fontSize: 11),
            ),
          ],
        ),
        actions: [
          // 🌟 FIX: Premium Table Grid Popup Button
          Container(
            margin: const EdgeInsets.only(right: 15, top: 8, bottom: 8),
            child: InkWell(
              onTap: () =>
                  _showTableGridDialog(), // 🌟 Yeh function hum step 2 mein add karenge
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Text(
                      selectedTable,
                      style: GoogleFonts.poppins(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.deepPurple,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // 🌟 NEW STRUCTURE: Category Belt + Live Item List
      body: Column(
        children: [
          // 1. HORIZONTAL CATEGORY BELT
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                String cat = categories[index];
                bool isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () => setState(() => selectedCategory = cat),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 2. LIVE ITEMS LIST (Filtered by Category)
          Expanded(
            child: ListView.builder(
              cacheExtent:
                  3000, // 🌟 NAYA: Pre-render off-screen items to fix white screen
              addAutomaticKeepAlives:
                  true, // 🌟 NAYA: RAM mein state save rakho
              padding: const EdgeInsets.only(
                top: 5,
                left: 15,
                right: 15,
                bottom: 100,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: liveMenu
                  .where(
                    (item) =>
                        selectedCategory == "All" ||
                        item['category'] == selectedCategory,
                  )
                  .length,
              itemBuilder: (context, index) {
                var filteredMenu = liveMenu
                    .where(
                      (item) =>
                          selectedCategory == "All" ||
                          item['category'] == selectedCategory,
                    )
                    .toList();
                var data = filteredMenu[index];

                String name = data['name'] ?? 'Unknown';
                double price = (data['price'] ?? 0).toDouble();
                String categoryType = data['type'] ?? data['category'] ?? 'Veg';
                int qty = cart[name] ?? 0;

                // 🌟 NAYA: Database ka actual Veg/Non-veg status read karo
                bool isVeg =
                    data['isVeg'] == true ||
                    data['dietaryPref'] == 'Veg' ||
                    data['foodType'] == 'Veg' ||
                    (data['isVeg'] == null &&
                        data['dietaryPref'] == null &&
                        data['foodType'] == null); // Purani items Veg hongi
                bool hasCustomization =
                    (data['variants'] != null &&
                        (data['variants'] as List).isNotEmpty) ||
                    (data['addOns'] != null &&
                        (data['addOns'] as List).isNotEmpty);

                return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ), // 🌟 FIX: Customer menu style border thickness
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // VEG/NON-VEG ICON
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isVeg ? Colors.green : Colors.red,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: CircleAvatar(
                                radius: 3,
                                backgroundColor: isVeg
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    // 🌟 FIX: Standardized Font
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "₹${price.toStringAsFixed(0)}",
                                  style: GoogleFonts.poppins(
                                    // 🌟 FIX: Standardized Font
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ADD BUTTON OR QUANTITY TOGGLE
                          // ADD BUTTON OR QUANTITY TOGGLE
                          qty == 0
                              ? OutlinedButton(
                                  onPressed: () {
                                    if (hasCustomization) {
                                      _showCustomizationPopup(
                                        context,
                                        data,
                                      ); // 🌟 Variant Popup Khulega
                                    } else {
                                      _updateCart(
                                        name,
                                        price,
                                        1,
                                      ); // 🌟 Normal item direct add
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.deepPurple,
                                    side: const BorderSide(
                                      color: Colors.deepPurple,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    "ADD",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove,
                                          color: Colors.deepPurple,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _updateCart(name, price, -1),
                                      ),
                                      Text(
                                        "$qty",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.deepPurple,
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.deepPurple,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _updateCart(name, price, 1),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: index * 50))
                    .slideY(begin: 0.1);
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // 🌟 FIX: Sleek Customer-Style Floating View Cart Banner
      floatingActionButton: cartTotal > 0
          ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withAlpha(100),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () =>
                            _showCartBottomSheet(), // 🌟 Opens verification sheet
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${cart.values.fold<int>(0, (acc, qty) => acc + (qty as int))} ITEMS",
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(200),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    "₹${cartTotal.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    "VIEW CART",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.shopping_bag_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // FIX: Added ValueKey to prevent widget tree from resetting and causing weird rotation/entry glitches
                )
                .animate(key: const ValueKey('waiter_cart_anim'))
                .slideY(
                  begin: 1,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                )
          : null,
    );
  }
}
