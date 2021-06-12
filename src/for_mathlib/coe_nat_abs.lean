import analysis.normed_space.basic

-- PRed in #7911

open_locale nnreal

lemma nnreal.coe_nat_abs (n : ℤ) : (n.nat_abs : ℝ≥0) = nnnorm n :=
nnreal.eq $
calc ((n.nat_abs : ℝ≥0) : ℝ)
    = ↑(n.nat_abs : ℤ) : by simp only [int.cast_coe_nat, nnreal.coe_nat_cast]
... = abs n            : by simp only [← int.abs_eq_nat_abs, int.cast_abs]
... = ∥n∥               : rfl
