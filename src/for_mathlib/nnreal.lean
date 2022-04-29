import data.real.nnreal
import analysis.mean_inequalities_pow
import for_mathlib.ennreal

open_locale nnreal

-- There doesn't seem to be a real analogue of this one, but probably should be?
lemma nnreal.div_le_div_left_of {a b c : ℝ≥0} (w : 0 < c) (h : c ≤ b) : a / b ≤ a / c :=
begin
  rcases a with ⟨a, a_pos⟩,
  rcases b with ⟨b, b_pos⟩,
  rcases c with ⟨c, c_pos⟩,
  change a / b ≤ a / c,
  change 0 < c at w,
  change c ≤ b at h,
  by_cases p : 0 < a,
  { rw div_le_div_left p (lt_of_lt_of_le w h) w,
    exact h, },
  { have q : a = 0, linarith,
    subst q,
    simp, }
end

attribute [norm_cast] nnreal.coe_zpow

open_locale ennreal big_operators

/-- sum of row sums equals sum of column sums -/
lemma nnreal.summable_symm {α β: Type*} (F : α → β → ℝ≥0)
  (h_rows : ∀ n, summable (λ k, F n k)) (h_cols : ∀ k, summable (λ n, F n k))
  (h_col_row : summable (λ k, ∑' n, F n k)) : summable (λ n, ∑' k, F n k) :=
begin
  cases h_col_row with a ha,
  use a,
  rw ← ennreal.has_sum_coe,
  convert_to has_sum (λ n, ∑' k, (F n k : ℝ≥0∞)) a,
  { ext1 n,
    exact ennreal.coe_tsum (h_rows n) },
  { rw ennreal.has_sum_comm,
    rw ← ennreal.has_sum_coe at ha,
    convert ha,
    ext1 k,
    exact (ennreal.coe_tsum (h_cols k)).symm },
end

open nnreal

lemma nnreal.summable_of_comp_injective {α β : Type*} {f : α → ℝ≥0} {i : β → α}
  (hi : function.injective i) (hi' : ∀ a, a ∉ set.range i → f a = 0) (hfi : summable (f ∘ i)) :
  summable f :=
begin
  rw ← summable_coe at hfi ⊢,
  let e : β ≃ ({x : α | x ∈ set.range i} : set α) :=
  { to_fun := λ b, ⟨i b, b, rfl⟩,
  inv_fun := λ x, x.2.some,
  left_inv := begin intro b, simp, apply hi, exact Exists.some_spec (⟨b, rfl⟩ : ∃ y, i y = i b) end,
  right_inv := begin rintro ⟨x, b, rfl⟩, simp, exact Exists.some_spec (⟨b, rfl⟩ : ∃ y, i y = i b) end },
  have this2 : summable ((λ (x : {x : α // x ∈ set.range i}), (f x.1 : ℝ)) ∘ ⇑e : β → ℝ),
  { convert (summable_congr _).1 hfi,
    intro b, refl },
  rw e.summable_iff at this2,
  change summable ((λ a, (f a : ℝ)) ∘ (coe : {x // x ∈ set.range i} → α)) at this2,
  rw ← this2.summable_compl_iff,
  convert summable_zero,
  ext1 ⟨x, hx⟩,
  simp [hi' x hx],
end

lemma nnreal.mul_le_mul_right {a b : ℝ≥0} (h : a ≤ b) (c : ℝ≥0) : a * c ≤ b * c :=
begin
  suffices : (a : ℝ) * c ≤ b * c, by assumption_mod_cast,
  apply mul_le_mul_of_nonneg_right (by assumption_mod_cast),
  apply zero_le',
end

lemma nnreal.rpow_sum_le_sum_rpow
  {ι : Type*} (s : finset ι) {p : ℝ} (a : ι → ℝ≥0) (hp_pos : 0 < p) (hp1 : p ≤ 1) :
  (∑ i in s, a i) ^ p ≤ ∑ i in s, (a i ^ p) :=
begin
  classical,
  induction s using finset.induction_on with i s his IH,
  { simp only [nnreal.zero_rpow hp_pos.ne', finset.sum_empty, le_zero_iff], },
  { simp only [his, finset.sum_insert, not_false_iff],
    exact (nnreal.rpow_add_le_add_rpow _ _ hp_pos hp1).trans (add_le_add le_rfl IH), }
end
