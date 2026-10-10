/// Every named integer sequence in the system.
///
/// The [id] is the persisted key in counters.json. The Dart identifier
/// is free to be renamed without orphaning counters — only [id] is
/// load-bearing on disk.
enum CounterKey {
  invoice('invoice'),
  receipt('receipt'),
  item('item'),
  customer('customer'),
  business('business'),
  payment('payment');

  const CounterKey(this.id);

    /// Stable key written to storage. Never rename this.
  final String id;
}