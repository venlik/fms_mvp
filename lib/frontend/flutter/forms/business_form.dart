import 'package:flutter/material.dart';

class BusinessForm extends StatefulWidget {
  const BusinessForm({
    super.key,
    this.businessName,
    this.businessEmail,
    this.businessPhoneNumber,
    this.businessCurrency,
    this.businessServiceLocation,
    this.businessFullAddress,
    this.onSubmit,
  });

  final String? businessName;
  final String? businessEmail;
  final String? businessPhoneNumber;
  final String? businessCurrency;
  final String? businessServiceLocation;
  final String? businessFullAddress;
  final Function(
    String name,
    String email,
    String phone,
    String currency,
    String location,
    String address,
  )?
  onSubmit;

  @override
  State<BusinessForm> createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessPhoneNumberController = TextEditingController();
  final _businessCurrencyController = TextEditingController();
  final _businessServiceLocationController = TextEditingController();
  final _businessFullAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _businessNameController.text = widget.businessName ?? '';
    _businessEmailController.text = widget.businessEmail ?? '';
    _businessPhoneNumberController.text = widget.businessPhoneNumber ?? '';
    _businessCurrencyController.text = widget.businessCurrency ?? '';
    _businessServiceLocationController.text =
        widget.businessServiceLocation ?? '';
    _businessFullAddressController.text = widget.businessFullAddress ?? '';
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessEmailController.dispose();
    _businessPhoneNumberController.dispose();
    _businessCurrencyController.dispose();
    _businessServiceLocationController.dispose();
    _businessFullAddressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      final businessName = _businessNameController.text;
      final businessEmail = _businessEmailController.text;
      final businessPhone = _businessPhoneNumberController.text;
      final businessCurrency = _businessCurrencyController.text;
      final businessServiceLocation = _businessServiceLocationController.text;
      final businessFullAddress = _businessFullAddressController.text;

      // Perform form submission logic here
      print('Submitted Business Form:');
      print('Business Name: $businessName');
      print('Email: $businessEmail');
      print('Phone Number: $businessPhone');
      print('Currency: $businessCurrency');
      print('Service Location: $businessServiceLocation');
      print('Full Address: $businessFullAddress');
      widget.onSubmit?.call(
        businessName,
        businessEmail,
        businessPhone,
        businessCurrency,
        businessServiceLocation,
        businessFullAddress,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Business Form')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _businessNameController,
                  decoration: InputDecoration(labelText: 'Business Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a business name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _businessEmailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _businessPhoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _businessCurrencyController,
                  decoration: InputDecoration(
                    labelText: 'Currency (ISO string)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a currency';
                    }
                    if (value.length < 3) {
                      return 'Please enter a valid currency';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _businessServiceLocationController,
                  decoration: InputDecoration(labelText: 'Service Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a service location';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _businessFullAddressController,
                  decoration: InputDecoration(labelText: 'Full Address'),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.0),
                ElevatedButton(onPressed: () => _submit, child: Text('Submit')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
