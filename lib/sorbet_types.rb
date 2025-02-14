# frozen_string_literal: true
# typed: strong

StringArray      = T.type_alias { T::Array[String] }
StringArrayArray = T.type_alias { T::Array[StringArray] }
StringsFromFile  = T.type_alias { StringArray }
SymOrString      = T.type_alias { T.any(Symbol, String) }
