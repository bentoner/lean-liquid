import analysis.normed_space.basic

/-!
#  The typeclass `nnnorm_add_class α`

In this file, we introduce the typeclass `nnnorm_add_class α`.

Let `α` be a type with a non-negative norm `∥_∥₊`, a zero `0`, an addition `+` and a negation `-`.

The typeclass `nnnorm_add_class α` requires to prove the identities:
* the nnnorm of `0` is `0` : `∥0∥₊ = 0`;
* the nnnorm of `-x` is equal to the nnnorm of `x`: `∥- x∥₊ = ∥x∥₊`;
* the nnnorm of a sum is at most the sum of the nnnorms: `∥x + y∥₊ ≤ ∥x∥₊ + ∥y∥₊`.
-/

open_locale nnreal

variables (α : Type*) [has_nnnorm α]

/--  A typeclass for an additive monoid `α` with a nnnorm.
Its fields `nnn_zero, nnn_neg, nnn_add_le` assert that
* `∥0∥₊ = 0`;
* `∥- x∥₊ = ∥x∥₊`;
* `∥x + y∥₊ ≤ ∥x∥₊ + ∥y∥₊`.

The class only assumes that `α` has `0, +, -`. -/
class nnnorm_add_class [has_zero α] [has_add α] [has_neg α] : Prop :=
(nnn_zero   : ∥(0 : α)∥₊ = 0)
(nnn_neg    : ∀ ⦃x : α⦄, ∥- x∥₊ = ∥x∥₊)
(nnn_add_le : ∀ ⦃x y : α⦄, ∥x + y∥₊ ≤ ∥x∥₊ + ∥y∥₊)

namespace nnnorm_add_class
variables {α}

section def_lemmas
variables [has_zero α] [has_add α] [has_neg α] [nnnorm_add_class α]

@[simp] lemma nnnorm_zero : ∥(0 : α)∥₊ = 0 := nnn_zero

@[simp] lemma nnnorm_neg (x : α) : ∥- x∥₊ = ∥x∥₊ :=
by apply nnn_neg

lemma nnnorm_add_le (x y : α) : ∥x + y∥₊ ≤ ∥x∥₊ + ∥y∥₊ :=
by apply nnn_add_le

end def_lemmas

variables [add_group α] [nnnorm_add_class α]

lemma nnnorm_sub (x y : α) : ∥x - y∥₊ = ∥y - x∥₊ :=
(nnnorm_neg _).symm.trans (congr_arg _ (neg_sub _ _))

lemma nnnorm_triangle (x y z : α) : ∥x - z∥₊ ≤ ∥x - y∥₊ + ∥y - z∥₊ :=
(le_of_eq (by simp only [sub_add_sub_cancel])).trans (nnnorm_add_le _ _)

end nnnorm_add_class
