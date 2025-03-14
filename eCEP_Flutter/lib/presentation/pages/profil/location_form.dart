import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/app/services/local_storage.dart';

class LocationForm extends StatefulWidget {
  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _storageService = Get.find<LocalStorageService>();
  final TextEditingController _quartierController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  void _loadLocation() {
    _quartierController.text = _storageService.quartier;
    _villeController.text = _storageService.ville;
    _selectedCountry = _storageService.pays;
  }

  Future<void> _saveLocation() async {
    _storageService.quartier = _quartierController.text;
    _storageService.ville = _villeController.text;
    _storageService.pays = _selectedCountry ?? 'Inconnu';
    Get.back();
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country.name;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulaire de localisation'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen.shade600,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen.shade100, Colors.lightGreen.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Informations de Localisation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _quartierController,
                      decoration: InputDecoration(
                        labelText: 'Quartier',
                        prefixIcon: const Icon(Icons.home),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _villeController,
                      decoration: InputDecoration(
                        labelText: 'Ville',
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedCountry ?? 'Choisir un pays',
                        style: const TextStyle(fontSize: 16),
                      ),
                      leading: const Icon(Icons.public, color: Colors.green),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: _pickCountry,
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        child: const Text(
                          'Enregistrer',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
