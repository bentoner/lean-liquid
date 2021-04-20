import thm95.double_complex
import pseudo_normed_group.homotopy

/-!
# A complex canonically isomorphic to `row 1` of the double complex

We have
```
lemma double_complex.row_one :
  (double_complex BD c' r r' V Λ M N).row 1 =
  BD.system c' r V r' (Hom ((cosimplicial Λ N).obj (mk 0)) M) := rfl
```

We want to "rewrite" this row in such a way that it is the target
of the homotopies that will be constructed formally from `BD.homotopy`.

Concretely, we want:
```
(((data.mul N).obj BD.data).system (rescale_constants c_ N) r V r').obj (op (Hom ↥Λ ↥M)) ≅
  (thm95.double_complex BD.data c_ r r' V Λ M N).row 1
```

This means that we need to multiply `BD` by `N`,
and then take the system associated with `rescale N (Hom Λ M)`.

We need the following isomorphisms

* `BD.system M^N = (BD.mul N).system M`
* `Hom (rescale N (Λ^N)) M = (rescale N (Hom Λ M)^N` (2 steps?)
* `(cosimplicial Λ N).obj (mk 0) = rescale N (Λ^N)`

-/

universe variables u

noncomputable theory

open_locale nnreal

local attribute [instance] type_pow

open category_theory

namespace PolyhedralLattice

section
open simplex_category polyhedral_lattice (conerve.L conerve.obj)

variables (N : ℕ) [fact (0 < N)] (Λ : PolyhedralLattice)
variables (r' : ℝ≥0) (M : ProFiltPseuNormGrpWithTinv r')


-- TODO: we probably want some efficient constructor for these isomorphisms,
-- because the default has a lot of redundancy in the proof obligations

def finsupp_fin_one_iso : of (fin 1 →₀ Λ) ≅ Λ :=
sorry

-- the left hand side is by definition the quotient of the right hand side
-- by a subgroup that is provably trivial
noncomputable def conerve_obj_one_iso :
  of (conerve.obj (diagonal_embedding Λ N) 1) ≅ of (fin 1 →₀ (rescale N (fin N →₀ Λ))) :=
{ hom := sorry,
  inv := sorry,
  hom_inv_id' := sorry,
  inv_hom_id' := sorry }

def Hom_rescale_iso [fact (0 < r')] :
  polyhedral_lattice.Hom (rescale N Λ) M ≅
  (ProFiltPseuNormGrpWithTinv.of r' $ (rescale N (polyhedral_lattice.Hom Λ M))) :=
sorry

-- move this
instance : profinitely_filtered_pseudo_normed_group_with_Tinv r' (M ^ N) :=
profinitely_filtered_pseudo_normed_group_with_Tinv.pi _ _

def Hom_finsupp_iso [fact (0 < r')] :
  polyhedral_lattice.Hom (fin N →₀ Λ) M ≅
  (ProFiltPseuNormGrpWithTinv.of r' $ ((polyhedral_lattice.Hom Λ M) ^ N)) :=
sorry

end

end PolyhedralLattice

section rescale

variables {BD : breen_deligne.data}
variables (c_ c_₁ c_₂ : ℕ → ℝ≥0)
variables [BD.suitable c_]
variables (r : ℝ≥0) (V : NormedGroup) [normed_with_aut r V] [fact (0 < r)]
variables {r' : ℝ≥0} [fact (0 < r')] [fact (r' ≤ 1)] (c : ℝ≥0)
variables (M : ProFiltPseuNormGrpWithTinv.{u} r')

-- move this
instance rescale_constants_suitable (N : ℝ≥0) :
  BD.suitable (rescale_constants c_ N) :=
by { delta rescale_constants, apply_instance }

variables (BD)

open breen_deligne opposite ProFiltPseuNormGrpWithTinv (of)

-- this is not `iso.refl` -- so close, and yet so far away
-- the difference is `M_{(c * c_i) * N⁻¹}` vs `M_{c * (c_i * N⁻¹)}`
lemma complex_rescale_eq (N : ℝ≥0) :
  (BD.complex (rescale_constants c_ N) r V r' c).obj (op M) =
  (BD.complex c_ r V r' c).obj (op $ of r' $ rescale N M) :=
begin
  dsimp only [data.complex, rescale_constants],
  haveI : ∀ c c_, fact (c * c_ * N⁻¹ ≤ c * (c_ * N⁻¹)) :=
    λ c c_, by simpa only [mul_assoc] using nnreal.fact_le_refl _,
  transitivity
    (BD.complex₂ r V r' (λ (i : ℕ), c * c_ i * N⁻¹) (λ (i : ℕ), r' * (c * c_ i) * N⁻¹)).obj (op $ of r' M),
  { simp only [mul_assoc, ProFiltPseuNormGrpWithTinv.of_coe] },
  refine cochain_complex.ext (λ i, _),
  dsimp only [data.complex₂, rescale_constants, data.complex₂_d],
  rw ← universal_map.eval_CLCFPTinv₂_rescale,
end
.

-- section

-- attribute [reducible] CLCFPTinv₂ CLCFPTinv₂.res
--   breen_deligne.universal_map.eval_CLCFPTinv₂

-- def complex_rescale_iso (N : ℝ≥0) :
--   (BD.complex (rescale_constants c_ N) r V r' c).obj (op M) ≅
--   (BD.complex c_ r V r' c).obj (op $ of r' $ rescale N M) :=
-- differential_object.complex_like.iso_of_components
--   (λ i, (CLCPTinv.map_nat _ _ _ _ _ _ _ _ _ _ _).app _) _

-- end

noncomputable
def system_rescale_iso (N : ℝ≥0) :
  (BD.system (rescale_constants c_ N) r V r').obj (op M) ≅
  (BD.system c_ r V r').obj (op $ of r' $ rescale N M) :=
nat_iso.of_components (λ c, eq_to_iso $ complex_rescale_eq BD c_ r V c.unop _ _)
begin
  sorry
end

end rescale

namespace thm95

open breen_deligne polyhedral_lattice opposite

variables (BD : breen_deligne.data) (c_ : ℕ → ℝ≥0) [BD.suitable c_]
variables (r : ℝ≥0) (V : NormedGroup) [normed_with_aut r V] [fact (0 < r)]
variables {r' : ℝ≥0} [fact (0 < r')] [fact (r < r')] [fact (r' ≤ 1)] (c : ℝ≥0)

section

attribute [reducible] CLCFPTinv₂ CLCFPTinv₂.res
  breen_deligne.universal_map.eval_CLCFPTinv₂

def mul_complex_iso (N : ℕ) [fact (0 < N)] (M : ProFiltPseuNormGrpWithTinv.{u} r') (c : ℝ≥0) :
  (((data.mul N).obj BD).complex c_ r V r' c).obj (op M) ≅
  (BD.complex c_ r V r' c).obj (op (ProFiltPseuNormGrpWithTinv.of r' $ M^N)) :=
differential_object.complex_like.iso_of_components (λ i, sorry)
begin
  sorry
end

end

def mul_system_iso (N : ℕ) [fact (0 < N)] (M : ProFiltPseuNormGrpWithTinv.{u} r') :
  (((data.mul N).obj BD).system c_ r V r').obj (op M) ≅
  (BD.system c_ r V r').obj (op (ProFiltPseuNormGrpWithTinv.of r' $ M^N)) :=
nat_iso.of_components (λ c, mul_complex_iso BD c_ r V N M c.unop)
begin
  intros c₁ c₂ hc,
  sorry
end

def mul_rescale_iso_row_one
  (N : ℕ) [fact (0 < N)] (N' : ℝ≥0) (h : N' = N)
  (Λ : PolyhedralLattice) (M : ProFiltPseuNormGrpWithTinv.{u} r') :
  (((data.mul N).obj BD).system (rescale_constants c_ N') r V r').obj (op (Hom Λ M)) ≅
    ((thm95.double_complex BD c_ r r' V Λ M N).row 1) :=
(mul_system_iso BD _ r V N _) ≪≫
(system_rescale_iso BD c_ r V _ _) ≪≫
((BD.system c_ r V r').map_iso $ sorry)

lemma mul_rescale_iso_row_one_strict
  (N : ℕ) [fact (0 < N)] (N' : ℝ≥0) (h : N' = N)
  (Λ : PolyhedralLattice) (M : ProFiltPseuNormGrpWithTinv.{u} r')
  (c : ℝ≥0) (i : ℕ)
  (x : (((data.mul N).obj BD).system (rescale_constants c_ N') r V r').obj (op (Hom Λ M)) c i) :
  ∥(mul_rescale_iso_row_one BD c_ r V N N' h Λ M).hom x∥ = ∥x∥ :=
begin
  sorry
end

lemma row_map_eq_sum_comp
  (N : ℕ) [fact (0 < N)] (N' : ℝ≥0) (h : N' = N)
  [∀ (i : ℕ), universal_map.suitable (rescale_constants c_ N' i) (c_ i) ((BD.sum N).f i)]
  (Λ : PolyhedralLattice) (M : ProFiltPseuNormGrpWithTinv.{u} r') :
  (thm95.double_complex BD c_ r r' V Λ M N).row_map 0 1 =
    (iso.refl ((BD.system c_ r V r').obj (op (Hom Λ M)))).inv ≫
    (BD_system_map (BD.sum N) c_
      (rescale_constants c_ N') r V).app (op (Hom Λ M)) ≫
    (thm95.mul_rescale_iso_row_one BD c_ r V N N' h Λ M).hom :=
begin
  unfreezingI { subst h },
  dsimp only [iso.refl_inv],
  erw category.id_comp,
  sorry
end

end thm95
