use valuable::*;

#[derive(Default, Debug, PartialEq)]
pub struct VisitCount {
    pub visit_value: u32,
    pub visit_named_fields: u32,
    pub visit_unnamed_fields: u32,
    pub visit_variant_named_fields: u32,
    pub visit_variant_unnamed_fields: u32,
    pub visit_slice: u32,
    pub visit_entry: u32,
}

impl Visit for VisitCount {
    fn visit_value(&mut self, _: Value<'_>) {
        self.visit_value += 1;
    }

    fn visit_named_fields(&mut self, _: &NamedValues<'_>) {
        self.visit_named_fields += 1;
    }

    fn visit_unnamed_fields(&mut self, _: &[Value<'_>]) {
        self.visit_unnamed_fields += 1;
    }

    fn visit_variant_named_fields(&mut self, _: &Variant<'_>, _: &NamedValues<'_>) {
        self.visit_variant_named_fields += 1;
    }

    fn visit_variant_unnamed_fields(&mut self, _: &Variant<'_>, _: &[Value<'_>]) {
        self.visit_variant_unnamed_fields += 1;
    }

    fn visit_slice(&mut self, _: Slice<'_>) {
        self.visit_slice += 1;
    }

    fn visit_entry(&mut self, _: Value<'_>, _: Value<'_>) {
        self.visit_entry += 1;
    }
}