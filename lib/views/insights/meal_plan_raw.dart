/// One meal in the weekly plan, in compact form.
///
/// [ing] is "name|qty;name|qty;..." (parsed by meal_plan_data.dart).
class RawMeal {
  final String name;
  final String blurb;
  final int kcal;
  final int p; // protein g
  final int c; // carbs g
  final int f; // fat g
  final String tag;
  final String ing;
  const RawMeal(
    this.name,
    this.blurb,
    this.kcal,
    this.p,
    this.c,
    this.f,
    this.tag,
    this.ing,
  );
}
