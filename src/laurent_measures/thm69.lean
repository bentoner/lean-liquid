-- import for_mathlib.short_exact_sequence
import laurent_measures.basic
import laurent_measures.theta


namespace thm_69

-- open category_theory category_theory.limits
open theta laurent_measures
open_locale nnreal classical big_operators


-- universe u
variables (p : ℝ≥0) [fact (0 < p)] [fact (p < 1)]
variables (r : ℝ≥0) [fact (0 < r)] [fact (r < 1)]
-- variables (r : ℝ≥0) [fact ((1 / 2 : ℝ) ^ p.1 = r)]

lemma r_pos : 0 < r ∧ r < 1 := sorry

lemma r_one : r < 1 := sorry

lemma half_ineq : (1 / 2 : ℝ) < r :=
begin
  sorry,
end

noncomputable theory

instance (S : Fintype) : has_scalar (laurent_measures r (Fintype.of punit)) (laurent_measures r S) :=
{ smul := sorry}


section ker_theta_half
-- open submodule linear_map

def θₗ : (laurent_measures r (Fintype.of punit)) →ₗ[ℤ] ℝ :=
{ to_fun := λ F, tsum (λ n, (F punit.star n) * (1 / 2 : ℝ) ^ n),
  map_add' :=
   begin
    intros F G,
    rw ← tsum_add,
    apply tsum_congr,
    intro m,
    rw [← add_mul, mul_eq_mul_right_iff],
    apply or.intro_left,
    rw [← int.cast_add, int.cast_inj],
    apply laurent_measures.add_apply,
    sorry, sorry,
  end,
  map_smul' := sorry }

-- lemma θ_is_linear (ξ : ℝ) : is_linear_map ℤ (θ ξ r) := sorry

-- noncomputable def θ₂.to_linear : (laurent_measures r (Fintype.of punit)) →ₗ[ℤ] ℝ :=
-- { to_fun := θ (1 / 2) r,
--   map_add' := (θ_is_linear r (1 / 2)).1,
--   map_smul' := (θ_is_linear r (1 / 2) ).2 }

lemma ker_θ₂_principal : submodule.is_principal ((θₗ r).ker) :=
begin
  -- constructor,
  let pos : ℕ → ℤ := λ n, (if n = 0 then -1 else if n = 1 then 2 else 0),
  let f₀ : ℤ → ℤ := λ d : ℤ, int.rec_on d (pos) (λ n, 0),
  use (λ s, f₀),
  sorry,
  ext,
  split,
  swap,
  intro h_x,
  -- sorry,
  -- sorry,
  obtain ⟨a, h_ax⟩ := submodule.mem_span_singleton.mp h_x,
  apply linear_map.mem_ker.mpr,
  rw ← h_ax,
  simp,
  apply or.intro_right,
  sorry, sorry
  -- rw θₗ,
--   rw θ₂.to_linear,
--   -- rw θ.to_linear,
  -- simp,
--   rw θ,
--   simp,
--   simp_rw [laurent_measures.to_Rfct],
--   let S : finset ℤ := {0, 1},
--   have hf : function.support f₀ ⊆ S, sorry,
--   have hf₀ : ∀ s ∉ S, ((f₀ s) : ℝ) * ((2 ^ s) : ℝ)⁻¹ = (0 : ℝ), sorry,
--   rw [tsum_eq_sum hf₀],
--   -- rw ← [has_sum_subtype_iff_of_support_subset hf],
--   sorry, sorry,
end


def ker_θ₂_generator : (laurent_measures r (Fintype.of punit)) :=
  @submodule.is_principal.generator _ _ _ _ _ (linear_map.ker (θₗ r)) (ker_θ₂_principal r)

/- [FAE] The following lemma needs that `(laurent_measures r (Fintype.of punit))` have a `mul`; but
I don't know if the lemma is actually needed -/
-- lemma ker_generator_non_zerodivisor : is_regular (ker_generator ξ) :=

end ker_theta_half

section SES_thm69

local notation `ℳ` := real_measures
local notation `𝑓` := (ker_θ₂_generator r)
variable (S : Fintype)
-- variables (p : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)] [fact ((1/2 : ℝ) ^ (p : ℝ) = r)]

include r

/-- This `θ₂` is the "measurification" of the map `θₗ` of
Theorem 6.9. Thus, `to_meas_θ` is the map inducing the isomorphism of Theorem 6.9 (2)-/
def θ₂ : laurent_measures r S → ℳ p S :=
λ F s, θₗ r ⟨(λ _, F s), (λ _, F.2 s)⟩

lemma θ₂_zero :
 (θ₂ p r S (0 : laurent_measures r S)) = 0 := sorry

lemma θ₂_add (F G : laurent_measures r S) :
 (θ₂ p r S (F + G)) = (θ₂ p r S F) + (θ₂ p r S G) := sorry

/--This `lemma to_meas_θ_bound` is precisely Prop 7.2 (3) of `Analytic.pdf`-/
lemma θ₂_bound : ∃ (C : ℝ≥0), ∀ (c : ℝ≥0) (F : laurent_measures r S),
  ∥ F ∥ ≤ c → ∥ θ₂ p r S F ∥₊ ≤ C * c := sorry

def to_add_hom_θ₂ : add_hom (laurent_measures r S) (ℳ p S) :=
add_monoid_hom.mk' (λ F, θ₂ p r S F)
begin
    intros a b,
    have := θ₂_add p r S a b,
    exact this,
  end

def Θ : comphaus_filtered_pseudo_normed_group_hom (laurent_measures r S) (ℳ p S) :=
  { to_fun := θ₂ p r S,
    bound' := θ₂_bound p r S,
    continuous' := sorry, -- [FAE] I guess that this is Prop 7.2 (4) of `Analytic.pdf`
    -- .. to_add_hom_meas_θ ξ r S p,
    map_add' := (to_add_hom_θ₂ p r S).2,
    map_zero' := sorry }


lemma chain_complex_thm69 (F : laurent_measures r S) : Θ p r S (𝑓 • F) = 0 :=
begin
  funext s,
  sorry,
  -- simp only [real_measures.zero_apply],
  -- dsimp [Θ],
  -- dsimp [to_meas_θ],
  -- dsimp [θ],
  -- dsimp [has_scalar],
  -- rw pi.has_scalar,
end


/-
From here onwards, the bundled version
-/
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

end SES_thm69

end thm_69
