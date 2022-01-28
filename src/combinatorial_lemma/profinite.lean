import Mbar.functor
import combinatorial_lemma.finite
import algebra.module.linear_map

import category_theory.limits.shapes.products
import topology.category.Compactum

noncomputable theory

open_locale nnreal big_operators

universe u

section
variables (r : ℝ≥0) [fact (0 < r)] (Λ : Type u) [polyhedral_lattice Λ]

open category_theory
open category_theory.limits

-- Sanity check using Mathlib PR: #11690
example : creates_limits
  (forget Profinite.{u}) := infer_instance

lemma polyhedral_exhaustive
  (M : ProFiltPseuNormGrpWithTinv₁ r) (x : Λ →+ M) :
  ∃ c : ℝ≥0, x ∈ pseudo_normed_group.filtration (Λ →+ M) c :=
begin
  obtain ⟨ι,hι,l,hl,h⟩ := polyhedral_lattice.polyhedral Λ,
  resetI,
  let cs : ι → ℝ≥0 := λ i, (M.exhaustive r (x (l i))).some,
  let c := finset.univ.sup (λ i, cs i / ∥l i∥₊),
  -- This should be easy, using the fact that (l i) ≠ 0.
  have hc : ∀ i, cs i ≤ c * ∥l i∥₊,
  { intro i, rw ← mul_inv_le_iff₀,
    { exact finset.le_sup (finset.mem_univ i), },
    { rw [ne.def, nnnorm_eq_zero], exact h i }, },
  use c,
  rw generates_norm.add_monoid_hom_mem_filtration_iff hl x,
  intros i,
  apply pseudo_normed_group.filtration_mono (hc i),
  apply (M.exhaustive r (x (l i))).some_spec,
end

def polyhedral_postcompose {M N : ProFiltPseuNormGrpWithTinv₁ r} (f : M ⟶ N) :
  profinitely_filtered_pseudo_normed_group_with_Tinv_hom r
  (Λ →+ M) (Λ →+ N) :=
{ to_fun := λ x, f.to_add_monoid_hom.comp x,
  map_zero' := by simp only [add_monoid_hom.comp_zero],
  map_add' := by { intros, ext, dsimp, erw [f.to_add_monoid_hom.map_add], refl, },
  strict' := begin
      obtain ⟨ι,hι,l,hl,h⟩ := polyhedral_lattice.polyhedral Λ,
      resetI,
      intros c x hx,
      erw generates_norm.add_monoid_hom_mem_filtration_iff hl at hx ⊢,
      intros i,
      apply f.strict,
      exact hx i,
    end,
  continuous' := sorry,
  map_Tinv' := λ x, by { ext l, dsimp, rw f.map_Tinv, } }

/-- the functor `M ↦ Hom(Λ, M), where both are considered as objects in
  `ProFiltPseuNormGrpWithTinv₁.{u} r` -/
def hom_functor : ProFiltPseuNormGrpWithTinv₁.{u} r ⥤ ProFiltPseuNormGrpWithTinv₁.{u} r :=
{ obj := λ M,
  { M := Λ →+ M,
    str := infer_instance,
    exhaustive' := by { apply polyhedral_exhaustive } },
  map := λ M N f, polyhedral_postcompose _ _ f,
  map_id' := λ M, begin
    ext,
    dsimp [polyhedral_postcompose],
    simp,
  end,
  map_comp' := λ M N L f g, begin
    ext,
    dsimp [polyhedral_postcompose],
    simp,
  end }

open category_theory.limits

-- This should be the functor sending `M` to `α → M`.
def pi_functor (α : Type u) [fintype α] :
  ProFiltPseuNormGrpWithTinv₁.{u} r ⥤ ProFiltPseuNormGrpWithTinv₁.{u} r :=
{ obj := λ M, ProFiltPseuNormGrpWithTinv₁.product r (λ i : α, M),
  map := λ M N f, ProFiltPseuNormGrpWithTinv₁.product.lift _ _ _ $
    λ i, ProFiltPseuNormGrpWithTinv₁.product.π _ _ i ≫ f } .

def hom_functor_forget_iso {α : Type u} [fintype α] (e : basis α ℤ Λ) :
  pi_functor r α ⋙ forget _ ≅ hom_functor r Λ ⋙ forget _ :=
nat_iso.of_components
(λ X,
  { hom := λ (f : α → X), (e.constr ℤ f).to_add_monoid_hom,
    inv := λ (f : Λ →+ X), (e.constr ℤ : (α → X) ≃ₗ[ℤ] _).symm f.to_int_linear_map,
    hom_inv_id' := sorry,
    inv_hom_id' := sorry }) sorry

/-

Hom(Λ, lim_i A_i)_{≤ c} should be "the same" as
lim_i Hom(Λ, A_i)_{≤ c}

I'm fairly sure this is correct, but this will be a bit of a challenge to prove...

Idea:

Since the forgetful functor on profinite creates limits, it suffices to prove this for the
underlying sets.

Now, choose a finite basis `e` for `Λ`, and a family `m : ι → Λ` generating the norm for `Λ`.
This gives us a map
`Hom(Λ,M) → (ι → M)`
given by composition with `m`.

Since `Λ` has a finite basis `e`, it follows that `Hom(Λ,-)` commutes with limits.
One might expect this to be true in general, but there is a subtlety in how limits are defined
in `ProFiltPseuNormGroupWithTinv₁`, as they are essentially of the form `colim_c (lim_i M_{i,c})`,
so one needs to use the fact that finite limits commute with filtered colimits to obtain this
(and this is where the finiteness of the basis is used).
Similarly, `ι` is finite, so that `(ι → M)` commutes with limits in the variable `M`.

Now we can identify `(ι → M)` with the categorical product in `ProFilt...₁`, and use the fact
that the functor `level.obj c` preserves limits to obtain the desired result.
-/

-- See note above.
instance pi_functor_forget_preserves_limits {α : Type u} [fintype α] :
  preserves_limits (pi_functor r α ⋙ forget _) := sorry

instance hom_functor_forget_preserves_limits :
  preserves_limits (hom_functor r Λ ⋙ forget _) :=
begin
  -- Λ is finite free.
  have : ∃ (α : Type u) (hα : fintype α) (e : basis α ℤ Λ), true := sorry,
  choose α hα e h using this,
  resetI,
  let e : (pi_functor r α ⋙ forget _) ≅ (hom_functor r Λ ⋙ forget _) :=
    (hom_functor_forget_iso r Λ e),
  apply preserves_limits_of_nat_iso e,
end

-- NOTE: `polyhedral_lattice.polyhedral` uses `ι : Type` instead of a universe polymorphic variant.
-- We mimic `ι : Type` here...
def hom_functor_level_forget_aux {ι : Type} [fintype ι] (m : ι → Λ)
  (hm : generates_norm m) (c : ℝ≥0) :
  ProFiltPseuNormGrpWithTinv₁.{u} r ⥤ Type u :=
{ obj := λ M,
    { f : Λ →+ M | ∀ i : ι, f (m i) ∈ pseudo_normed_group.filtration M (c * ∥ m i ∥₊) },
  map := λ M N f t, ⟨f.to_add_monoid_hom.comp t, λ i, f.strict (t.2 i)⟩,
  map_id' := λ M, by { ext, refl },
  map_comp' := by { intros, ext, refl } }

def hom_functor_level_forget_aux_incl {ι : Type} [fintype ι] (m : ι → Λ)
  (hm : generates_norm m) (c : ℝ≥0) :
  hom_functor_level_forget_aux r Λ m hm c ⟶ hom_functor r Λ ⋙ forget _:=
{ app := λ X t, t.1,
  naturality' := λ M N f, by { ext, refl } }

-- This instance can probably be proved by hand.
instance hom_functor_level_forget_aux_preserves_limits {ι : Type} [fintype ι] (m : ι → Λ)
  (hm : generates_norm m) (c : ℝ≥0) :
  preserves_limits (hom_functor_level_forget_aux r Λ m hm c) :=
begin
  constructor, introsI J hJ, constructor, intros K, constructor, intros C hC,
  -- `Hom(Λ,C.X)` is the limit of of `Hom(Λ,K.obj j)`.
  let hC' := is_limit_of_preserves (hom_functor r Λ ⋙ forget _) hC,
  -- `C.X_{≤ c}` is the limit of of `(K.obj j)_{≤ c}`, when considered as sets.
  let hC'' := λ (c : ℝ≥0),
    is_limit_of_preserves (ProFiltPseuNormGrpWithTinv₁.to_PFPNG₁ r ⋙
      ProFiltPseuNormGrp₁.level.obj c ⋙ forget _) hC,
  refine ⟨λ S, _, _, _⟩,
  { let η : K ⋙ hom_functor_level_forget_aux r Λ m hm c ⟶
      K ⋙ (hom_functor r Λ ⋙ forget _) :=
      whisker_left _ (hom_functor_level_forget_aux_incl r Λ m hm c),
    let T := (cones.postcompose η).obj S,
    let t := hC'.lift T,
    refine (λ x, ⟨t x, _⟩),
    intros i,
    -- Now we should use hC''
    sorry },
  { sorry },
  { sorry }
end

-- This is more-or-less by definition!
-- TODO: The definition of this nat_iso can be broken up a bit.
-- for example, the isomorphism of the individual types is essentially just
-- and equivalence of subtypes defined by equivalent predicates. I'm sure
-- we have some general equivalence we can use here, but one would still
-- have to convert a type equivalence to an isomoprhism in the category `Type u`.
def hom_functor_level_forget_iso {ι : Type} [fintype ι] (m : ι → Λ)
  (hm : generates_norm m) (c : ℝ≥0) :
  hom_functor_level_forget_aux r Λ m hm c ≅
  hom_functor r Λ ⋙
  ProFiltPseuNormGrpWithTinv₁.to_PFPNG₁ r ⋙
  ProFiltPseuNormGrp₁.level.obj c ⋙
  forget _ :=
nat_iso.of_components (λ M,
{ hom := λ t, ⟨t.1, begin
    erw generates_norm.add_monoid_hom_mem_filtration_iff hm,
    intros i,
    apply t.2,
  end⟩,
  inv := λ t, ⟨t.1, begin
    dsimp,
    erw ← generates_norm.add_monoid_hom_mem_filtration_iff hm,
    exact t.2,
  end⟩,
  hom_inv_id' := by { ext, refl },
  inv_hom_id' := by { ext, refl } }) $ by { intros, ext, refl }

instance hom_functor_level_forget_preserves_limits (c) : preserves_limits (
  hom_functor r Λ ⋙
  ProFiltPseuNormGrpWithTinv₁.to_PFPNG₁ r ⋙
  ProFiltPseuNormGrp₁.level.obj c ⋙
  forget _ ) :=
begin
  choose ι hι m hm h using polyhedral_lattice.polyhedral Λ,
  resetI,
  apply preserves_limits_of_nat_iso (hom_functor_level_forget_iso r Λ m hm c),
end

instance hom_functor_level_preserves_limits (c) : preserves_limits (
  hom_functor r Λ ⋙
  ProFiltPseuNormGrpWithTinv₁.to_PFPNG₁ r ⋙
  ProFiltPseuNormGrp₁.level.obj c ) :=
begin
  apply preserves_limits_of_reflects_of_preserves _ (forget Profinite),
  -- A hack, to avoid functor composition associativity...
  apply hom_functor_level_forget_preserves_limits,
end

end

/-- Lemma 9.8 of [Analytic] -/
lemma lem98 (r' : ℝ≥0) [fact (0 < r')] [fact (r' < 1)]
  (Λ : Type*) [polyhedral_lattice Λ] (S : Profinite) (N : ℕ) [hN : fact (0 < N)] :
  pseudo_normed_group.splittable (Λ →+ (Mbar.functor r').obj S) N (lem98.d Λ N) :=
begin
  -- This reduces to `lem98_finite`: See the first lines of the proof in [Analytic].
  sorry
end
