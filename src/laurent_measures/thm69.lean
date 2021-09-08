import category_theory.Fintype
import data.real.nnreal
import laurent_measures.basic
import order.filter.at_top_bot

/-
We define the map θ : (laurent_measures r `singleton`) → ℝ and we show it is surjective.
TO DO :
* Prove `lemma has_sum_pow_floor` and deduce `lemma has_sum_pow_floor_norm` from it
* Upgrade θ to a `comp_haus_blah` morphism
* Finish the proof of surjectivity for negative reals using linearity
-/

open filter function classical
open_locale topological_space classical nnreal

section thm69_surjective

lemma converges_floor_nat (x : ℝ≥0) (r' : ℝ≥0) [fact (r' < 1)] :
  tendsto (λn : ℕ, (nat_floor (2 ^ n * x.1 ) * r' ^ n : ℝ≥0)) at_top (𝓝 x) := sorry

lemma converges_floor (x : ℝ≥0) :
  tendsto (λn : ℕ, (floor (2 ^ n * x : ℝ) / (2 ^ n) : ℝ)) at_top (𝓝 x) :=
begin
  have two_pow_pos : ∀ n : ℕ,  0 < (2 ^ n : ℝ) := by simp only
    [forall_const, zero_lt_bit0, pow_pos, zero_lt_one],
  have h₁ : ∀ n : ℕ, (x.1 - 1 / 2 ^ n) ≤ (floor (2 ^ n * x : ℝ) / (2 ^ n) : ℝ),
  { intro n,
    have := (div_le_div_right $ two_pow_pos n).mpr (le_of_lt (sub_one_lt_floor (2 ^ n * x.1))),
    calc (x.1 - 1 / 2 ^ n) = ( 2 ^ n * x.1 - 1)/ 2 ^ n : by field_simp[mul_comm]
                       ... ≤ (floor (2 ^ n * x.1) / (2 ^ n)) : this },
  have HH : tendsto (λn : ℕ, (x.1 - 1 / 2 ^ n)) at_top (𝓝 x),
  { suffices : tendsto (λn : ℕ, (1 / 2 ^ n : ℝ)) at_top (𝓝 0),
    { have h_geom := tendsto.mul_const (-1 : ℝ) this,
      replace h_geom := tendsto.const_add x.1 h_geom,
      simp_rw [pi.add_apply, zero_mul, add_zero, mul_neg_one] at h_geom,
      exact h_geom },
    have abs_half : abs ((1:ℝ)/2) < 1 := by {rw [abs_div, abs_one, abs_two], exact one_half_lt_one},
    have mah := tendsto_pow_at_top_nhds_0_of_abs_lt_1 (abs_half),
    simp_rw [← one_div_pow],
    exact mah },
  have h₂ : ∀ n : ℕ, ((floor (2 ^ n * x.1) ) / (2 ^ n) : ℝ) ≤ x.1,
  { intro n,
    have := (div_le_div_right $ two_pow_pos n).mpr (floor_le (2 ^ n * x.1)),
    calc (floor (2 ^ n * x.1) / 2 ^ n : ℝ)  ≤ (2 ^ n * x.1 / 2 ^ n) : this
                                        ... = (x.1 * 2 ^ n / 2 ^ n) : by simp only [mul_comm]
                                        ... = x.1 : by simp only [mul_div_cancel_of_invertible] },
  apply tendsto_of_tendsto_of_tendsto_of_le_of_le HH tendsto_const_nhds h₁ h₂,
end

noncomputable def floor_seq (x : ℝ≥0): ℤ → ℤ
| (int.of_nat n)          := nat.rec_on n
                          (floor x.1) (λ n, floor (2 ^ n * x.1) - 2 * floor (2 ^ (n-1) * x.1))
| (int.neg_succ_of_nat n) := 0

noncomputable  def floor_seq_nat (x : ℝ≥0): ℤ → ℕ
| (int.of_nat n)          := nat.rec_on n
                          (nat_floor x.1) (λ n, nat_floor (2 ^ n * x.1) - 2 * nat_floor (2 ^ (n-1) * x.1))
| (int.neg_succ_of_nat n) := 0

-- example : summable (λ (n : ℤ), (φ n) * (1 / 2) ^ n) :=
-- begin
--   have hinj : function.injective (coe : ℕ → ℤ) := by {apply int.coe_nat_inj},
--   have hφ : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → φ n = 0,
--   { rintros n hn,
--     induction n with n,
--     { simp only [set.mem_range_self, not_true, int.of_nat_eq_coe] at hn, tauto },
--     refl },
--   replace hφ : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → φ n * (1 / 2) ^ n = 0,
--   { intros n hn,
--     specialize hφ n hn,
--     rw [hφ, zero_mul] },
--   apply (function.injective.summable_iff hinj hφ).mp,
--   have H : (λ (n : ℤ), φ n * (1 / 2) ^ n) ∘ coe = λ (n : ℕ), (1 / 2) ^ n,
--   funext a,
--   simp only [function.comp_app, gpow_coe_nat],
--   suffices : φ a = 1,
--   rw [this, one_mul],
--   refl,
--   rw H,
--   exact summable_geometric_two,
-- end

lemma has_sum_pow_floor_nat (r' : ℝ≥0) [fact (r' < 1)] (x : ℝ≥0) :
  has_sum (λ n, (coe ∘ floor_seq_nat x) n * r' ^ n) x :=
begin
  have hinj : function.injective (coe : ℕ → ℤ) := by {apply int.coe_nat_inj},
  have h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → floor_seq_nat x n = 0, sorry,
  replace h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → (coe ∘ floor_seq_nat x) n * r' ^ n = 0,
  sorry,
  apply (@function.injective.has_sum_iff _ _ _ _ _ _ x _ hinj h_range).mp,
  have H : (λ (n : ℤ), (coe ∘ floor_seq_nat x) n * r' ^ n) ∘ coe =
    (λ (n : ℕ), (coe ∘ floor_seq_nat x) n * r' ^ n), sorry,
  rw H,
  apply (nnreal.has_sum_iff_tendsto_nat).mpr,
  have h_calc : ∀ n : ℕ,
  (finset.range n).sum (λ (i : ℕ), (coe ∘ floor_seq_nat x) ↑i * r' ^ i) =
    nat_floor (2 ^ n * x.1) * r' ^ n, sorry,
  simp_rw h_calc,
  apply (converges_floor_nat x r'),
end

lemma has_sum_pow_floor (r' : ℝ≥0) [fact (r' < 1)] (x : ℝ≥0) :
  has_sum (λ n, (coe ∘ floor_seq x) n * r'.1 ^ n) x :=
begin
  -- apply (has_sum_iff_tendsto_nat_of_nonneg).mp,
  have hinj : function.injective (coe : ℕ → ℤ) := by {apply int.coe_nat_inj},
  have h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → floor_seq x n = 0, sorry,
  replace h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → (coe ∘ floor_seq x) n * r'.1 ^ n = 0,
  sorry,
  apply (@function.injective.has_sum_iff _ _ _ _ _ _ x.1 _ hinj h_range).mp,
  have H : (λ (n : ℤ), (coe ∘ floor_seq x) n * r'.val ^ n) ∘ coe =
    (λ (n : ℕ), (coe ∘ floor_seq x) n * r'.val ^ n), sorry,
  rw H,
  sorry,
  -- apply (nnreal.has_sum_iff_tendsto_nat).mpr,
--   funext a,
--   simp only [function.comp_app, gpow_coe_nat],
--   suffices : φ a = 1,
--   rw [this, one_mul],
--   refl,
--   rw H,
  -- dsimp [has_sum],
  -- apply summable.has_sum_iff_tendsto_nat,
end

lemma has_sum_pow_floor_norm (r : ℝ≥0)  [fact (r < 1)] (x : ℝ≥0) :
  has_sum (λ n, ∥ ((coe : ℤ → ℝ) ∘ floor_seq x) n ∥ * r ^ n) x.1:=
begin
  sorry,--will be an easy consequence of the previous one
end

lemma has_sum_pow_floor_norm_nat (r : ℝ≥0)  [fact (r < 1)] (x : ℝ≥0) :
  has_sum (λ n, ∥ ((coe : ℕ → ℝ) ∘ floor_seq_nat x) n ∥ * r ^ n) x.1:=
begin
  sorry,--will be an easy consequence of the previous one
end

def laurent_measures.to_Rfct (r : ℝ≥0) [fact (r < 1)] :
  (laurent_measures r (Fintype.of punit)) → (ℤ → ℝ) := λ ⟨F, _⟩, coe ∘ (F punit.star)

noncomputable def θ (r' : ℝ≥0) [fact (r' < 1)] (r : ℝ≥0) [fact (r < 1)] :
 (laurent_measures r (Fintype.of punit)) → ℝ := λ F, tsum (λ n, (F.to_Rfct r n) * (r'.1) ^ n)

lemma θ_surj_on_nonneg (r' : ℝ≥0) [fact (r' < 1)] (r : ℝ≥0) [fact (r < 1)] (x : ℝ≥0) :
  ∃ (F : laurent_measures r (Fintype.of punit)), (θ r' r F) = x :=
begin
  let F₀ : Fintype.of punit → ℤ → ℤ := λ a, (floor_seq x),
  have Hr : ∀ (s : Fintype.of punit), summable (λ (n : ℤ), ∥F₀ s n∥ * ↑r ^ n),
  { intro s,
    apply has_sum.summable (has_sum_pow_floor_norm r x) },
  let F : laurent_measures r (Fintype.of punit) := ⟨F₀, Hr⟩,
  use F,
  have : summable (λ (n : ℤ), (F.to_Rfct r n) * (r'.1) ^ n) :=
    has_sum.summable (has_sum_pow_floor r' x),
  unfold θ,
  unfold tsum,
  rw [dif_pos this],
  exact has_sum.unique (some_spec this) (has_sum_pow_floor r' x),
end

lemma θ_surj_on_nonneg_nat (r' : ℝ≥0) [fact (r' < 1)] (r : ℝ≥0) [fact (r < 1)] (x : ℝ≥0) :
  ∃ (F : laurent_measures r (Fintype.of punit)), (θ r' r F) = x :=
begin
  let F₀ : Fintype.of punit → ℤ → ℤ := λ a m, int.of_nat (floor_seq_nat x m),
  have Hr : ∀ (s : Fintype.of punit), summable (λ (n : ℤ), ∥F₀ s n∥ * ↑r ^ n),
  { intro s,
    apply has_sum.summable (has_sum_pow_floor_norm_nat r x) },
  let F : laurent_measures r (Fintype.of punit) := ⟨F₀, Hr⟩,
  use F,
  have : summable (λ (n : ℤ), (F.to_Rfct r n) * (r'.1) ^ n) := sorry,
    -- has_sum.summable (has_sum_pow_floor_nat r' x),
  unfold θ,
  unfold tsum,
  rw [dif_pos this],
  exact has_sum.unique (some_spec this) (has_sum_pow_floor r' x),
end

lemma θ_surj (r' : ℝ≥0) [fact (r' < 1)] (r : ℝ≥0) [fact (r < 1)] : surjective (θ r' r) :=
begin
  intro x,
  by_cases hx : 0 ≤ x,
  { exact θ_surj_on_nonneg r' r ⟨x, hx⟩},
  replace hx := le_of_lt (neg_pos_of_neg (lt_of_not_ge hx)),
  obtain ⟨F, hF⟩ := θ_surj_on_nonneg r' r ⟨-x,hx⟩,
  use -F,
  sorry,--better to do it later, once θ becomes a comp_haus_blah morphism, in particular linear
end

end thm69_surjective
