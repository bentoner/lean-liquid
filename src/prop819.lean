import for_mathlib.Cech.split
import for_mathlib.Profinite.functorial_limit
import for_mathlib.simplicial.complex
import for_mathlib.SemiNormedGroup
import for_mathlib.homological_complex

import locally_constant.Vhat
import prop819.completion

open_locale nnreal

noncomputable theory

open category_theory opposite
open SemiNormedGroup

universes u

-- We have a surjective morphism of profinite sets.
variables (F : arrow Profinite.{u}) (surj : function.surjective F.hom)
variables (M : SemiNormedGroup.{u})

abbreviation FL : cochain_complex SemiNormedGroup ℕ :=
  (((cosimplicial_object.augmented.whiskering _ _).obj (LocallyConstant.{u u}.obj M)).obj
  F.augmented_cech_nerve.right_op).to_cocomplex

abbreviation FLC : cochain_complex SemiNormedGroup ℕ :=
  (((cosimplicial_object.augmented.whiskering _ _).obj (LCC.{u u}.obj M)).obj
  F.augmented_cech_nerve.right_op).to_cocomplex

--def Rop : (simplicial_object.augmented Profinite)ᵒᵖ ⥤ cosimplicial_object.augmented Profiniteᵒᵖ :=
--{ obj := λ X, X.unop.right_op,
--  map := λ X Y f,
--  { left := quiver.hom.op (comma_morphism.right f.unop),
--    right := nat_trans.right_op (comma_morphism.left f.unop),
--    w' := by { ext, exact congr_arg (λ η, (nat_trans.app η (op x)).op) f.unop.w.symm, } } }

def FLC_functor : (arrow Profinite.{u})ᵒᵖ ⥤ cochain_complex SemiNormedGroup ℕ :=
simplicial_object.augmented_cech_nerve.op ⋙
  simplicial_to_cosimplicial_augmented _ ⋙
  (cosimplicial_object.augmented.whiskering _ _).obj (LCC.{u u}.obj M) ⋙
  cosimplicial_object.augmented.cocomplex

lemma _root_.cosimplicial_object.augmented.cocomplex_map_norm_noninc
  {C₁ C₂ : cosimplicial_object.augmented SemiNormedGroup} (f : C₁ ⟶ C₂)
  (hf1 : f.left.norm_noninc) (hf2 : ∀ n, (f.right.app n).norm_noninc) (i : ℕ) :
  ((cosimplicial_object.augmented.cocomplex.map f).f i).norm_noninc :=
begin
  cases i,
  { exact hf1 },
  { exact hf2 _ },
end

lemma FLC_functor_map_norm_noninc {f g : (arrow Profinite.{u})ᵒᵖ} (α : f ⟶ g) (i : ℕ) :
  (((FLC_functor M).map α).f i).norm_noninc :=
begin
  refine cosimplicial_object.augmented.cocomplex_map_norm_noninc _ _ _ _,
  { exact SemiNormedGroup.LCC_obj_map_norm_noninc _ _ },
  { intro n,
    exact SemiNormedGroup.LCC_obj_map_norm_noninc _ _ },
end

--⊢ cosimplicial_object.δ
--      (functor.right_op F.cech_nerve ⋙ (curry.obj (uncurry.obj LocallyConstant ⋙ Completion)).obj M)
--      k =
--    Completion.map (cosimplicial_object.δ (functor.right_op F.cech_nerve ⋙ LocallyConstant.obj M) k)

lemma FLC_iso_helper {x y : simplex_category} (f : x ⟶ y) :
  (F.cech_nerve.right_op ⋙ LCC.obj M).map f =
  Completion.map ((F.cech_nerve.right_op ⋙ LocallyConstant.obj M).map f) :=
begin
  change Completion.map _ = _,
  congr' 1,
  dsimp [uncurry],
  erw locally_constant.map_hom_id,
  change 𝟙 _ ≫ _ = _,
  rw category.id_comp,
end

def FLC_iso : strict_iso ((Completion.map_homological_complex _).obj (FL F M)) (FLC F M) :=
{ iso := homological_complex.iso_of_components (λ i,
    match i with
    | 0 := eq_to_iso rfl
    | n+1 := eq_to_iso rfl
    end) begin
      rintro (_|i) (_|j) h; rcases h with _|⟨i,w⟩; ext; dsimp [FLC_iso._match_1];
        split_ifs with hh hh,
      { simp only [category.id_comp, category.comp_id, Completion_map_apply],
        dsimp only [cosimplicial_object.augmented.to_cocomplex_d,
          cosimplicial_object.augmented.drop, comma.snd, cosimplicial_object.whiskering,
          whiskering_right, cosimplicial_object.coboundary, functor.const_comp, LCC],
        simpa },
      { exfalso,
        apply hh,
        refl },
      { simp only [category.id_comp, category.comp_id, Completion_map_apply],
        dsimp only [cosimplicial_object.augmented.to_cocomplex_d,
          cosimplicial_object.augmented.drop, comma.snd, cosimplicial_object.whiskering,
          whiskering_right, cosimplicial_object.coboundary, LCC],
        rw [← Completion_map_apply, Completion.map_sum],
        congr,
        funext k,
        rw [Completion.map_gsmul],
        congr' 1,
        apply FLC_iso_helper },
      { exfalso,
        apply hh,
        refl }
    end,
  is_strict := λ i, { strict_hom' := λ a, by { cases i; refl } } }.

open_locale simplicial

-- TODO: Move this to mathlib (also relax the has_limits condition).
/-- the iso between the 0-th term of the Cech nerve and F.left-/
@[simps]
def cech_iso_zero {C : Type*} [category C] (F : arrow C) [limits.has_limits C]
  : F.cech_nerve _[0] ≅ F.left :=
{ hom := limits.wide_pullback.π _ ⟨0⟩,
  inv := limits.wide_pullback.lift F.hom (λ _, 𝟙 _) (by simp),
  hom_inv_id' := begin
    apply limits.wide_pullback.hom_ext,
    { intro i,
      simp only [limits.wide_pullback.lift_π, category.id_comp, category.comp_id, category.assoc],
      congr,
      tidy },
    { simp }
  end }

lemma augmentation_zero {C : Type*} [category C] (F : arrow C) [limits.has_limits C] :
  (cech_iso_zero F).inv ≫ F.augmented_cech_nerve.hom.app _ = F.hom := by tidy

lemma locally_constant_norm_empty (X : Profinite) (hX : ¬ nonempty X)
  (g : (LocallyConstant.obj M).obj (op X)) : ∥ g ∥ = 0 :=
begin
  rw locally_constant.norm_def,
  dsimp [supr],
  suffices : set.range (λ x : ↥X, ∥ g.to_fun x ∥) = ∅,
  { erw [this, real.Sup_empty],  },
  simp only [set.range_eq_empty, not_nonempty_iff],
  exact not_nonempty_iff.mp hX
end

include surj

lemma prop819_degree_zero_helper :
  function.surjective (limits.wide_pullback.base (λ i : ulift (fin 1), F.hom)) :=
begin
  intro x,
  obtain ⟨x,rfl⟩ := surj x,
  dsimp at *,
  refine ⟨(cech_iso_zero F).inv x, _⟩,
  dsimp,
  change (limits.wide_pullback.lift F.hom _ _ ≫ limits.wide_pullback.base _) _ = _,
  simp,
end

lemma prop819_zero_norm_le (g : (LocallyConstant.obj M).obj (op F.right)) : ∥ g ∥ ≤
  ∥ (LocallyConstant.obj M).map (limits.wide_pullback.base (λ i : ulift (fin 1), F.hom)).op g ∥ :=
begin
  by_cases hh : nonempty F.right,
  { erw real.Sup_le,
    { rintros z ⟨z,rfl⟩,
      obtain ⟨z,rfl⟩ := (prop819_degree_zero_helper _ surj) z,
      change ∥ g.to_fun _ ∥ ≤ _,
      erw ← LocallyConstant_map_apply M _ F.right (limits.wide_pullback.base (λ i, F.hom)) g z,
      apply locally_constant.norm_apply_le },
    { rcases hh with ⟨x⟩,
      refine ⟨∥ g.to_fun x ∥, x, rfl⟩ },
    { use ∥ g ∥,
      rintro y ⟨y,rfl⟩,
      dsimp,
      apply locally_constant.norm_apply_le } },
  { rw locally_constant_norm_empty _ _ hh g,
    simp }
end

theorem prop819_degree_zero (f : (FLC F M).X 0) (hf : (FLC F M).d 0 1 f = 0) :
  f = 0 :=
begin
  apply injective_of_strict_iso _ _ (FLC_iso F M) _ _ hf,
  intros f hf,
  have := @controlled_exactness ((FL F M).X 0) (0 : SemiNormedGroup) ((FL F M).X 1) _ _ _ 0 1
    zero_lt_one 1 ((FL F M).d _ _) _ _ f _ 1 zero_lt_one,
  { rcases this with ⟨g,h1,h2⟩,
    rw ← h1,
    simp },
  { intros g hg,
    refine ⟨0,_, by simp⟩,
    change (FL F M).d 0 1 g = 0 at hg,
    dsimp,
    symmetry,
    delta FL at hg,
    dsimp only [cosimplicial_object.augmented.whiskering,
      cosimplicial_object.augmented.whiskering_obj,
      cosimplicial_object.augmented.to_cocomplex,
      cochain_complex.of] at hg,
    rw dif_pos at hg,
    swap, {simp},
    dsimp [cosimplicial_object.augmented.to_cocomplex_d] at hg,
    simp only [locally_constant.comap_hom_apply, category.id_comp, category.comp_id] at hg,
    ext x,
    obtain ⟨x,rfl⟩ := (prop819_degree_zero_helper F surj) x,
    apply_fun (λ e, e x) at hg,
    dsimp [locally_constant.comap] at hg,
    split_ifs at hg,
    { exact hg },
    { exfalso, apply h, continuity },
    { exfalso, apply h, continuity } },
  { rintro g ⟨g,rfl⟩,
    refine ⟨g,rfl,_⟩,
    dsimp [cosimplicial_object.augmented.to_cocomplex_d],
    simp only [locally_constant.comap_hom_apply, one_mul,
      if_true, eq_self_iff_true, category.id_comp, category.comp_id],
    apply prop819_zero_norm_le _ surj },
  { exact hf }
end

theorem prop819 {m : ℕ} (ε : ℝ≥0) (hε : 0 < ε)
  (f : (FLC F M).X (m+1)) (hf : (FLC F M).d (m+1) (m+2) f = 0) :
  ∃ g : (FLC F M).X m, (FLC F M).d m (m+1) g = f ∧ nnnorm g ≤ (1 + ε) * (nnnorm f) :=
begin
  apply exact_of_strict_iso _ _ (FLC_iso F M) ε hε _ _ _ hf,
  apply cmpl_exact_of_exact _ _ hε,
  clear hf f m hε ε,
  intros n f hf,
  -- We've reduced to the non-completed case.
  sorry,
end
