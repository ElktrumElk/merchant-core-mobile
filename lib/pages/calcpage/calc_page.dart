import 'package:flutter/material.dart';

// ──────────────────────────────────────────────
// Currency rates (relative to 1 SLE)
// ──────────────────────────────────────────────
const Map<String, double> _rates = {
  'SLE': 1.0,
  'USD': 0.044,
  'EUR': 0.040,
  'GBP': 0.034,
  'NGN': 58.0,
  'GHS': 0.54,
  'KES': 5.65,
  'ZAR': 0.80,
  'CNY': 0.32,
  'JPY': 6.80,
};

const List<String> _currencies = [
  'SLE', 'USD', 'EUR', 'GBP', 'NGN',
  'GHS', 'KES', 'ZAR', 'CNY', 'JPY',
];

class CalcPage extends StatefulWidget {
  const CalcPage({super.key});

  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage>
    with TickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabCtrl,
            indicator: BoxDecoration(
              color: const Color(0xFF000102),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: const Color(0xFF4793FF),
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            dividerColor: Colors.transparent,
            splashBorderRadius: BorderRadius.circular(12),
            tabs: const [
              Tab(text: 'Basic'),
              Tab(text: 'Business'),
              Tab(text: 'Currency'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: const [
              _BasicCalc(),
              _BusinessCalc(),
              _CurrencyConverter(),
            ],
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════
//  BASIC CALCULATOR
// ══════════════════════════════════════════════

enum _Op { none, add, sub, mul, div }

class _BasicCalc extends StatefulWidget {
  const _BasicCalc();
  @override
  State<_BasicCalc> createState() => _BasicCalcState();
}

class _BasicCalcState extends State<_BasicCalc> {
  String _display = '0';
  double _lhs = 0;
  _Op _op = _Op.none;
  bool _fresh = true;
  bool _hasDecimal = false;

  void _input(String digit) {
    setState(() {
      if (_fresh) { _display = ''; _fresh = false; _hasDecimal = false; }
      if (digit == '.' && _hasDecimal) return;
      if (digit == '.') _hasDecimal = true;
      if (_display == '0' && digit != '.') {
        _display = digit;
      } else {
        _display += digit;
      }
    });
  }

  void _setOp(_Op newOp) {
    setState(() {
      _lhs = double.tryParse(_display) ?? 0;
      _op = newOp;
      _fresh = true;
    });
  }

  void _equals() {
    final rhs = double.tryParse(_display) ?? 0;
    double result;
    switch (_op) {
      case _Op.add: result = _lhs + rhs; break;
      case _Op.sub: result = _lhs - rhs; break;
      case _Op.mul: result = _lhs * rhs; break;
      case _Op.div:
        result = rhs == 0 ? double.nan : _lhs / rhs;
        break;
      case _Op.none: result = rhs; break;
    }
    setState(() {
      _display = result.isNaN || result.isInfinite
          ? 'Error' : result == result.roundToDouble()
          ? result.toInt().toString() : result.toStringAsFixed(2);
      _op = _Op.none;
      _fresh = true;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _lhs = 0;
      _op = _Op.none;
      _fresh = true;
      _hasDecimal = false;
    });
  }

  void _backspace() {
    setState(() {
      if (_display.length > 1) {
        if (_display.endsWith('.')) _hasDecimal = false;
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
        _fresh = true;
      }
    });
  }

  Widget _btn(String label, Color bg, Color fg, {double flex = 1}) {
    return Expanded(
      flex: flex ~/ 1,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (label == 'C') {
                _clear();
              } else if (label == '⌫') {
                _backspace();
              } else if (label == '=') {
                _equals();
              } else if (label == '+') {
                _setOp(_Op.add);
              } else if (label == '−') {
                _setOp(_Op.sub);
              } else if (label == '×') {
                _setOp(_Op.mul);
              } else if (label == '÷') {
                _setOp(_Op.div);
              } else {
                _input(label);
              }
            },
            child: Center(
              child: Text(label,
                style: TextStyle(fontSize: 22, color: fg, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final numBg = isDark ? Colors.grey.shade700 : Colors.grey.shade200;
    final opBg = Colors.black;
    final eqBg = Colors.black;
    final fg = isDark ? Colors.white : Colors.black87;

    return Column(children: [

      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(_display,
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300,
              color: theme.colorScheme.onSurface)),
      ),
      const SizedBox(height: 12),
      Expanded(

        child: Column(children: [
          Row(children: [
            _btn('C', Colors.red.shade400, Colors.white),
            _btn('⌫', numBg, fg),
            _btn('÷', opBg, Colors.white),
          ]),
          const SizedBox(height: 20,),
          Row(children: [
            _btn('7', numBg, fg),
            _btn('8', numBg, fg),
            _btn('9', numBg, fg),
            _btn('×', opBg, Colors.white),
          ]),
          const SizedBox(height: 10,),

          Row(children: [
            _btn('4', numBg, fg),
            _btn('5', numBg, fg),
            _btn('6', numBg, fg),
            _btn('−', opBg, Colors.white),
          ]),
          const SizedBox(height: 10,),
          Row(children: [
            _btn('1', numBg, fg),
            _btn('2', numBg, fg),
            _btn('3', numBg, fg),
            _btn('+', opBg, Colors.white),
          ]),

          const SizedBox(height: 10,),
          Row(children: [
            _btn('0', numBg, fg, flex: 2),
            _btn('.', numBg, fg),
            _btn('=', eqBg, Colors.white),
          ]),
        ]),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════
//  BUSINESS CALCULATOR
// ══════════════════════════════════════════════

enum _BizMode { margin, roi, markup, breakeven }

class _BusinessCalc extends StatefulWidget {
  const _BusinessCalc();
  @override
  State<_BusinessCalc> createState() => _BusinessCalcState();
}

class _BusinessCalcState extends State<_BusinessCalc> {
  _BizMode _mode = _BizMode.margin;

  final _costCtrl = TextEditingController();
  final _revenueCtrl = TextEditingController();
  String _result = '';

  @override
  void dispose() {
    _costCtrl.dispose();
    _revenueCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final cost = double.tryParse(_costCtrl.text);
    final rev = double.tryParse(_revenueCtrl.text);
    if (cost == null || rev == null || cost <= 0 || rev <= 0) {
      setState(() => _result = 'Enter valid positive numbers');
      return;
    }

    setState(() {
      switch (_mode) {
        case _BizMode.margin:
          final margin = ((rev - cost) / rev * 100);
          final profit = rev - cost;
          _result = 'Profit: SLE ${profit.toStringAsFixed(2)}\n'
              'Margin: ${margin.toStringAsFixed(2)}%';
        case _BizMode.roi:
          final roi = ((rev - cost) / cost * 100);
          _result = 'ROI: ${roi.toStringAsFixed(2)}%';
        case _BizMode.markup:
          final markup = ((rev - cost) / cost * 100);
          _result = 'Markup: ${markup.toStringAsFixed(2)}%';
        case _BizMode.breakeven:
          final cm = rev - cost;
          if (cm <= 0) {
            _result = 'Contribution margin must be > 0';
          } else {
            _result = 'Break-even is reached when\ntotal units sold cover fixed costs.';
          }
      }
    });
  }

  Widget _modeChip(_BizMode m, String label, IconData icon) {
    final sel = _mode == m;
    return GestureDetector(
      onTap: () => setState(() { _mode = m; _result = ''; _costCtrl.clear(); _revenueCtrl.clear(); }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? const Color(0xFF1565C0) : Colors.grey.shade400),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: sel ? Colors.white : Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: sel ? Colors.white : Colors.grey)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String label1, label2;
    switch (_mode) {
      case _BizMode.margin:
        label1 = 'Cost Price'; label2 = 'Selling Price';
      case _BizMode.roi:
        label1 = 'Investment'; label2 = 'Return';
      case _BizMode.markup:
        label1 = 'Cost Price'; label2 = 'Selling Price';
      case _BizMode.breakeven:
        label1 = 'Fixed Costs'; label2 = 'Contribution per Unit';
    }

    return ListView(children: [
      Wrap(
        spacing: 8, runSpacing: 8,

        children: [
          _modeChip(_BizMode.margin, 'Margin', Icons.trending_up),
          _modeChip(_BizMode.roi, 'ROI', Icons.analytics),
          _modeChip(_BizMode.markup, 'Markup', Icons.add_chart),
          _modeChip(_BizMode.breakeven, 'Break-even', Icons.balance),
        ],
      ),
      const SizedBox(height: 20),
      _buildField(theme, label1, _costCtrl),
      const SizedBox(height: 12),
      _buildField(theme, label2, _revenueCtrl),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity, height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _calculate,
          child: const Text('Calculate', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
      if (_result.isNotEmpty) ...[
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(_result,
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface)),
        ),
      ],
    ]);
  }
}

// ══════════════════════════════════════════════
//  CURRENCY CONVERTER
// ══════════════════════════════════════════════

class _CurrencyConverter extends StatefulWidget {
  const _CurrencyConverter();
  @override
  State<_CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<_CurrencyConverter> {
  final _amountCtrl = TextEditingController(text: '1');
  String _from = 'SLE';
  String _to = 'USD';
  String _result = '';

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _convert() {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      setState(() => _result = 'Enter a valid amount');
      return;
    }
    final inBase = amount / _rates[_from]!;
    final converted = inBase * _rates[_to]!;
    setState(() {
      _result = '$amount $_from = ${converted.toStringAsFixed(2)} $_to';
    });
  }

  void _swap() {
    setState(() {
      final t = _from; _from = _to; _to = t;
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardColor;

    Widget dropdown(String val, ValueChanged<String?> onChanged) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: val,
            dropdownColor: cardBg,
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
            items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: onChanged,
          ),
        ),
      );
    }

    return ListView(children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg, borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          _buildField(theme, 'Amount', _amountCtrl),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: dropdown(_from, (v) => setState(() { _from = v!; _result = ''; }))),
            IconButton(onPressed: _swap, icon: const Icon(Icons.swap_horiz, color: Color(0xFF1565C0))),
            Expanded(child: dropdown(_to, (v) => setState(() { _to = v!; _result = ''; }))),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _convert,
              child: const Text('Convert', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ]),
      ),
      if (_result.isNotEmpty) ...[
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg, borderRadius: BorderRadius.circular(14),
          ),
          child: Text(_result,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        ),
      ],
    ]);
  }
}

// ──────────────────────────────────────────────
//  SHARED FIELD
// ──────────────────────────────────────────────

Widget _buildField(ThemeData theme, String label, TextEditingController ctrl) {
  return TextFormField(
    controller: ctrl,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    style: TextStyle(color: theme.colorScheme.onSurface),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: theme.brightness == Brightness.dark
          ? Colors.grey.shade800 : Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
      ),
    ),
  );
}
