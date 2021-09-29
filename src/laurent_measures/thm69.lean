import category_theory.Fintype
import data.real.nnreal
import laurent_measures.basic
import topology.basic
import order.filter.at_top_bot
import analysis.special_functions.exp_log


noncomputable theory

open set real (log) finset filter
open_locale topological_space nnreal big_operators filter classical

namespace thm71

-- section surjectivity

-- parameter (x : ℝ≥0)
-- variables (y : ℝ≥0) --(N : ℕ)

-- def N : ℕ := ⌈(x⁻¹ : ℝ)⌉₊

-- lemma N_inv_le : x ≥ 1 / N := sorry


-- --The minimal integer such that the corresponding coefficient in the Laurent series for y is ≠ 0
-- def deg : ℤ := ⌊(log y) / (log x)⌋

-- lemma xpow_le : x ^ (deg y) ≤ y := sorry

-- lemma deg_is_min : ∀ k < deg y, x ^ k > y := sorry

-- def a (m : ℤ) := ⌊ (y / x ^ m : ℝ)⌋₊

-- lemma a_bdd : a y (deg y) < N  := sorry

-- lemma y_mul_xpow_le : ((a y (deg y) : ℝ≥0) * x ^ (deg y)) ≤ y := sorry

-- def z (m : ℤ) := y - (a y m) * x ^ m

-- /--Given the bound L (eventually L = deg y), `step m` is the pair whose first element is the
-- (m+L)-th coefficient
-- -/
-- def step (L : ℤ) (m : ℕ) : ℕ × ℝ≥0 := (a y (L + m), z y (L + m))

-- noncomputable def A : ℕ → ℕ × ℝ≥0
-- | 0         := step y (deg y) 0
-- | (m + 1)   := step (A m).2 (deg y) (m + 1)--let z' := (A m).2, c := n y + m + 1 in (a z' c, z z' c)

-- lemma deg_increasing (k : ℕ) : deg (A y (k + 1)).2 > deg (A y k).2 := sorry

-- def coeff : ℤ → ℕ := λ k, if k < deg y then 0 else (A y (k + deg y ).to_nat).1

-- lemma surj_on_nonneg : has_sum (λ k : ℤ, (coeff y k : ℝ≥0) * x ^ k ) y := sorry

-- end surjectivity


variables (ξ : ℝ) [fact (0 < ξ)] [fact (ξ < 1)]
variable (x : ℝ)

noncomputable def y : ℕ → ℝ
| 0         := x
| (n + 1)   := (y n) - (⌊(((y n) / ξ ^ n) : ℝ)⌋ : ℝ) * ξ ^ n


--[FAE] why I can't find this in mathlib?
lemma ge_of_div_le_one {a b : ℝ} (ha₁ : a ≥ 0) (hb₁ : b ≤ 1) (hb₂ : b > 0) : a ≤ a / b :=
begin
  by_cases ha : a > 0,
  { have that := (mul_le_mul_left ha).mpr ((one_le_div hb₂).mpr hb₁),
    rwa [← div_eq_mul_one_div, mul_one] at that },
  { simp only [gt_iff_lt, not_lt, ge_iff_le] at *,
    have : a = 0 := linarith.eq_of_not_lt_of_not_gt a 0 (not_lt_of_le ha₁) (not_lt_of_le ha),
    rw [this, zero_div] },
end

-- lemma eventually_le : ∀ n : ℕ, n ≥ 1 → (y ξ x n) ≤ ⌊(((y ξ x n) / ξ ^ n) : ℝ)⌋ :=
-- begin
--   intros n hn,
--   have h_pow : ξ ^ n ≤ 1, sorry,
--   -- have := (pow_lt_one_iff _).mpr (fact.out _) ξ,
--   -- have := (pow_lt_one_iff _).mpr
--   --   ((not_iff_not_of_iff (@nat.lt_one_iff n)).mp (not_lt_of_ge hn)),
--   -- -- sorry,
--   -- exact fact.out _,
--   calc y ξ x n ≤ (y ξ x n) / (ξ ^ n) : sorry--ge_of_div_le_one h_pow
--            ... ≤ ⌊(y ξ x n) / (ξ ^ n)⌋ : sorry,
-- end

section aux_lemmas

example (a b c : ℝ) : a < b + c ↔ a - b < c := sub_lt_iff_lt_add'.symm

lemma bdd_floor : bdd_above (range (λ n : ℕ, (⌊ y ξ x n / ξ ^ n⌋ : ℝ))) :=
begin
  use (max x ξ ⁻¹ : ℝ),
  intros z hz,
  obtain ⟨m, h_mz⟩ := (set.mem_range).mp hz,
    by_cases hm : m = 0,
  { rw [hm, pow_zero, div_one] at h_mz,
    rw [← h_mz, y, le_max_iff],
    apply or.intro_left,
    exact floor_le x },
  rw ← h_mz,
  apply (floor_le _).trans,
  obtain ⟨k, hk⟩ : ∃ k : ℕ, m = k + 1 := nat.exists_eq_succ_of_ne_zero hm,
  rw [hk, y],
  have : ξ ^ k ≠ 0 := ne_of_gt (pow_pos (fact.out _) k),
  calc (y ξ x k - ↑⌊y ξ x k / ξ ^ k⌋ * ξ ^ k) / ξ ^ (k + 1) =
              (y ξ x k - ↑⌊y ξ x k / ξ ^ k⌋ * ξ ^ k) / (ξ ^ k * ξ) : by {rw [pow_add, pow_one]}
        ... = (y ξ x k - ↑⌊y ξ x k / ξ ^ k⌋ * ξ ^ k) / ξ ^ k / ξ : by {field_simp}
        ... = (y ξ x k / ξ ^ k - ↑⌊y ξ x k / ξ ^ k⌋ * ξ ^ k / ξ ^ k) / ξ : by {rw [sub_div]}
        ... = (y ξ x k / ξ ^ k - ↑⌊y ξ x k / ξ ^ k⌋) / ξ : by {simp only [mul_div_cancel,
                                                                      this, ne.def, not_false_iff]}
        ... ≤ 1 / ξ : div_le_div_of_le (le_of_lt _) (le_of_lt _)
        ... ≤ max x ξ ⁻¹ : by {field_simp},
  exact fact.out _,
  {rw [sub_lt_iff_lt_add, add_comm], from (lt_floor_add_one _)},
end

lemma eventually_pos_y : ∀ n : ℕ, n ≥ 1 → y ξ x n ≥ 0 :=
begin
  have h_pos : ∀ n : ℕ, n ≥ 1 → ξ ^ n > 0 := λ n _, pow_pos (fact.out _) n,
  have : ∀ n : ℕ, n ≥ 1 →  (y ξ x n) / ξ ^ n ≥ ⌊(((y ξ x n) / ξ ^ n) : ℝ)⌋ := λ n _, floor_le _,
  intros n hn₁,
  by_cases hn₀ : n = 1,
  { rw [hn₀, y,pow_zero, div_one, mul_one, ge_iff_le, sub_nonneg], apply floor_le },
  { replace hn₁ : n > 1, {apply (lt_of_le_of_ne hn₁), tauto },
    obtain ⟨m, hm⟩ : ∃ m : ℕ, m ≥ 1 ∧ n = m + 1,
    use ⟨n - 1, and.intro (nat.le_pred_of_lt hn₁) (nat.sub_add_cancel (le_of_lt hn₁)).symm⟩,
    rw [hm.2, y],
    replace this := (le_div_iff (h_pos m hm.1)).mp (this m hm.1),
    rwa ← sub_nonneg at this },
end

lemma eventually_pos_floor : ∀ n : ℕ, n ≥ 1 → (⌊((y ξ x n) / ξ ^ n )⌋ : ℝ) ≥ 0 :=
begin
  have h_pos : ∀ n : ℕ, n ≥ 1 → ξ ^ n > 0 := λ n _, pow_pos (fact.out _) n,
  intros n hn,
  -- apply mul_nonneg _ (le_of_lt (h_pos n hn)),
  norm_cast,
  apply floor_nonneg.mpr,
  exact div_nonneg (eventually_pos_y ξ x n hn) (le_of_lt (h_pos n hn)),
end


lemma eventually_le : ∀ n, n ≥ 1 → y ξ x (n + 1) ≤ (y ξ x n) :=
begin
  have h_pos : ∀ n : ℕ, n ≥ 1 → ξ ^ n > 0 := λ n _, pow_pos (fact.out _) n,
  intros n hn,
  rw y,
  apply sub_le_self (y ξ x n),
  apply mul_nonneg _ (le_of_lt (h_pos n hn)),
  exact eventually_pos_floor ξ x n hn,
end

lemma eventually_le_one {n : ℕ} (hn : n ≥ 1) : (y ξ x n) ≤ (y ξ x 1) :=
begin
  induction hn with n hn h_ind,
  exact le_of_eq (refl _),
  have := (eventually_le ξ x n hn).trans h_ind,
  rwa nat.succ_eq_add_one,
end

def trunc_y : ℕ → ℝ := λ n, if n = 0 then y ξ x 1 else y ξ x n

lemma eventually_monotone : monotone (order_dual.to_dual ∘ (trunc_y ξ x)) :=
begin
  apply monotone_nat_of_le_succ,
  intro n,
  rw [order_dual.to_dual_le, order_dual.of_dual_to_dual],
  by_cases hn : n = 0,
  {rw [hn, zero_add, trunc_y],
    simp only [nat.one_ne_zero, if_true, eq_self_iff_true, if_false] },
  { simp only [trunc_y, if_neg hn, function.comp_app, nat.succ_ne_zero, if_false],
    replace hn : n ≥ 1 := le_of_not_gt ((not_iff_not.mpr nat.lt_one_iff).mpr hn),
    exact eventually_le ξ x n hn },
end

lemma limit_neg_geometric : tendsto (λ i : ℕ, - ξ ^ i) at_top (𝓝 0) :=
begin
  apply summable.tendsto_at_top_zero,
  rw summable_neg_iff,
  apply summable_geometric_of_abs_lt_1,
  rw abs_of_pos,
  all_goals {exact fact.out _},
end

end aux_lemmas

section summability

lemma finite_sum (n : ℕ) : (y ξ x (n + 1) : ℝ) =
  x - ∑ i in range(n + 1),  (⌊(((y ξ x i) / ξ ^ i) : ℝ)⌋ : ℝ) * (ξ ^ i) :=
begin
  induction n with n h_ind,
  { rw [zero_add, range_one, sum_singleton], refl },
  { replace h_ind : (x - (y ξ x (n + 1)) : ℝ) =
    ∑ i in range(n + 1),  (⌊(y ξ x i / ξ ^ i : ℝ)⌋ : ℝ) * ξ ^ i := by {rw [sub_eq_iff_eq_add,
      ← sub_eq_iff_eq_add', h_ind] },
    nth_rewrite_rhs 2 [nat.succ_eq_add_one, ← nat.succ_eq_add_one, range_succ],
    rw [sum_insert, nat.succ_eq_add_one, ← sub_sub, ← h_ind, sub_sub, add_sub, add_comm _ x,
      ← add_sub, ← sub_sub, sub_self, zero_sub, neg_sub],
    refl,
    simp },
end

lemma exists_limit_y : ∃ a, tendsto (λ n, y ξ x n) at_top (𝓝 a) :=
begin
  have h_bdd : bdd_below (range (trunc_y ξ x)),
  { use 0,
    intros z hz,
    obtain ⟨m, h_mz⟩ := (set.mem_range).mp hz,
    by_cases hm : m = 0,
    { simp_rw [hm, trunc_y, if_pos] at h_mz,
      rw ← h_mz,
      exact eventually_pos_y ξ x 1 (le_of_eq (refl _)), },
      simp_rw [trunc_y, (if_neg hm)] at h_mz,
      rw ← h_mz,
      replace hm : m ≥ 1 := le_of_not_gt ((not_iff_not.mpr nat.lt_one_iff).mpr hm),
      exact eventually_pos_y ξ x m hm },
  have := tendsto_at_top_cinfi (eventually_monotone ξ x) h_bdd,
  use (⨅ (i : ℕ), trunc_y ξ x i),
  apply @tendsto.congr' _ _ (trunc_y ξ x) _ _ _ _ this,
  apply (filter.eventually_eq_iff_exists_mem).mpr,
  use {n | n ≥ 1},
  simp only [mem_at_top_sets, ge_iff_le, mem_set_of_eq],
  use 1,
  simp only [imp_self, forall_const],
  intros n hn,
  replace hn : n ≥ 1 := by {simp only [*, ge_iff_le, mem_set_of_eq] at * },
  have := ne_of_lt (lt_of_lt_of_le nat.zero_lt_one hn),
  rw [trunc_y, ite_eq_right_iff],
  tauto,
end

lemma summable_floor (r : ℝ) (hr₀ : 0 < r) (hr₁ : r < 1) :
   summable (λ i, (⌊(y ξ x i / ξ ^ i : ℝ)⌋ : ℝ) * r ^ i) :=
begin
  have h_pos : ∀ n : ℕ, n ≥ 1 → r ^ n > 0 := λ n _, pow_pos (hr₀) n,
  have H : ∀ j : {i // i ∉ range 1}, j.1 ≥ 1,
  { rintro ⟨n, h_n⟩,
    simp only [ge_iff_le, finset.mem_singleton, range_one] at h_n,
    exact le_of_not_gt ((not_iff_not.mpr nat.lt_one_iff).mpr h_n) },
  apply (finset.summable_compl_iff (finset.range 1)).mp,
  swap, apply_instance,
  have h_nonneg : ∀ i : {i // i ∉ range 1}, (⌊(y ξ x i.1 / ξ ^ i.1 : ℝ)⌋ : ℝ) * r ^ i.1 ≥ 0,
  { intro i,
    apply mul_nonneg _ (le_of_lt (h_pos i.1 (H i))),
    exact (eventually_pos_floor ξ x i.1 (H i)) },
  obtain ⟨μ, hμ⟩  := bdd_floor ξ x,
  have h_bdd : ∀ i : {i // i ∉ range 1}, (⌊(y ξ x i.1 / ξ ^ i.1 : ℝ)⌋ : ℝ) ≤ μ,
  { rw upper_bounds at hμ,
    simp only [*, forall_apply_eq_imp_iff', set.mem_range, forall_exists_index, mem_set_of_eq,
      implies_true_iff] at * },
  replace h_bdd : ∀ i : {i // i ∉ range 1}, (⌊(y ξ x i.1 / ξ ^ i.1 : ℝ)⌋ : ℝ) * r ^ i.1
      ≤ μ * r ^ i.1,
  { intro i,
    rw mul_le_mul_right,
    exacts [h_bdd i, pow_pos hr₀ i.1] },
  apply summable_of_nonneg_of_le h_nonneg h_bdd,
  apply (@finset.summable_compl_iff _ _ _ _ _ (λ i, μ * r ^ i) (finset.range 1)).mpr,
  apply summable.mul_left,
  apply summable_geometric_of_abs_lt_1,
  rwa [abs_eq_self.mpr (le_of_lt hr₀)],
end


lemma limit_y (h_pos : 0 < ξ) (h_small : ξ < 1)
  : tendsto (λ n, y ξ x n) at_top (𝓝 0) :=
begin
  have h_right : ∀ n, n ≥ 1 → (⌊(y ξ x n / ξ ^ n)⌋ : ℝ) ≤ (y ξ x n / ξ ^ n) := (λ _ _, floor_le _),
  replace h_right : ∀ n, n ≥ 1 → (⌊(y ξ x n / ξ ^ n)⌋ : ℝ) * ξ ^ n  ≤ y ξ x n :=
    (λ n hn, (le_div_iff (pow_pos h_pos n)).mp (h_right n hn)),
  replace h_right : ∀ᶠ n in at_top, (⌊(y ξ x n / ξ ^ n)⌋ : ℝ) * ξ ^ n  ≤ y ξ x n,
  { simp only [ge_iff_le, eventually_at_top], use [1, h_right] },
  have h_left : ∀ n, n ≥ 1 → (y ξ x n / ξ ^ n) - 1 ≤ ⌊(y ξ x n / ξ ^ n)⌋ :=
    (λ n hn, le_of_lt (sub_one_lt_floor _)),
  replace h_left : ∀ n, n ≥ 1 → (y ξ x n - ξ ^ n) ≤ ⌊(y ξ x n / ξ ^ n)⌋ * ξ ^ n,
  { have h_one : ∀ n : ℕ, 0 < ξ ^ n := (λ n, pow_pos h_pos n),
    intros n hn,
    calc y ξ x n -  ξ ^ n = (y ξ x n * ξ ^ n / ξ ^ n  - ξ ^ n) :
                                                by {rw [mul_div_cancel _ (ne_of_lt (h_one n)).symm]}
                    ... = (y ξ x n / ξ ^ n * ξ ^ n  - ξ ^ n) :
                                                  by {rw [mul_div_assoc, ← div_mul_eq_mul_div_comm]}
                    ... = ((y ξ x n / ξ ^ n) - 1 ) * ξ ^ n :
                                            by {nth_rewrite_lhs 2 [← one_mul (ξ ^ n)], rw ← sub_mul}
                    ... ≤ ⌊(y ξ x n / ξ ^ n)⌋ * ξ ^ n :
                                                  (mul_le_mul_right (h_one n)).mpr (h_left n hn) },
  replace h_left : ∀ᶠ n in at_top, y ξ x n - ξ ^ n ≤ (⌊(y ξ x n / ξ ^ n)⌋ : ℝ) * ξ ^ n,
  { simp only [eventually_at_top], use [1, h_left] },
  have : tendsto (λ n, y ξ x n - ξ ^ n) at_top (𝓝 (exists_limit_y ξ x).some),
  { convert tendsto.add (exists_limit_y ξ x).some_spec (limit_neg_geometric ξ),
    rw add_zero } ,
  have h₁ := (le_of_tendsto_of_tendsto this
    (summable_floor ξ x ξ _ _).tendsto_at_top_zero h_left).antisymm (le_of_tendsto_of_tendsto
    (summable_floor ξ x ξ _ _).tendsto_at_top_zero (exists_limit_y ξ x).some_spec h_right),
  have := (exists_limit_y ξ x).some_spec,
  rwa h₁ at this,
  all_goals {exact (fact.out _)},
end



end summability


end thm71
