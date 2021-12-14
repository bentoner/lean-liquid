-- import for_mathlib.short_exact_sequence
import analysis.special_functions.log
import analysis.special_functions.exp
import data.int.interval
import laurent_measures.basic
import laurent_measures.theta
import linear_algebra.basic


/-
This file introduces the maps
* `θ₀`, which is the specialization of evaluation-at-ξ map `ϑ` from `laurent_measures.theta`
  at `ξ=1/2`. Observe that both `ϑ` and `θ₀` evaluate only at Laurent measures supported on the
  singleton
* `ϕ₀` which corresponds to multiplying a Laurent series by `2T-1`: here, Laurent series are seen as
  Laurent measures on the singleton
* `ψ₀` corresponds to multiplying a Laurent series by `(2T-1)^-1`: again, Laurent series are seen as
  Laurent measures on the singleton. It is defined only on series vanishing at `1/2`, so that it
  again takes values in `laurent_measures r (Finitype.of punit)`.
* The maps `θ`, `ϕ` and `ψ` are the analogous of `θ₀`, `ϕ₀` and `ψ₀`, respectively, for Laurent
  measures on an arbitrary finite set `S`.
* The maps `Θ`, `Φ` and `Ψ` are the "measurifications" of `θ`, `ϕ` and `ψ` in the right category.

**The main results are ...**
-/

noncomputable theory

namespace laurent_measures

open_locale nnreal

--For every F, d F is the bound whose existence is establised in  `eq_zero_of_filtration`
def d {r : ℝ≥0} {S : Fintype} (F : laurent_measures r S) : ℤ :=
  ⌊ (real.log ∥ F ∥ / real.log (r : ℝ)) ⌋ + 1


-- lemma bdd_bounds (c : ℝ) (r : ℝ≥0) : bdd_below {n : ℤ | (c : ℝ) < (r : ℝ) ^ n} :=
-- begin
--   use ⌊ (log c / log (r : ℝ)) ⌋ + 1,
--   rintros a ha,
--   rw le_sub_iff_add_le.symm,
--   rw ← @int.cast_le ℝ _ _ _ _ ,
--   apply_fun exp_order_iso,
--   apply_fun (coe : Ioi (0 : ℝ) → ℝ),
--   -- apply coe_exp_order_iso_apply,
--   have := (coe_exp_order_iso_apply ⌊ (log c / log (r : ℝ)) ⌋),
--   -- rw ← exp_order_iso_apply,
--   -- rw exp_log,

-- end


end laurent_measures

-- namespace thm_69

-- -- open category_theory category_theory.limits
-- open theta laurent_measures filter
-- open_locale nnreal classical big_operators topological_space

-- noncomputable theory

section singleton

open theta laurent_measures filter
open_locale nnreal classical big_operators topological_space
-- local notation `ℳ` := real_measures


-- -- parameter {p : ℝ≥0}
variables {p : ℝ≥0} [fact (0 < p)] [fact (p < 1)] {S : Fintype}
variables (r : ℝ≥0) [fact (0 < r)] [fact (r < 1)]
-- def r : ℝ≥0 := (1 / 2) ^ ( 1 / p.1)
-- variables (S : Fintype)
-- -- variables (r : ℝ≥0) [fact ((1 / 2 : ℝ) ^ p.1 = r)]

--For every F, d F is the bound whose existence is establised in  `eq_zero_of_filtration`
-- def d (F : laurent_measures r (Fintype.of punit)) : ℤ :=
--   ⌊ (real.log ∥ F ∥ / real.log (r : ℝ)) ⌋ + 1

-- lemma r_ineq : 0 < r p ∧ (r p : ℝ) < 1 := sorry

-- -- lemma r_one : (r : ℝ) = 1 := sorry

-- lemma half_ineq : (1 / 2 : ℝ) < (r p) := sorry

-- -- #check r_pos.1

-- open finset

def ϕ₀ : (laurent_measures r (Fintype.of punit)) → (laurent_measures r (Fintype.of punit)) :=
begin
  -- have loc_r_ineq := (r_ineq).1,
  -- rotate,
  -- assumption',
  rintro ⟨f,hF⟩,
  let f₁ : (Fintype.of punit) → ℤ → ℤ := λ s n, 2* f s (n - 1) - f s n,
  use f₁,
  intro s,
  let g₁ : ℤ → ℝ := λ n, ∥ 2 * f s (n - 1) ∥ * r ^ n + ∥ f s n ∥ * r ^ n,
  have Hf_le_g : ∀ b : ℤ, ∥ f₁ s b ∥ * r ^ b ≤ g₁ b,
  { intro b,
    dsimp [f₁, g₁],
    rw ← add_mul,
    have rpow_pos : 0 < (r : ℝ) ^ b := by { apply zpow_pos_of_pos, rw nnreal.coe_pos,
      exact fact.out _, },
    apply (mul_le_mul_right rpow_pos).mpr,
    exact norm_sub_le (2 * f s (b - 1)) (f s b) },
  apply summable_of_nonneg_of_le _ Hf_le_g,
  { apply summable.add,
    have : ∀ b : ℤ, ∥ f s (b - 1) ∥ * r ^ b = r * ∥ f s (b - 1) ∥ * r ^ (b - 1),
    { intro b,
      nth_rewrite_rhs 0 mul_assoc,
      nth_rewrite_rhs 0 mul_comm,
      nth_rewrite_rhs 0 mul_assoc,
      rw [← zpow_add_one₀, sub_add_cancel b 1],
      rw [ne.def, nnreal.coe_eq_zero],
      apply ne_of_gt,
      exact fact.out _ },
    simp_rw [← int.norm_cast_real, int.cast_mul, normed_field.norm_mul, int.norm_cast_real,
      mul_assoc],
    apply @summable.mul_left ℝ _ _ _ _ (λ (b : ℤ), ∥f s (b - 1) ∥ * ↑r ^ b ) (∥ (2 : ℤ) ∥),
    simp_rw [this, mul_assoc],
    apply @summable.mul_left ℝ _ _ _ _ (λ (b : ℤ), ∥f s (b - 1)∥ * ↑r ^ (b - 1)) r,
    have h_comp : (λ (b : ℤ), ∥f s (b - 1)∥ * ↑r ^ (b - 1)) =
      (λ (b : ℤ), ∥f s b∥ * ↑r ^ b) ∘ (λ n, n - 1) := rfl,
    rw h_comp,
    apply summable.comp_injective _ sub_left_injective,
    repeat {apply_instance},
    repeat {specialize hF s, exact hF}, },
  { intro b,
    apply mul_nonneg,
    apply norm_nonneg,
    rw ← nnreal.coe_zpow,
    exact (r ^ b).2 },
end


-- def θ₀ : (laurent_measures r (Fintype.of punit)) → real_measures p (Fintype.of punit) :=
--   ϑ (1 / 2 : ℝ) r p (Fintype.of punit)

-- -- def θₗ : (laurent_measures r (Fintype.of punit)) →ₗ[ℤ] ℝ :=
-- -- { to_fun := λ F, tsum (λ n, (F punit.star n) * (1 / 2 : ℝ) ^ n),
-- --   map_add' :=
-- --    begin
-- --     intros F G,
-- --     rw ← tsum_add,
-- --     apply tsum_congr,
-- --     intro m,
-- --     rw [← add_mul, mul_eq_mul_right_iff],
-- --     apply or.intro_left,
-- --     rw [← int.cast_add, int.cast_inj],
-- --     apply laurent_measures.add_apply,
-- --     sorry, sorry,
-- --   end,
-- --   map_smul' := sorry }


-- lemma sum_smaller_radius₀ (F : laurent_measures r S) (s : S) :
--   summable (λ n, (F.to_fun s n : ℝ) * (1 / 2) ^ n) := sorry


-- #check θ₀ r

-- lemma θ₀_ϕ₀_complex (F : laurent_measures r (Fintype.of punit)) : (θ₀ r ∘ ϕ₀ r) F = 0 :=
-- begin
--   rcases F with ⟨f, hf⟩,
--   convert_to ∑' (n : ℤ), ((2 * f punit.star (n - 1) - f punit.star n) : ℝ) * (1 / 2) ^ n = 0,
--   { apply tsum_congr,
--     intro b,
--     rw ← inv_eq_one_div,
--     apply (mul_left_inj' (@zpow_ne_zero ℝ _ _ b (inv_ne_zero two_ne_zero))).mpr,
--     have : (2 : ℝ) * (f punit.star (b - 1)) = ((2 : ℤ) * (f punit.star (b -1))) := by {rw [← int.cast_one, int.cast_bit0] },
--     rw [this, ← int.cast_mul, ← int.cast_sub],
--     refl },
--   have h_pos : has_sum (λ n, ((2 * f punit.star (n - 1)) : ℝ) * (1 / 2) ^ n) (sum_smaller_radius r (Fintype.of punit) ⟨f, hf⟩ (punit.star)).some,
--   { have div_half : ∀ b : ℤ, (1 / 2 : ℝ) ^ b * (2 : ℝ) = (1 / 2) ^ ( b - 1),
--     { intro b,
--       rw [← inv_eq_one_div, @zpow_sub_one₀ ℝ _ _ (inv_ne_zero two_ne_zero) b],
--       apply (mul_right_inj' (@zpow_ne_zero ℝ _ _ b (inv_ne_zero two_ne_zero))).mpr,
--       exact (inv_inv₀ 2).symm },
--     have h_comp : (λ (b : ℤ), ((f punit.star (b - 1)) : ℝ ) * (1 / 2) ^ (b - 1)) =
--       (λ (b : ℤ), ((f punit.star b) : ℝ) * (1 / 2) ^ b) ∘ (λ n, n - 1) := rfl,
--     simp_rw [mul_comm, ← mul_assoc, div_half, mul_comm, h_comp],
--     let e : ℤ ≃ ℤ := ⟨λ n : ℤ, n - 1, λ n, n + 1, by {intro, simp}, by {intro, simp}⟩,
--     apply (equiv.has_sum_iff e).mpr,
--     exact (sum_smaller_radius r (Fintype.of punit) ⟨f, hf⟩ (punit.star)).some_spec, },
--   simp_rw [sub_mul],
--   rw [tsum_sub h_pos.summable, sub_eq_zero, h_pos.tsum_eq],
--   exacts [(sum_smaller_radius r (Fintype.of punit) ⟨f, hf⟩ (punit.star)).some_spec.tsum_eq.symm, (sum_smaller_radius r (Fintype.of punit) ⟨f, hf⟩ (punit.star))],
-- end

-- lemma Icc_nneg (d : ℤ) : ∀ n : ℤ, (n + d) ≥ 0 → ∀ (k ∈ finset.Icc (- d) n), n - k ≥ (0 : ℤ) := sorry


-- -- Icc_sum_integer is the n-th coefficient b_m of ψ₀(F)
-- def Icc_sum_integer (f : ℤ → ℤ) (d m : ℤ) (hm : (m + d) ≥ 0) : ℤ :=
--   (∑ k : (Icc (- d) m : set ℤ),
--     2 ^ ((int.eq_coe_of_zero_le (Icc_nneg d m hm k (coe_mem _))).some) * f (- k))

-- lemma Icc_sum_eq_tail (f : ℤ → ℤ) (d : ℤ)
--   (hf : (has_sum (λ x : {a : ℤ // a ≥ -d}, (f x : ℝ) * (1 / 2) ^ x.1) 0))
--   (m : ℤ) (hm : (m + d) ≥ 0) : - ((Icc_sum_integer f d m hm) : ℝ) =
--   2 ^ m * tsum (λ x : {a : ℤ // a ≥ m + 1}, (f x : ℝ) * (1 / 2) ^ x.1) :=
-- begin
--   sorry,
-- end

-- -- `[FAE]` To prove the next lemma I certainly need that r > (1/2).
-- lemma tail_little_oh (f : ℤ → ℤ) (n d : ℤ) (h_sum : summable (λ n : ℤ, ∥ f n ∥ * r ^n)) :
--  tendsto (λ m, (r : ℝ) ^ m * ∥ tsum (λ x : {a : ℤ // a ≥ m + 1}, (f x : ℝ) * (1 / 2) ^ x.1) ∥ )
--   at_top (𝓝 0) :=
-- begin
--   sorry
-- end

-- -- `[FAE]` I am adding the assumption r > (1/2) but it might be better to incorporate it in the
-- -- whole file
-- def ψ₀ (F : laurent_measures r (Fintype.of punit)) (hF : θ₀ r F = 0) (hr : r < 1 / 2):
--   laurent_measures r (Fintype.of punit) :=
-- begin
--   -- classical,
--   let A : (set ℤ) := {n : ℤ | n + d F ≥ 0},
--   -- have h_nneg : ∀ n : ℤ, n ∈ A → ∀ k : ℤ, k ∈ Icc (- (d F)) n → k ≥ (0 : ℤ), sorry,
--   -- have h_nneg : ∀ n : ℤ, (n + d F) ≥ 0 → ∀ (k ∈ finset.Icc (- (laurent_measures.d F)) n), k ≥ (0 : ℤ), sorry,
--   -- have n : ℤ, sorry,
--   -- have hn : n ∈ A, sorry,
--   -- have k : (finset.Icc (- (laurent_measures.d F)) n), sorry,
--   -- have hk : k ∈ (finset.Icc (- (laurent_measures.d F)) n), sorry,
--   -- have := h_nneg n hn k,
--   let f₀ : Fintype.of punit → ℤ → ℤ := λ s n,
--     if hn : n ∈ A then - (Icc_sum_integer (F.to_fun s) F.d n hn)
--     -- - (∑ k : (finset.Icc (- (d F)) n : set ℤ),
--     -- 2 ^ ((int.eq_coe_of_zero_le (Icc_nneg F.d n hn k (coe_mem _))).some) * F.to_fun s (n - k))
--     else 0,
--   use f₀,
--   intro s,
--   apply (@summable_subtype_and_compl _ _ _ _ _ _ _ A).mp,
--   split,
--   { -- have := F.2 s,
--     -- have h_dec : decidable_eq A, sorry,
--     -- apply has_sum.summable _, sorry,
--     -- let x : ℤ → Prop → ℤ := λ n : ℤ, n ∈ A → - (∑ k : (finset.Icc (- (d F)) n : set ℤ), 2 ^ ((int.eq_coe_of_zero_le (h_nneg n _ k (finset.coe_mem _))).some) * F.to_fun s (n - k)),
--     dsimp only [f₀],
--     -- have : ∀ x : A, (x : ℤ) + F.d ≥ 0, sorry,
--     simp only [*, dif_pos, subtype.coe_prop, coe_mem, norm_neg],--, Icc_sum_integer],
--     have per_ipotesi : has_sum (λ (x : {a // a ≥ -F.d}), ↑(F.to_fun s x) * (1 / 2 : ℝ) ^ x.1) 0, sorry,
--     have := Icc_sum_eq_tail (F.to_fun s) F.d per_ipotesi,
--     sorry,
--     -- simp_rw this,
--     -- apply summable_congr this _,
--     -- simp_rw [this _],


--     -- apply tsum_dite_left,-- P,

--   },
--   { convert_to summable (λ x : {n : ℤ // n ∉ A}, ∥ f₀ s x ∥ * r ^ (x.1)),
--     have h_supp : ∀ n : {x : ℤ // x ∉ A}, ∥ f₀ s n ∥ * r ^ n.1 = 0, sorry,
--     simp_rw h_supp,
--     apply summable_zero },
--   repeat { apply_instance },
-- end


-- lemma θ_ϕ_exact (F : laurent_measures r (Fintype.of punit)) (hF : θ₀ r F = 0) :
--   ∃ G, ϕ₀ r G = F := sorry


end singleton


noncomputable theory

section finite_set

open nnreal theta
open_locale nnreal classical big_operators topological_space
-- -- open category_theory category_theory.limits
-- open theta laurent_measures filter
-- open_locale nnreal classical big_operators topological_space

parameter {p : ℝ≥0}
def r : ℝ≥0 := (1 / 2) ^ ( 1 / p.1)
variables [fact(0 < p)] [fact (p < 1)]
variable (S : Fintype)

lemma r_ineq : 0 < r ∧ r < 1 := sorry

lemma r_half : 1 / 2 < r := sorry

local notation `ℳ` := real_measures p
local notation `ℒ` := laurent_measures r

def θ : ℒ S → ℳ S := ϑ (1 / 2 : ℝ) r p S

def ϕ : ℒ S → ℒ S :=
begin
  rintro ⟨f,hF⟩,
  let f₁ : S → ℤ → ℤ := λ s n, 2* f s (n - 1) - f s n,
  use f₁,
  intro s,
  let g₁ : ℤ → ℝ := λ n, ∥ 2 * f s (n - 1) ∥ * r ^ n + ∥ f s n ∥ * r ^ n,
  have Hf_le_g : ∀ b : ℤ, ∥ f₁ s b ∥ * r ^ b ≤ g₁ b,
  { intro b,
    dsimp [f₁, g₁],
    rw ← add_mul,
    have rpow_pos : 0 < (r : ℝ) ^ b := by { apply zpow_pos_of_pos, rw nnreal.coe_pos,
      exact r_ineq.1, },
    apply (mul_le_mul_right rpow_pos).mpr,
    exact norm_sub_le (2 * f s (b - 1)) (f s b) },
  apply summable_of_nonneg_of_le _ Hf_le_g,
  { apply summable.add,
    have : ∀ b : ℤ, ∥ f s (b - 1) ∥ * r ^ b = r * ∥ f s (b - 1) ∥ * r ^ (b - 1),
    { intro b,
      nth_rewrite_rhs 0 mul_assoc,
      nth_rewrite_rhs 0 mul_comm,
      nth_rewrite_rhs 0 mul_assoc,
      rw [← zpow_add_one₀, sub_add_cancel b 1],
      rw [ne.def, nnreal.coe_eq_zero],
      apply ne_of_gt,
      exact r_ineq.1 },
    simp_rw [← int.norm_cast_real, int.cast_mul, normed_field.norm_mul, int.norm_cast_real,
      mul_assoc],
    apply @summable.mul_left ℝ _ _ _ _ (λ (b : ℤ), ∥f s (b - 1) ∥ * ↑r ^ b ) (∥ (2 : ℤ) ∥),
    simp_rw [this, mul_assoc],
    apply @summable.mul_left ℝ _ _ _ _ (λ (b : ℤ), ∥f s (b - 1)∥ * ↑r ^ (b - 1)) r,
    have h_comp : (λ (b : ℤ), ∥f s (b - 1)∥ * ↑r ^ (b - 1)) =
      (λ (b : ℤ), ∥f s b∥ * ↑r ^ b) ∘ (λ n, n - 1) := rfl,
    rw h_comp,
    apply summable.comp_injective _ sub_left_injective,
    repeat {apply_instance},
    repeat {specialize hF s, exact hF}, },
  { intro b,
    apply mul_nonneg,
    apply norm_nonneg,
    rw ← nnreal.coe_zpow,
    exact (r ^ b).2 },
end

lemma sum_smaller_radius (F : ℒ S) (s : S) :
  summable (λ n, (F.to_fun s n : ℝ) * (1 / 2) ^ n) := sorry

lemma θ_ϕ_complex (F : ℒ S) : (θ S ∘ ϕ S) F = 0 :=
begin
  rcases F with ⟨f, hf⟩,
  funext,
  convert_to ∑' (n : ℤ), ((2 * f s (n - 1) - f s n) : ℝ) * (1 / 2) ^ n = 0,
  { apply tsum_congr,
    intro b,
    rw ← inv_eq_one_div,
    apply (mul_left_inj' (@zpow_ne_zero ℝ _ _ b (inv_ne_zero two_ne_zero))).mpr,
    have : (2 : ℝ) * (f s (b - 1)) = ((2 : ℤ) * (f s (b -1))) :=
      by {rw [← int.cast_one, int.cast_bit0] },
    rw [this, ← int.cast_mul, ← int.cast_sub],
    refl },
  have h_pos : has_sum (λ n, ((2 * f s (n - 1)) : ℝ) * (1 / 2) ^ n) (sum_smaller_radius S ⟨f, hf⟩ s).some,
  { have div_half : ∀ b : ℤ, (1 / 2 : ℝ) ^ b * (2 : ℝ) = (1 / 2) ^ ( b - 1),
    { intro b,
      rw [← inv_eq_one_div, @zpow_sub_one₀ ℝ _ _ (inv_ne_zero two_ne_zero) b],
      apply (mul_right_inj' (@zpow_ne_zero ℝ _ _ b (inv_ne_zero two_ne_zero))).mpr,
      exact (inv_inv₀ 2).symm },
    have h_comp : (λ (b : ℤ), ((f s (b - 1)) : ℝ ) * (1 / 2) ^ (b - 1)) =
      (λ (b : ℤ), ((f s b) : ℝ) * (1 / 2) ^ b) ∘ (λ n, n - 1) := rfl,
    simp_rw [mul_comm, ← mul_assoc, div_half, mul_comm, h_comp],
    let e : ℤ ≃ ℤ := ⟨λ n : ℤ, n - 1, λ n, n + 1, by {intro, simp}, by {intro, simp}⟩,
    apply (equiv.has_sum_iff e).mpr,
    exact (sum_smaller_radius S ⟨f, hf⟩ s).some_spec },
  simp_rw [sub_mul],
  rw [tsum_sub h_pos.summable, sub_eq_zero, h_pos.tsum_eq],
  exacts [(sum_smaller_radius S ⟨f, hf⟩ s).some_spec.tsum_eq.symm, (sum_smaller_radius S ⟨f, hf⟩ s)],
end

open finset filter
open_locale big_operators topological_space

lemma Icc_nneg (d : ℤ) : ∀ n : ℤ, (n + d) ≥ 0 → ∀ (k ∈ finset.Icc (- d) n), n - k ≥ (0 : ℤ) := sorry


-- Icc_sum_integer is the n-th coefficient b_m of ψ₀(F)
def Icc_sum_integer (f : ℤ → ℤ) (d m : ℤ) (hm : (m + d) ≥ 0) : ℤ :=
  (∑ k : (Icc (- d) m : set ℤ),
    2 ^ ((int.eq_coe_of_zero_le (Icc_nneg d m hm k (coe_mem _))).some) * f (- k))

lemma Icc_sum_eq_tail (f : ℤ → ℤ) (d : ℤ)
  (hf : (has_sum (λ x : {a : ℤ // a ≥ -d}, (f x : ℝ) * (1 / 2) ^ x.1) 0))
  (m : ℤ) (hm : (m + d) ≥ 0) : - ((Icc_sum_integer f d m hm) : ℝ) =
  2 ^ m * tsum (λ x : {a : ℤ // a ≥ m + 1}, (f x : ℝ) * (1 / 2) ^ x.1) :=
begin
  sorry,
end


lemma tail_little_o (f : ℤ → ℤ) (n d : ℤ) (h_sum : summable (λ n : ℤ, ∥ f n ∥ * r ^n)) :
 tendsto (λ m, (r : ℝ) ^ m * ∥ tsum (λ x : {a : ℤ // a ≥ m + 1}, (f x : ℝ) * (1 / 2) ^ x.1) ∥ )
  at_top (𝓝 0) :=
begin
  sorry
end

open laurent_measures

def ψ₀ (F : ℒ S) (hF : θ S F = 0) : ℒ S :=
begin
  -- classical,
  let A : (set ℤ) := {n : ℤ | n + d F ≥ 0},
  -- have h_nneg : ∀ n : ℤ, n ∈ A → ∀ k : ℤ, k ∈ Icc (- (d F)) n → k ≥ (0 : ℤ), sorry,
  -- have h_nneg : ∀ n : ℤ, (n + d F) ≥ 0 → ∀ (k ∈ finset.Icc (- (laurent_measures.d F)) n), k ≥ (0 : ℤ), sorry,
  -- have n : ℤ, sorry,
  -- have hn : n ∈ A, sorry,
  -- have k : (finset.Icc (- (laurent_measures.d F)) n), sorry,
  -- have hk : k ∈ (finset.Icc (- (laurent_measures.d F)) n), sorry,
  -- have := h_nneg n hn k,
  let f₀ : S → ℤ → ℤ := λ s n,
    if hn : n ∈ A then - (Icc_sum_integer (F.to_fun s) F.d n hn)
    -- - (∑ k : (finset.Icc (- (d F)) n : set ℤ),
    -- 2 ^ ((int.eq_coe_of_zero_le (Icc_nneg F.d n hn k (coe_mem _))).some) * F.to_fun s (n - k))
    else 0,
  use f₀,
  intro s,
  apply (@summable_subtype_and_compl _ _ _ _ _ _ _ A).mp,
  split,
  { -- have := F.2 s,
    -- have h_dec : decidable_eq A, sorry,
    -- apply has_sum.summable _, sorry,
    -- let x : ℤ → Prop → ℤ := λ n : ℤ, n ∈ A → - (∑ k : (finset.Icc (- (d F)) n : set ℤ), 2 ^ ((int.eq_coe_of_zero_le (h_nneg n _ k (finset.coe_mem _))).some) * F.to_fun s (n - k)),
    dsimp only [f₀],
    -- have : ∀ x : A, (x : ℤ) + F.d ≥ 0, sorry,
    simp only [*, dif_pos, subtype.coe_prop, coe_mem, norm_neg],--, Icc_sum_integer],
    have per_ipotesi : has_sum (λ (x : {a // a ≥ -F.d}), ↑(F.to_fun s x) * (1 / 2 : ℝ) ^ x.1) 0, sorry,
    have := Icc_sum_eq_tail (F.to_fun s) F.d per_ipotesi,
    sorry,
    -- simp_rw this,
    -- apply summable_congr this _,
    -- simp_rw [this _],


    -- apply tsum_dite_left,-- P,

  },
  { convert_to summable (λ x : {n : ℤ // n ∉ A}, ∥ f₀ s x ∥ * r ^ (x.1)),
    have h_supp : ∀ n : {x : ℤ // x ∉ A}, ∥ f₀ s n ∥ * r ^ n.1 = 0, sorry,
    simp_rw h_supp,
    apply summable_zero },
  repeat { apply_instance },
end

theorem θ_ϕ_exact (F : ℒ S) (hF : θ S F = 0) : ∃ G, ϕ S G = F := sorry

end finite_set

-- #where
-- end
-- section SES_thm69

-- local notation `ℳ` := real_measures


-- include r

-- This `θ₂` is the "measurification" of the map `θₗ` of
-- Theorem 6.9. Thus, `to_meas_θ` is the map inducing the isomorphism of Theorem 6.9 (2)
-- def θ' : laurent_measures r S → ℳ p S :=
-- λ F s, θ₀ r ⟨(λ _, F s), (λ _, F.2 s)⟩

-- lemma θ_zero :
--  (θ p r S (0 : laurent_measures r S)) = 0 := sorry

-- lemma θ_add (F G : laurent_measures r S) :
--  (θ p r S (F + G)) = (θ p r S F) + (θ p r S G) := sorry

-- This `lemma to_meas_θ_bound` is precisely Prop 7.2 (3) of `Analytic.pdf`
-- lemma θ_bound : ∃ (C : ℝ≥0), ∀ (c : ℝ≥0) (F : laurent_measures r S),
--   ∥ F ∥ ≤ c → ∥ θ p r S F ∥₊ ≤ C * c := sorry

-- def to_add_hom_θ : add_hom (laurent_measures r S) (ℳ p S) :=
-- add_monoid_hom.mk' (λ F, θ p r S F)
-- begin
--     intros a b,
--     have := θ_add p r S a b,
--     exact this,
--   end

-- def Θ : comphaus_filtered_pseudo_normed_group_hom (laurent_measures r S) (ℳ p S) :=
--   { to_fun := θ p r S,
--     bound' := θ_bound p r S,
--     continuous' := sorry, -- [FAE] I guess that this is Prop 7.2 (4) of `Analytic.pdf`
--     -- .. to_add_hom_meas_θ ξ r S p,
--     map_add' := (to_add_hom_θ p r S).2,
--     map_zero' := sorry }


-- lemma chain_complex_thm69 (F : laurent_measures r S) : Θ p r S (𝑓 • F) = 0 :=
-- begin
--   funext s,
--   sorry,
--   -- simp only [real_measures.zero_apply],
--   -- dsimp [Θ],
--   -- dsimp [to_meas_θ],
--   -- dsimp [θ],
--   -- dsimp [has_scalar],
--   -- rw pi.has_scalar,
-- end


-- From here onwards, the bundled version
-- variable [imCHFPNG : has_images (CompHausFiltPseuNormGrp.{u})]
-- variable [zerCHFPNG : has_zero_morphisms (CompHausFiltPseuNormGrp.{u})]
-- variable [kerCHFPNG : has_kernels (CompHausFiltPseuNormGrp.{u})]



-- def SES_thm69 (S : Fintype) : @category_theory.short_exact_sequence CompHausFiltPseuNormGrp.{u} _
--   imCHFPNG zerCHFPNG kerCHFPNG :=
-- { fst := bundled.of (laurent_measures r S),
--   snd := bundled.of (laurent_measures r S),
--   trd := bundled.of (ℳ p S),
--   f :=
--   begin
--     let φ := λ (F : laurent_measures r S), (ker_θ₂_generator r) • F,
--     use φ,
--     sorry,
--     sorry,
--     sorry,
--     sorry,-- [FAE] These four are the properties that the scalar multiplication by a measure on the
--     --singleton (as endomorphism of S-measures) must satisfy
--   end,
--   g := @Θ r _ S p _ _ _,
--   mono' := sorry,
--   epi' := sorry,
--   exact' := sorry }
-- end SES_thm69
-- end thm_696
