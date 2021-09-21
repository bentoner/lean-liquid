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

open filter function classical finset
open_locale topological_space classical nnreal big_operators

--move me to laurent_measures.basic



-- instance : has_coe (laurent_measures r S) (laurent_measures r₁ S) :=
-- { coe :=
-- begin
--   rintros ⟨F, hF⟩,
--   use F,
--   sorry,
-- end}


section thm69_surjective

lemma sub_one_le_nat_floor' (x : ℝ) : x - 1 ≤ ⌊x⌋₊ :=
begin
  by_cases hx : x ≤ 0,
  { rw (nat_floor_of_nonpos hx), exact (le_of_lt (sub_one_lt x)).trans hx },
  { rw [sub_le_iff_le_add], exact le_of_lt (lt_nat_floor_add_one x) }
end

-- lemma nat_floor_le_nat (x : ℝ≥0) : (⌊(x.1)⌋₊ : ℝ≥0) ≤ x :=
--   by {simp only [← nnreal.coe_le_coe, nnreal.coe_nat_cast], from nat_floor_le x.2}

lemma converges_floor_rat  --(r' : ℝ≥0) [fact (r' < 1)] (h_r' : r' ≠ 0) :
    (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) (x : ℝ) (h_x : x ≥ 0)
   : tendsto (λn : ℕ, (nat_floor (x / r' ^ (n - 1)) : ℝ) * r' ^ ( n- 1)) at_top (𝓝 x) :=
begin
  by_cases h_zero : x = 0,
  { simp_rw [h_zero, zero_div, nat_floor_zero, nat.cast_zero, zero_mul, tendsto_const_nhds] },
  { let x₀ : ℝ≥0 := ⟨x, h_x⟩,
    have h_pos : ∀ n : ℕ, 0 < (r' : ℝ) ^ n := pow_pos (rat.cast_pos.mpr h_pos'),
    haveI : ∀ n : ℕ, invertible ((r' : ℝ) ^ n) := λ n, invertible_of_nonzero (ne_of_gt (h_pos n)),
    have h₁ : ∀ n : ℕ, (x - r' ^ (n - 1)) ≤ (nat_floor (x / r' ^ (n - 1)) : ℝ) * r' ^ (n - 1),
    { intro n,
      have := (mul_le_mul_right $ h_pos (n -1)).mpr
        (sub_one_le_nat_floor' (x / (r' : ℝ) ^ (n - 1) : ℝ)),
      have h_calc : (x - r' ^ (n - 1)) = ( x / r' ^ (n - 1) - 1) * (r' ^ (n - 1)),
      { rw [div_sub_one, div_mul_cancel];
        apply ne_of_gt (h_pos (n - 1)) },
      rwa h_calc },
    have HH : tendsto (λn : ℕ, x - r' ^ (n -1 )) at_top (𝓝 x),
    { suffices : tendsto (λn : ℕ, (r' : ℝ) ^ (n -1)) at_top (𝓝 0),
      { have h_geom := tendsto.mul_const (-1 : ℝ) this,
        replace h_geom := tendsto.const_add x h_geom,
        simp_rw [pi.add_apply, zero_mul, add_zero, mul_neg_one,
          tactic.ring.add_neg_eq_sub] at h_geom,
        exact h_geom },
      have h_abs : abs (r' : ℝ) < 1,
      { norm_cast,
        apply abs_lt.mpr,
        exact and.intro ((right.neg_neg_iff.mpr (@zero_lt_one ℚ _ _)).trans h_pos') h_one',
        all_goals {apply_instance} },
      replace h_abs := filter.tendsto.const_mul (r'⁻¹ : ℝ)
        (tendsto_pow_at_top_nhds_0_of_abs_lt_1 (h_abs)),
      simp_rw [mul_zero, (mul_comm (r'⁻¹ : ℝ) _)] at h_abs,
      apply tendsto.congr' _ h_abs,
      replace h_pos' : (r' : ℝ) ≠ 0 := by {rwa [ne.def, rat.cast_eq_zero], from (ne_of_gt h_pos')},
      rw eventually_eq_iff_exists_mem,
      use { n | n ≥ 1 },
      split,
      { simp only [mem_at_top_sets, ge_iff_le, set.mem_set_of_eq],
        use 1,
        tauto },
      { intros n hn,
        field_simp,
        ring_nf,
        nth_rewrite_rhs 0 [← pow_one ↑r'],
        rw [← pow_add ↑r' 1 (n - 1)],
        rwa nat.add_sub_cancel' }},
    have h₂ : ∀ n : ℕ, (nat_floor (x / (r' : ℝ) ^ (n - 1) ) : ℝ) * (r' : ℝ) ^ (n - 1) ≤ x,
    { intro n,
      have h_pos' : (x / r' ^ (n - 1)) > 0 := div_pos ((ne.symm h_zero).le_iff_lt.mp h_x) (h_pos (n - 1)),
      have := (mul_le_mul_right $ h_pos (n - 1)).mpr (nat_floor_le (le_of_lt h_pos')),
      calc (nat_floor (x / r' ^ (n - 1)) : ℝ) * (r' : ℝ) ^ (n - 1) ≤ (x / r' ^ (n - 1)) * (r' ^ (n - 1)) : this
                                              ... = x : div_mul_cancel_of_invertible x (r' ^ (n - 1)) },
    apply tendsto_of_tendsto_of_tendsto_of_le_of_le HH tendsto_const_nhds h₁ h₂ },
end


--[FAE] In the following def I use r' : ℝ, but it might be a bad idea
noncomputable  def floor_seq_nat' (x : ℝ) (r' : ℝ) : ℤ → ℕ
| (int.of_nat n)          := nat.rec_on n ⌊x⌋₊ (λ n, ⌊1 / r' ^ n * x⌋₊ - ⌊1 / r'⌋₊ * ⌊1 / r' ^ (n-1) * x⌋₊)
| (int.neg_succ_of_nat n) := 0

noncomputable  def floor_seq_rat (r' : ℚ) (x : ℝ) : ℤ → ℕ --or → ℤ?
| (int.of_nat n)          := nat.rec_on n
                            ⌊x⌋₊
                            (λ n, ⌊1 / (r' : ℝ) ^ n * x⌋₊ - ⌊1 / r'⌋₊ * ⌊1 / (r' : ℝ) ^ (n-1) * x⌋₊)
| (int.neg_succ_of_nat n) := 0


lemma finite_sum_floor_seq_rat (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) (x : ℝ) (n : ℕ) :
  (range n).sum (λ (i : ℕ), (coe ∘ floor_seq_rat r' x) ↑i * (r' : ℝ) ^ i) =
    if n = 0 then 0 else ⌊x / r' ^ (n - 1) ⌋₊ * r' ^ (n - 1) :=
begin
  sorry,
end

-- lemma finite_sum_floor_seq_nat' (r' : ℝ≥0) [fact (r' < 1)] (h_r' : r' ≠ 0) (x : ℝ) (n : ℕ) :
--   (range n).sum (λ (i : ℕ), (coe ∘ floor_seq_nat' r'.1 x) ↑i * r'.1 ^ i) =
--     if n = 0 then 0 else ⌊x / r'.1 ^ (n - 1) ⌋₊ * r' ^ (n - 1) :=
-- begin
--   sorry,
-- end

lemma finite_sum_floor_seq_half (x : ℝ) (n : ℕ) : --[fact (r' < 1)] (h_r' : r' > 0)
  (range n).sum (λ (i : ℕ), (coe ∘ floor_seq_rat (1 / 2 : ℚ) x) ↑i * (1 / 2 : ℝ) ^ i) =
    if n = 0 then 0 else ⌊x / (1 / 2 : ℝ) ^ (n - 1) ⌋₊ * (1 / 2 : ℝ) ^ (n - 1) :=
begin
  by_cases h_nz : n = 0, sorry,
  have uno := calc (range n).sum (λ (i : ℕ), (coe ∘ floor_seq_nat' (1 / 2 : ℚ) x) ↑i * (1 / 2 : ℚ) ^ i) =
    ⌊x⌋₊ + ∑ k in (Ico 1 n), 1 / 2 * (⌊2 ^ k * x⌋₊ - 2 * ⌊2 ^ (k - 1) * x⌋₊) : sorry,
  have due :=
  calc  ⌊x⌋₊ + ∑ k in (Ico 1 n), 1 / 2 * (⌊2 ^ k * x⌋₊ - 2 * ⌊2 ^ (k - 1) * x⌋₊) =
        ⌊x⌋₊ + 1 / 2 ^ (n - 1) * ∑ k in (Ico 1 n), 2 ^ (n - k) * (⌊2 ^ k * x⌋₊ - 2 * ⌊2 ^ (k - 1) * x⌋₊) : sorry
  ... = ⌊x⌋₊ + 1 / 2 ^ (n - 1) * ( ∑ k in (Ico 1 n), 2 ^ (n - k) * ⌊2 ^ k * x⌋₊ - ∑ k in (Ico 1 n), 2 ^ (n - (k - 1)) * ⌊2 ^ (k - 1) * x⌋₊) : sorry
  ... = ⌊x⌋₊ + 1 / 2 ^ (n - 1) * (⌊2 ^ (n - 1) * x⌋₊ + ∑ k in (Ico 1 (n - 1)), 2 ^ (n - k) * ⌊2 ^ k * x⌋₊ - ∑ k in (Ico 1 n), 2 ^ (n - (k - 1)) * ⌊2 ^ (k - 1) * x⌋₊) : sorry
  ... = ⌊x⌋₊ + 1 / 2 ^ (n - 1) * (⌊2 ^ (n - 1) * x⌋₊ + ∑ k in (Ico 1 (n - 1)), 2 ^ (n - k) * ⌊2 ^ k * x⌋₊ - ∑ k in (Ico 2 n), 2 ^ (n - (k - 1)) * ⌊2 ^ (k - 1) * x⌋₊ - 2 ^ (n - 1) * ⌊x⌋₊) : sorry
  ... = ⌊x⌋₊ + 1 / 2 ^ (n - 1) * (⌊2 ^ (n - 1) * x⌋₊ + ∑ k in (Ico 1 (n - 1)), 2 ^ (n - k) * ⌊2 ^ k * x⌋₊ - ∑ k in (Ico 1 (n - 1)), 2 ^ (n - k) * ⌊2 ^ k * x⌋₊ - 2 ^ (n - 1) * ⌊x⌋₊) : sorry
  ... = ⌊x⌋₊ + 1 / 2 ^ (n - 1) * (⌊2 ^ (n - 1) * x⌋₊ - 2 ^ (n - 1) * ⌊x⌋₊) : sorry
  ... = ⌊x⌋₊ + 1 / 2 ^ (n - 1) * ⌊2 ^ (n - 1) * x⌋₊ - (1 / 2 ) ^ (n - 1) * 2 ^ (n - 1) * ⌊x⌋₊ : sorry
  ... = 1 / 2 ^ (n - 1) * ⌊2 ^ (n - 1) * x⌋₊ : sorry,
    --  sorry,/
    sorry,
end

lemma has_sum_pow_floor_rat (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) (x : ℝ) (h_x : x≥0)
  : has_sum (λ n, (coe ∘ floor_seq_rat r' x) n * (r' : ℝ) ^ n) x :=
begin
  let x₀ : ℝ≥0 := ⟨x, h_x⟩,
  have hinj : function.injective (coe : ℕ → ℤ) := by {apply int.coe_nat_inj},
  have h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → floor_seq_rat r' x n = 0,
  { intro,
    cases n,
    simp only [forall_false_left, set.mem_range_self, not_true, int.of_nat_eq_coe],
    intro,
    refl },
  replace h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) →
    (coe ∘ floor_seq_rat r' x) n * (r' : ℝ) ^ n = 0,
  { intros n hn,
    specialize h_range n hn,
    rw [comp_app, h_range, nat.cast_zero, zero_mul], },
  apply (@function.injective.has_sum_iff _ _ _ _ _ _ x _ hinj h_range).mp,
  have H : (λ (n : ℤ), ((coe ∘ floor_seq_rat r' x) n * (r' : ℝ) ^ n)) ∘ coe =
    (λ (n : ℕ), (coe ∘ floor_seq_rat r' x) n * r' ^ n) := by {funext,--want to change  (r' : ℝ) ^ n?
      simp only [comp_app, gpow_coe_nat] },
  rw H,
  have h_pos : ∀ n : ℕ, (coe ∘ floor_seq_rat r' x) n * (r' : ℝ) ^ n ≥ 0,
  { intro n,
    apply mul_nonneg,
    rw comp_app,
    simp only [nat.cast_nonneg],
    norm_cast,
    apply pow_nonneg (le_of_lt h_pos') n, },
  apply (has_sum_iff_tendsto_nat_of_nonneg h_pos x).mpr,
  have aux : (λ n, ite (n = 0) (0 : ℝ) ((⌊x / (r' : ℝ) ^ (n - 1)⌋₊) * (r' : ℝ) ^ (n - 1))) =ᶠ[at_top]
    λ n, (↑⌊x / (r' : ℝ) ^ (n - 1)⌋₊ * (r' : ℝ) ^ (n - 1)),
  { rw eventually_eq_iff_exists_mem,
    use { n | n ≥ 1 },
    split,
    { simp only [mem_at_top_sets, ge_iff_le, set.mem_set_of_eq],
      use 1,
      tauto },
    { intros n hn,
      replace hn : n ≠ 0 := ne_of_gt (nat.succ_le_iff.mp hn),
      simpa only [ite_eq_right_iff, nat.cast_eq_zero, zero_eq_mul] }},
  simp_rw (finite_sum_floor_seq_rat r' h_pos' h_one' x),
  rw ← (tendsto_congr' aux.symm),
  apply converges_floor_rat r' h_pos' h_one' x h_x,
end

lemma has_sum_pow_floor_half (x : ℝ) (h_x : x≥0) :
  has_sum (λ n, (coe ∘ floor_seq_rat (1 / 2) x) n * ((1 / 2) : ℝ) ^ n) x :=
begin
  -- have h_pos' := (@one_half_pos ℝ _),
  let x₀ : ℝ≥0 := ⟨x, h_x⟩,
  have hinj : function.injective (coe : ℕ → ℤ) := by {apply int.coe_nat_inj},
  have h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → floor_seq_rat (1 / 2) x n = 0,
  { intro,
    cases n,
    simp only [forall_false_left, set.mem_range_self, not_true, int.of_nat_eq_coe],
    intro,
    refl },
  replace h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) →
    (coe ∘ floor_seq_rat (1 / 2) x) n * ((1 / 2) : ℝ) ^ n = 0,
  { intros n hn,
    specialize h_range n hn,
    rw [comp_app, h_range, nat.cast_zero, zero_mul], },
  apply (@function.injective.has_sum_iff _ _ _ _ _ _ x _ hinj h_range).mp,
  have H : (λ (n : ℤ), ((coe ∘ floor_seq_rat (1 / 2) x) n * ((1 / 2) : ℝ) ^ n)) ∘ coe =
    (λ (n : ℕ), (coe ∘ floor_seq_rat (1 / 2) x) n * (1 / 2) ^ n) := by {funext,--want to change  (r' : ℝ) ^ n?
      simp only [comp_app, gpow_coe_nat] },
  rw H,
  have h_pos : ∀ n : ℕ, (coe ∘ floor_seq_rat (1 / 2) x) n * ((1 / 2) : ℝ) ^ n ≥ 0,
  { intro n,
    apply mul_nonneg,
    rw comp_app,
    simp only [nat.cast_nonneg],
    norm_cast,
    apply pow_nonneg (le_of_lt (@one_half_pos ℝ _)) n },
  apply (has_sum_iff_tendsto_nat_of_nonneg h_pos x).mpr,
  have aux : (λ n, ite (n = 0) (0 : ℝ) ((⌊x / ((1 / 2) : ℝ) ^ (n - 1)⌋₊) * ((1 / 2) : ℝ) ^ (n - 1)))
   =ᶠ[at_top] λ n, (↑⌊x / ((1 / 2) : ℝ) ^ (n - 1)⌋₊ * ((1 / 2) : ℝ) ^ (n - 1)),
  { rw eventually_eq_iff_exists_mem,
    use { n | n ≥ 1 },
    split,
    { simp only [mem_at_top_sets, ge_iff_le, set.mem_set_of_eq],
      use 1,
      tauto },
    { intros n hn,
      replace hn : n ≠ 0 := ne_of_gt (nat.succ_le_iff.mp hn),
      simpa only [ite_eq_right_iff, nat.cast_eq_zero, zero_eq_mul] }},
  simp_rw (finite_sum_floor_seq_half x),
  rw ← (tendsto_congr' aux.symm),
  convert converges_floor_rat (1 / 2 : ℚ) (@one_half_pos ℚ _) (one_half_lt_one) x h_x,
  simp only [one_div, rat.cast_inv, rat.cast_one, rat.cast_bit0],
end

-- lemma has_sum_pow_floor_nat' (r' : ℝ≥0) [fact (r' < 1)] (h_r' : r' ≠ 0) (x : ℝ) (hx_pos : x≥0) : has_sum (λ n, (coe ∘ floor_seq_nat' r'.1 x) n * r'.1 ^ n) x :=
-- begin
--   let x₀ : ℝ≥0 := ⟨x, hx_pos⟩,
--   have hinj : function.injective (coe : ℕ → ℤ) := by {apply int.coe_nat_inj},
--   have h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → floor_seq_nat' r'.1 x n = 0,--could also use primed version
--   { intro,
--     cases n,
--     simp only [forall_false_left, set.mem_range_self, not_true, int.of_nat_eq_coe],
--     intro,
--     refl },
--   replace h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → (coe ∘ floor_seq_nat' r'.1 x) n * r'.1 ^ n = 0,
--   { intros n hn,
--     specialize h_range n hn,
--     rw [comp_app, h_range, nat.cast_zero, zero_mul] },
--   apply (@function.injective.has_sum_iff _ _ _ _ _ _ x _ hinj h_range).mp,
--   have H : (λ (n : ℤ), ((coe ∘ floor_seq_nat' r'.1 x) n * r'.1 ^ n)) ∘ coe =
--     (λ (n : ℕ), (coe ∘ floor_seq_nat' r'.1 x) n * r'.1 ^ n) := by {funext,
--       simp only [comp_app, gpow_coe_nat] },
--   rw H,
--   have h_pos : ∀ n : ℕ, (coe ∘ floor_seq_nat' r'.1 x) n * r'.1 ^ n ≥ 0,
--   { intro n,
--     apply mul_nonneg,
--     rw comp_app,
--     simp only [nat.cast_nonneg],
--     exact pow_nonneg r'.2 n },
--   apply (has_sum_iff_tendsto_nat_of_nonneg h_pos x).mpr,
--   have aux : (λ n, ite (n = 0) 0 ((⌊x / r'.val ^ (n - 1)⌋₊ : ℝ) * ↑r' ^ (n - 1))) =ᶠ[at_top]
--     λ n, (↑⌊x / r'.val ^ (n - 1)⌋₊ * ↑r' ^ (n - 1)),
--     sorry,
--   simp_rw (finite_sum_floor_seq_nat' r' h_r' x),
--   rw ← (tendsto_congr' aux.symm),
--   sorry,
--   -- apply converges_floor_rat x hx_pos r' h_r',
-- end

/-
lemma has_sum_pow_floor_rat (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) (x : ℝ) (h_x : x≥0)
  : has_sum (λ n, (coe ∘ floor_seq_rat r' x) n * (r' : ℝ) ^ n) x :=
-/

lemma has_sum_pow_floor_rat_norm (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) (x : ℝ) (h_x : x≥0) :
  has_sum (λ n, ∥ (floor_seq_rat r' x n : ℝ) ∥ * r' ^ n) x :=
begin
  sorry,--will be an easy consequence of the previous one
end


-- lemma has_sum_pow_floor_norm_nat' (r' : ℝ≥0)  [fact (r' < 1)] (h_nz :  r' ≠ 0) (x : ℝ) :
--   has_sum (λ n, ∥ (floor_seq_nat' r'.1 x n : ℝ) ∥ * r' ^ n) x :=
--   -- has_sum (λ n, ∥ ((coe : ℕ → ℝ) ∘ floor_seq_nat x) n ∥ * r' ^ n) x :=
-- begin
--   sorry,--will be an easy consequence of the previous one
-- end



def laurent_measures.to_Rfct (r : ℝ≥0) [fact (r < 1)] :
  (laurent_measures r (Fintype.of punit)) → (ℤ → ℝ) := λ ⟨F, _⟩, coe ∘ (F punit.star)

noncomputable def θ (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) (r : ℝ≥0) [fact (r < 1)] :
 (laurent_measures r (Fintype.of punit)) → ℝ := λ F, tsum (λ n, (F.to_Rfct r n) * r' ^ n)


--[FAE] : modify ϕ to a `def` and do things properly!

def ϕ (r₂ r₁ : ℝ≥0) (h : r₁ < r₂) {S : Fintype} :
  (laurent_measures r₂ S) → (laurent_measures r₁ S) := sorry

lemma θ_and_ϕ (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) (r₁ r₂ : ℝ≥0) [fact (r₁ < 1)]
  [fact (r₂ < 1)] (h : r₁ < r₂) (F : laurent_measures r₂ (Fintype.of punit)) :
  θ r' h_pos' h_one' r₁ (ϕ r₂ r₁ h F) = θ r' h_pos' h_one' r₂ F := sorry

-- lemma θ_ext : (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) (r₁ r₂  : ℝ≥0) [fact (r₁ < 1)]
--  [fact (r₂ < 1)] : (laurent_measures r (Fintype.of punit)) → ℝ := λ F, tsum (λ n, (F.to_Rfct r n) * r' ^ n)

noncomputable def θ₁ (r' : ℝ≥0) [fact (r' < 1)] (r : ℝ≥0) [fact (r < 1)] :
 (laurent_measures r (Fintype.of punit)) → ℝ := λ F, tsum (λ n, (F.to_Rfct r n) * (r'.1) ^ n)
--FAE The assumption that r' < r is not needed by the definition of tsum


--move me to mathlib
@[simp, norm_cast]
lemma coe_pow' (r : ℝ≥0) (n : ℤ) : ((r^n : ℝ≥0) : ℝ) = r^n :=
begin
  cases n,
  apply nnreal.coe_pow,
  simp only [gpow_neg_succ_of_nat, inv_pow', nnreal.coe_pow, nnreal.coe_inv],
end

-- theorem θ_surj (r' : ℚ) [h_r' : r' > 0] [fact (r' < 1)] (r : ℝ≥0) [h_r : r ≠ 0] [fact (r < 1)]
--   (h_r'r : r' < r.1): ∀ x : ℝ, ∃ (F : laurent_measures r (Fintype.of punit)), (θ r' r F) = x :=

-- example (r : ℚ) (h : r < 1) : (r : ℝ) < 1 :=
-- begin
--   have := (@rat.cast_lt ℝ _ r 1).mpr h,
-- end

-- variables (t : ℚ) (ht : 0 < t)
-- #check (⟨(t : ℝ), le_of_lt ((@rat.cast_pos ℝ _ _).mpr ht)⟩ : ℝ≥0)

-- lemma θ_surj_on_nonneg_rat (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) --(r : ℝ≥0) [fact (r < 1)]
--   (t : ℚ) (h_pos : 0 < t)
--   [A : fact ((⟨(t : ℝ), le_of_lt ((@rat.cast_pos ℝ _ _).mpr h_pos)⟩ : ℝ≥0) < (1 : ℝ≥0))]
--   (h_r't : r' < t)
--   (x : ℝ) (h_x : x≥0) : ∃ (F : laurent_measures (real.to_nnreal (t : ℝ)) (Fintype.of punit)),
--   (θ r' h_pos' h_one' (real.to_nnreal (t : ℝ)) F) = x :=
lemma θ_surj_on_nonneg_rat (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) --(r : ℝ≥0) [fact (r < 1)]
  (t : ℚ) (h_pos : 0 < t)
  [H : fact ((⟨(t : ℝ), le_of_lt ((@rat.cast_pos ℝ _ _).mpr h_pos)⟩ : ℝ≥0) < (1 : ℝ≥0))]
  (h_r't : r' < t) (x : ℝ) (h_x : x≥0) :
  ∃ (F : laurent_measures ⟨(t : ℝ), le_of_lt ((@rat.cast_pos ℝ _ _).mpr h_pos)⟩ (Fintype.of punit)),
  (@θ r' h_pos' h_one' ⟨(t : ℝ), le_of_lt ((@rat.cast_pos ℝ _ _).mpr h_pos)⟩ H F) = x :=
begin
  let t₀ : ℝ≥0 := (⟨(t : ℝ), le_of_lt ((@rat.cast_pos ℝ _ _).mpr h_pos)⟩),
  have h_one : t₀ < (1 : ℝ≥0) := H.out,
  replace h_one : t < 1 := by {apply (@rat.cast_lt ℝ _ _ _).mp, rw rat.cast_one, exact h_one},
  let F₀ : Fintype.of punit → ℤ → ℤ := λ _ n, int.of_nat (floor_seq_rat t x n),
  have hF : ∀ (s : Fintype.of punit), summable (λ n : ℤ, ∥ F₀ s n ∥ * t ^ n),
  { intro s,
    apply has_sum.summable (has_sum_pow_floor_rat_norm t h_pos h_one x h_x) },
  let F : laurent_measures t₀ (Fintype.of punit) := ⟨F₀, hF⟩,
  use F,
  have h_sum : summable (λ (n : ℤ), (@laurent_measures.to_Rfct t₀ H F n) * t ^ n) :=
    (has_sum_pow_floor_rat t h_pos h_one x h_x).summable,
  unfold θ,
  have := has_sum_pow_floor_rat r' h_pos' h_one' x h_x,
  sorry,--FAE: We need somewhere to pass from convergence for t to convergence for r' < t
  -- exact has_sum.tsum_eq this,
end


--certainly the wrong def: I am not assuming r' ≥ 0 and r' < r
noncomputable def τ (r' : ℚ) (r : ℝ≥0) [fact (r < 1)] : {t : ℚ // 0 < t} :=
begin
  have h : r < 1 := fact.out _,
  use some (@exists_rat_btwn ℝ _ _ r 1 h),
  rwa [← (@rat.cast_lt ℝ _ 0 (some _)), rat.cast_zero],
  exact (lt_of_le_of_lt r.2) (some_spec (@exists_rat_btwn ℝ _ _ r 1 h)).left,
end

noncomputable def τ₀ (r' : ℚ) (r : ℝ≥0) [fact (r < 1)] : ℝ≥0 :=
⟨((τ r' r).1 : ℝ), le_of_lt ((@rat.cast_pos ℝ _ _).mpr (τ r' r).2)⟩

lemma r'_lt_τ (r' : ℚ) (r : ℝ≥0) [fact (r < 1)] : r' < τ r' r := sorry

lemma τ₀_one (r' : ℚ) (r : ℝ≥0) [fact (r < 1)] : (τ₀ r' r) < (1 : ℝ≥0) := sorry

lemma r_lt_τ₀ (r' : ℚ) (r : ℝ≥0) [fact (r < 1)] : r < (τ₀ r' r) := sorry

lemma θ_surj_on_nonneg (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) --(r : ℝ≥0) [fact (r < 1)]
  (r : ℝ≥0) (h_pos : 0 < r) [fact (r < 1)] (h_r'r : (r' : ℝ) < r)
  (x : ℝ) (h_x : x≥0) : ∃ (F : laurent_measures r (Fintype.of punit)),
  (θ r' h_pos' h_one' r F) = x :=
begin
  -- have t : ℚ, sorry,--ok
  -- have h_post : 0 < t, sorry,--ok
  -- let t₀ : ℝ≥0 := (⟨(t : ℝ), le_of_lt ((@rat.cast_pos ℝ _ _).mpr h_post)⟩),--ok
  have H : fact (τ₀ r' r < (1 : ℝ≥0)) := ⟨τ₀_one r' r⟩,
  -- have h_tr : r < t₀, sorry,--ok
  -- have h_tr' : r' < t, sorry, --follows from h_sr
  -- resetI,
  obtain ⟨F, hF⟩ := @θ_surj_on_nonneg_rat r' h_pos' h_one' (τ r' r) (τ r' r).2 H (r'_lt_τ r' r) x h_x,
  use ϕ (τ₀ r' r) r (r_lt_τ₀ r' r) F,
  have := @θ_and_ϕ r' h_pos' h_one' r (τ₀ r' r) _ H (r_lt_τ₀ r' r) F,
  sorry,
  -- rw this,
  -- rwa [← @θ_and_ϕ r' h_pos' h_one' r (τ₀ r' r) _ H (r_lt_τ₀ r' r) F] at hF,
end

-- lemma θ_surj_on_nonneg' (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) (r : ℝ≥0) [fact (r < 1)]
--   (h_r'r : ↑r' < r.1) (x : ℝ) (h_x : x≥0) : ∃ (F : laurent_measures r (Fintype.of punit)),
--   (θ r' h_pos' h_one' r F) = x :=
-- begin
--   let F₀ : Fintype.of punit → ℤ → ℤ := λ _ n, int.of_nat (floor_seq_rat r' x n),
--   have Hr : ∀ (s : Fintype.of punit), summable (λ n : ℤ, ∥ F₀ s n ∥ * r ^ n),
--   { intro s,
--     apply has_sum.summable (has_sum_pow_floor_norm_nat' r h_r x) },
--   let F : laurent_measures r (Fintype.of punit) := ⟨F₀, Hr⟩,
--   use F,
--   have h_sum : summable (λ (n : ℤ), (F.to_Rfct r n) * r.1 ^ n) :=
--     (has_sum_pow_floor_nat' r h_r x hx_pos).summable,
--   unfold θ,
--   have := has_sum_pow_floor_nat' r' h_r' x hx_pos,
--   sorry,--FAE: We need somewhere to pass from convergence for r to convergence for r' < r
--   -- exact has_sum.tsum_eq this,
-- end


-- lemma θ_surj_on_nonneg_nat (r' : ℝ≥0) (h_r' : r' ≠ 0) [fact (r' < 1)] (r : ℝ≥0) [fact (r < 1)]
--   (h_r : r ≠ 0) (x : ℝ) (hx_pos : x≥0) : ∃ (F : laurent_measures r (Fintype.of punit)),
--   (θ r' r F) = x :=
-- begin
--   let F₀ : Fintype.of punit → ℤ → ℤ := λ _ n, int.of_nat (floor_seq_nat' r.1 x n),
--   have Hr : ∀ (s : Fintype.of punit), summable (λ n : ℤ, ∥ F₀ s n ∥ * r ^ n),
--   { intro s,
--     apply has_sum.summable (has_sum_pow_floor_norm_nat' r h_r x) },
--   let F : laurent_measures r (Fintype.of punit) := ⟨F₀, Hr⟩,
--   use F,
--   have h_sum : summable (λ (n : ℤ), (F.to_Rfct r n) * r.1 ^ n) :=
--     (has_sum_pow_floor_nat' r h_r x hx_pos).summable,
--   unfold θ,
--   have := has_sum_pow_floor_nat' r' h_r' x hx_pos,
--   sorry,--FAE: We need somewhere to pass from convergence for r to convergence for r' < r
--   -- exact has_sum.tsum_eq this,
-- end

-- This is the version that I will probably be able to prove. I would also like to turn h_r' and
-- h_r into facts rather than being hypothesis.
-- theorem θ_surj (r' : ℚ) [h_r' : r' > 0] [fact (r' < 1)] (r : ℝ≥0) [h_r : r ≠ 0] [fact (r < 1)]
--   (h_r'r : r' < r.1): ∀ x : ℝ, ∃ (F : laurent_measures r (Fintype.of punit)), (θ r' r F) = x :=


theorem θ_surj (r' : ℚ) (h_pos' : 0 < r') (h_one' : r' < 1) --(r : ℝ≥0) [fact (r < 1)]
  (r : ℝ≥0) (h_pos : 0 < r) [fact (r < 1)] (h_r'r : (r' : ℝ) < r)
  (x : ℝ) : ∃ (F : laurent_measures r (Fintype.of punit)), (θ r' h_pos' h_one' r F) = x :=
begin
  by_cases h_x : 0 ≤ x,
  { exact (θ_surj_on_nonneg r' h_pos' h_one' r h_pos h_r'r x h_x)},
  replace h_x := le_of_lt (neg_pos_of_neg (lt_of_not_ge h_x)),
  obtain ⟨F, hF⟩ := θ_surj_on_nonneg r' h_pos' h_one' r h_pos h_r'r (-x) h_x,
  use -F,
  sorry,--better to do it later, once θ becomes a comp_haus_blah morphism, in particular linear
end

end thm69_surjective

-- lemma converges_floor_nat (x : ℝ≥0) (r' : ℝ≥0) [fact (r' < 1)] --[fact (r'.1 ≠ 0)]
--   (h_nz : r' ≠ 0) : tendsto (λn : ℕ, (nat_floor (x.1 / r'.1 ^ n) : ℝ≥0) * r' ^ n) at_top (𝓝 x) :=
-- begin
--   by_cases hx : x = 0,
--   { simp_rw [hx, nnreal.val_eq_coe, nnreal.coe_zero, zero_div, nat_floor_zero, nat.cast_zero,
--       zero_mul, tendsto_const_nhds] },
--   { haveI : ∀ n : ℕ, invertible (r' ^ n) := λ n, invertible_of_nonzero (pow_ne_zero n _),
--     have h_pos : ∀ n : ℕ,  0 < (r' ^ n) := λ n, pow_pos ((ne.symm h_nz).le_iff_lt.mp r'.2) n,
--     replace hx : ∀ n : ℕ, x / r' ^ n ≠ 0 := λ n, div_ne_zero hx (ne_of_gt (h_pos n)),
--     have h₁ : ∀ n : ℕ, (x - r' ^ n) ≤ (nat_floor (x.1 / r'.1 ^ n) : ℝ≥0) * r' ^ n,
--     { intro n,
--       have := (mul_le_mul_right $ h_pos n).mpr (sub_one_le_nat_floor (x / r' ^ n) (hx n)),
--       rw [nnreal.val_eq_coe, nnreal.coe_div, nnreal.coe_pow] at this,
--       calc (x - r' ^ n)  = ( x / r' ^ n - 1) * (r' ^ n) : by sorry
--                     ... ≤ (nat_floor ( x.1 / r'.1 ^ n) * (r' ^ n)) : this },
--     have HH : tendsto (λn : ℕ, x - r' ^ n) at_top (𝓝 x),
--     { suffices : tendsto (λn : ℕ, r'.1 ^ n) at_top (𝓝 0),
--       { have h_geom := tendsto.mul_const (-1 : ℝ) this,
--         replace h_geom := tendsto.const_add x.1 h_geom,
--         simp_rw [pi.add_apply, zero_mul, add_zero, mul_neg_one,
--           tactic.ring.add_neg_eq_sub, nnreal.val_eq_coe] at h_geom,
--         apply nnreal.tendsto_coe.mp,
--         sorry,
--         -- simp_rw [← nnreal.coe_pow, ← nnreal.coe_sub] at h_geom,
--         -- convert h_geom -> bad idea!
--         },
--       have h_abs : abs r'.1 < 1 := by {simp, norm_cast, from fact.out _},
--       replace h_abs := tendsto_pow_at_top_nhds_0_of_abs_lt_1 (h_abs),
--       simp_rw [← one_div_pow],
--       exact h_abs },
--     have h₂ : ∀ n : ℕ, (nat_floor ((x : ℝ) / r' ^ n ): ℝ≥0) * (r' ^ n) ≤ x,
--     { intro n,
--       have := (mul_le_mul_right $ h_pos n).mpr (nat_floor_le_nat (x / r' ^ n)),
--       rw [nnreal.val_eq_coe, nnreal.coe_div, nnreal.coe_pow] at this,
--       calc (nat_floor (x.1 / r'.1 ^ n) : ℝ≥0) * (r' ^ n) ≤ (x / r' ^ n) * (r' ^ n) : this
--                                           ... = x : div_mul_cancel_of_invertible x (r' ^ n) },
--     apply tendsto_of_tendsto_of_tendsto_of_le_of_le HH tendsto_const_nhds h₁ h₂,
--     simpa only [nnreal.val_eq_coe, nnreal.coe_eq_zero, ne.def, not_false_iff], },
-- end

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

lemma sub_one_le_nat_floor (x : ℝ≥0) (hx : x ≠ 0) : x - 1 ≤ ⌊x.1⌋₊ :=
begin
  by_cases h_one : x.1 - 1 ≤ 0,
  { have : x - 1 = 0 := real.to_nnreal_eq_zero.mpr h_one,
    rw this,
    exact zero_le ⌊x.1⌋₊ },
  { simp only [← nnreal.coe_le_coe],
    rw [nnreal.coe_sub, sub_le_iff_le_add, nnreal.coe_nat_cast],
    all_goals { simp only [not_le, zero_add, nnreal.val_eq_coe] at h_one,
      rw [lt_sub_iff_add_lt, zero_add] at h_one, apply le_of_lt },
    exacts [(lt_nat_floor_add_one x.1), h_one] }
end

-- example {f : ℕ → ℝ} {r : ℝ} [h : r≥0] :
--   has_sum f r ↔ tendsto (λn:ℕ, ∑ i in finset.range n, f i) at_top (𝓝 r) := by library_search


-- lemma has_sum_pow_floor_nat (r' : ℝ≥0) [fact (r' < 1)] (h_r' : r' ≠ 0) (x : ℝ≥0)
--   : has_sum (λ n, (coe ∘ floor_seq_nat x) n * r' ^ n) x :=
-- begin
--   have hinj : function.injective (coe : ℕ → ℤ) := by {apply int.coe_nat_inj},
--   have h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → floor_seq_nat x n = 0, sorry,
--   replace h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → (coe ∘ floor_seq_nat x) n * r' ^ n = 0,
--   sorry,
--   apply (@function.injective.has_sum_iff _ _ _ _ _ _ x _ hinj h_range).mp,
--   have H : (λ (n : ℤ), (coe ∘ floor_seq_nat x) n * r' ^ n) ∘ coe =
--     (λ (n : ℕ), (coe ∘ floor_seq_nat x) n * r' ^ n), sorry,
--   rw H,
--   apply (nnreal.has_sum_iff_tendsto_nat).mpr,
--   have h_calc : ∀ n : ℕ,
--   (finset.range n).sum (λ (i : ℕ), (coe ∘ floor_seq_nat x) ↑i * r' ^ i) =
--     nat_floor (x.1 / r'.1 ^ n) * r' ^ n,
--      sorry,
--   simp_rw h_calc,
--   -- sorry,
--   apply converges_floor_nat x r' h_r',
-- end

-- lemma θ_surj_on_nonneg (r' : ℝ≥0) [fact (r' < 1)] (r : ℝ≥0) [fact (r < 1)] (x : ℝ≥0) :
--   ∃ (F : laurent_measures r (Fintype.of punit)), (θ r' r F) = x :=
-- begin
--   let F₀ : Fintype.of punit → ℤ → ℤ := λ a, (floor_seq x),
--   have Hr : ∀ (s : Fintype.of punit), summable (λ (n : ℤ), ∥F₀ s n∥ * ↑r ^ n),
--   { intro s,
--     apply has_sum.summable (has_sum_pow_floor_norm r x) },
--   let F : laurent_measures r (Fintype.of punit) := ⟨F₀, Hr⟩,
--   use F,
--   have : summable (λ (n : ℤ), (F.to_Rfct r n) * (r'.1) ^ n) :=
--     has_sum.summable (has_sum_pow_floor r' x),
--   unfold θ,
--   unfold tsum,
--   rw [dif_pos this],
--   exact has_sum.unique (some_spec this) (has_sum_pow_floor r' x),
-- end




-- lemma has_sum_pow_floor (r' : ℝ≥0) [fact (r' < 1)] (x : ℝ≥0) :
--   has_sum (λ n, (coe ∘ floor_seq x) n * r'.1 ^ n) x :=
-- begin
--   -- apply (has_sum_iff_tendsto_nat_of_nonneg).mp,
--   have hinj : function.injective (coe : ℕ → ℤ) := by {apply int.coe_nat_inj},
--   have h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → floor_seq x n = 0, sorry,
--   replace h_range : ∀ n : ℤ, n ∉ set.range (coe : ℕ → ℤ) → (coe ∘ floor_seq x) n * r'.1 ^ n = 0,
--   sorry,
--   apply (@function.injective.has_sum_iff _ _ _ _ _ _ x.1 _ hinj h_range).mp,
--   have H : (λ (n : ℤ), (coe ∘ floor_seq x) n * r'.val ^ n) ∘ coe =
--     (λ (n : ℕ), (coe ∘ floor_seq x) n * r'.val ^ n), sorry,
--   rw H,
--   sorry,
--   -- apply (nnreal.has_sum_iff_tendsto_nat).mpr,
-- --   funext a,
-- --   simp only [function.comp_app, gpow_coe_nat],
-- --   suffices : φ a = 1,
-- --   rw [this, one_mul],
-- --   refl,
-- --   rw H,
--   -- dsimp [has_sum],
--   -- apply summable.has_sum_iff_tendsto_nat,
-- end

-- lemma has_sum_pow_floor_norm (r : ℝ≥0)  [fact (r < 1)] (x : ℝ≥0) :
--   has_sum (λ n, ∥ ((coe : ℤ → ℝ) ∘ floor_seq x) n ∥ * r ^ n) x.1:=
-- begin
--   sorry,--will be an easy consequence of the previous one
-- end

-- lemma has_sum_pow_floor_norm_nat (r' : ℝ≥0)  [fact (r' < 1)] (h_nz :  r' ≠ 0) (x : ℝ≥0) :
--   has_sum (λ n, ∥ (floor_seq_nat x n : ℝ) ∥ * r' ^ n) x :=
--   -- has_sum (λ n, ∥ ((coe : ℕ → ℝ) ∘ floor_seq_nat x) n ∥ * r' ^ n) x :=
-- begin
--   sorry,--will be an easy consequence of the previous one
-- end
