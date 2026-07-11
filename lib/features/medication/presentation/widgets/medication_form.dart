import 'package:flutter/material.dart';

import '../../domain/entities/medication.dart';
import 'medication_image_picker.dart';

/// ค่าที่กรอกในฟอร์มยา ส่งกลับให้หน้าจอที่เรียกใช้ผ่าน onSubmit
class MedicationFormValues {
  const MedicationFormValues({
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.note,
    required this.imagePath,
  });

  final String name;
  final String dosage;
  final String quantity;
  final String? note;

  /// path รูปยา อาจเป็น path ชั่วคราวที่ยังไม่ถูกบันทึกถาวรจนกว่าจะบันทึกสำเร็จ
  final String? imagePath;
}

/// ฟอร์มกรอกข้อมูลยา ใช้ร่วมกันระหว่างหน้าเพิ่มยาและแก้ไขยา
class MedicationForm extends StatefulWidget {
  const MedicationForm({
    super.key,
    this.initial,
    required this.onSubmit,
    required this.submitLabel,
    this.isSubmitting = false,
  });

  /// ข้อมูลยาเดิม ถ้าเป็น null แสดงว่าเป็นการเพิ่มยาใหม่
  final Medication? initial;
  final ValueChanged<MedicationFormValues> onSubmit;
  final String submitLabel;
  final bool isSubmitting;

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _quantityController;
  late final TextEditingController _noteController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _dosageController = TextEditingController(text: initial?.dosage ?? '');
    _quantityController = TextEditingController(text: initial?.quantity ?? '');
    _noteController = TextEditingController(text: initial?.note ?? '');
    _imagePath = initial?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      MedicationFormValues(
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        quantity: _quantityController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        imagePath: _imagePath,
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MedicationImagePicker(
            imagePath: _imagePath,
            onChanged: (path) => setState(() => _imagePath = path),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'ชื่อยา'),
            textInputAction: TextInputAction.next,
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dosageController,
            decoration: const InputDecoration(
              labelText: 'ขนาดยา',
              hintText: 'เช่น 500 mg',
            ),
            textInputAction: TextInputAction.next,
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'จำนวนที่รับประทานต่อครั้ง',
              hintText: 'เช่น 1 เม็ด',
            ),
            textInputAction: TextInputAction.next,
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'หมายเหตุ (ไม่บังคับ)',
            ),
            textInputAction: TextInputAction.done,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.isSubmitting ? null : _handleSubmit,
            child: widget.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
