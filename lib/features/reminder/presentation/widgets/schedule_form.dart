import 'package:flutter/material.dart';

import '../../../../core/utils/time_of_day_formatter.dart';
import '../../domain/entities/schedule.dart';
import 'schedule_date_range_field.dart';
import 'schedule_frequency_selector.dart';
import 'schedule_time_list_editor.dart';
import 'schedule_weekday_selector.dart';

/// ค่าที่กรอกในฟอร์มตารางยา ส่งกลับให้หน้าจอที่เรียกใช้ผ่าน onSubmit
class ScheduleFormValues {
  const ScheduleFormValues({
    required this.frequency,
    required this.weekdays,
    required this.times,
    required this.intervalHours,
    required this.startTime,
    required this.intervalDays,
    required this.startDate,
    required this.endDate,
  });

  final ScheduleFrequency frequency;
  final List<int> weekdays;
  final List<String> times;
  final int? intervalHours;
  final String? startTime;
  final int? intervalDays;
  final DateTime startDate;
  final DateTime? endDate;
}

/// ฟอร์มกรอกข้อมูลตารางยา ใช้ร่วมกันระหว่างหน้าเพิ่มตารางและแก้ไขตาราง
class ScheduleForm extends StatefulWidget {
  const ScheduleForm({
    super.key,
    this.initial,
    required this.onSubmit,
    required this.submitLabel,
    this.isSubmitting = false,
  });

  /// ตารางยาเดิม ถ้าเป็น null แสดงว่าเป็นการเพิ่มตารางใหม่
  final Schedule? initial;
  final ValueChanged<ScheduleFormValues> onSubmit;
  final String submitLabel;
  final bool isSubmitting;

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  late ScheduleFrequency _frequency;
  late List<int> _weekdays;
  late List<String> _times;
  late final TextEditingController _intervalHoursController;
  late final TextEditingController _intervalDaysController;
  TimeOfDay? _startTime;
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _frequency = initial?.frequency ?? ScheduleFrequency.daily;
    _weekdays = List<int>.from(initial?.weekdays ?? const []);
    _times = List<String>.from(initial?.times ?? const []);
    _intervalHoursController = TextEditingController(
      text: initial?.intervalHours?.toString() ?? '',
    );
    _intervalDaysController = TextEditingController(
      text: initial?.intervalDays?.toString() ?? '',
    );
    _startTime = initial?.startTime != null
        ? TimeOfDayFormatter.parse(initial!.startTime!)
        : null;
    _startDate = initial?.startDate ?? DateTime.now();
    _endDate = initial?.endDate;
  }

  @override
  void dispose() {
    _intervalHoursController.dispose();
    _intervalDaysController.dispose();
    super.dispose();
  }

  bool get _usesTimeList => _frequency != ScheduleFrequency.intervalHours;

  bool get _usesIntervalDays => _frequency == ScheduleFrequency.everyNDays;

  String? _validate() {
    if (_frequency == ScheduleFrequency.weekly && _weekdays.isEmpty) {
      return 'กรุณาเลือกวันในสัปดาห์อย่างน้อย 1 วัน';
    }
    if (_usesTimeList && _times.isEmpty) {
      return 'กรุณาเพิ่มเวลาทานยาอย่างน้อย 1 เวลา';
    }
    if (_usesIntervalDays) {
      final days = int.tryParse(_intervalDaysController.text.trim());
      if (days == null || days <= 0) {
        return 'กรุณากรอกจำนวนวันให้ถูกต้อง';
      }
    }
    if (!_usesTimeList) {
      if (_startTime == null) {
        return 'กรุณาเลือกเวลาทานมื้อแรก';
      }
      final hours = int.tryParse(_intervalHoursController.text.trim());
      if (hours == null || hours <= 0) {
        return 'กรุณากรอกจำนวนชั่วโมงให้ถูกต้อง';
      }
    }
    return null;
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  void _handleSubmit() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    widget.onSubmit(
      ScheduleFormValues(
        frequency: _frequency,
        weekdays: _frequency == ScheduleFrequency.weekly ? _weekdays : const [],
        times: _usesTimeList ? _times : const [],
        intervalHours: _usesTimeList
            ? null
            : int.parse(_intervalHoursController.text.trim()),
        startTime: _usesTimeList
            ? null
            : TimeOfDayFormatter.format(_startTime!),
        intervalDays: _usesIntervalDays
            ? int.parse(_intervalDaysController.text.trim())
            : null,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('รูปแบบการทานยา', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ScheduleFrequencySelector(
          value: _frequency,
          onChanged: (value) => setState(() => _frequency = value),
        ),
        const SizedBox(height: 20),
        if (_frequency == ScheduleFrequency.weekly) ...[
          Text('วันในสัปดาห์', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ScheduleWeekdaySelector(
            selected: _weekdays,
            onChanged: (value) => setState(() => _weekdays = value),
          ),
          const SizedBox(height: 20),
        ],
        if (_usesIntervalDays) ...[
          TextField(
            controller: _intervalDaysController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'ทานซ้ำทุกกี่วัน',
              hintText: 'เช่น 2 (วันเว้นวัน)',
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (_usesTimeList) ...[
          Text('เวลาทานยา', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ScheduleTimeListEditor(
            times: _times,
            onChanged: (value) => setState(() => _times = value),
          ),
        ] else ...[
          Text('เวลามื้อแรก', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _pickStartTime,
            child: Text(
              _startTime == null
                  ? 'เลือกเวลา'
                  : TimeOfDayFormatter.format(_startTime!),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _intervalHoursController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'ทานซ้ำทุกกี่ชั่วโมง',
              hintText: 'เช่น 6',
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text('ช่วงวันที่', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ScheduleDateRangeField(
          startDate: _startDate,
          endDate: _endDate,
          onStartDateChanged: (value) => setState(() => _startDate = value),
          onEndDateChanged: (value) => setState(() => _endDate = value),
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
    );
  }
}
