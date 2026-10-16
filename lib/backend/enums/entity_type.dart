enum EntityType {
  business('BUS'),
  customer('CUS'),
  item('ITM'),
  payment('PAY'),
  receipt('REC');

  const EntityType(this.label);
  final String label;
}
