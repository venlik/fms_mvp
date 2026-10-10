enum EntityType {
  business('BUS'),
  customer('CUS'),
  item('ITM'),
  payment('PAY');

  const EntityType(this.label);
  final String label;
}