import for_mathlib.derived.les_facts
import liquid
import Lbar.functor
import condensed.projective_resolution
import condensed.condensify
import condensed.bd_lemma
import breen_deligne.eg

import for_mathlib.derived.ext_coproducts
import condensed.ab4
import Lbar.squares
import pseudo_normed_group.QprimeFP
import for_mathlib.acyclic
import free_pfpng.acyclic
import for_mathlib.SemiNormedGroup_ulift
import for_mathlib.bicartesian4
import for_mathlib.has_homology_aux

import for_mathlib.derived.Ext_lemmas

noncomputable theory

universes u

open opposite category_theory category_theory.limits
open_locale nnreal zero_object


variables (r r' : ℝ≥0)
variables [fact (0 < r)] [fact (0 < r')] [fact (r < r')] [fact (r < 1)] [fact (r' < 1)]

abbreviation SemiNormedGroup.to_Cond (V : SemiNormedGroup.{u}) := Condensed.of_top_ab V

section

open bounded_homotopy_category

variables (BD : breen_deligne.data)
variables (κ κ₂ : ℝ≥0 → ℕ → ℝ≥0)
variables [∀ (c : ℝ≥0), BD.suitable (κ c)] [∀ n, fact (monotone (function.swap κ n))]
variables [∀ (c : ℝ≥0), BD.suitable (κ₂ c)] [∀ n, fact (monotone (function.swap κ₂ n))]
variables (M : ProFiltPseuNormGrpWithTinv₁.{u} r')
variables (V : SemiNormedGroup.{u}) [complete_space V] [separated_space V]

lemma ExtQprime_iso_aux_system_aux (c : ℝ≥0) (k i : ℤ) (hi : i > 0) :
  is_zero (((Ext' i).obj (op (((homological_complex.embed complex_shape.embedding.nat_down_int_up).obj
      ((QprimeFP_nat.{u} r' BD κ M).obj c)).X k))).obj V.to_Cond) :=
begin
  rcases k with (_|_)|_,
  { apply free_acyclic.{u} _ V i hi },
  { apply bounded_derived_category.Ext'_zero_left_is_zero, refine (is_zero_zero _).op },
  { apply free_acyclic.{u} _ V i hi },
end

def embed_unop {𝓐 : Type*} [category 𝓐] [abelian 𝓐] :
  (homological_complex.embed complex_shape.embedding.nat_down_int_up).op ⋙
    @homological_complex.unop_functor 𝓐 _ _ _ _ ≅
  homological_complex.unop_functor ⋙
    homological_complex.embed complex_shape.embedding.nat_up_int_down :=
begin
  refine nat_iso.of_components _ _,
  { intro X, refine homological_complex.hom.iso_of_components _ _,
    { rintro ((_|n)|n),
      { exact iso.refl _ },
      { refine is_zero.iso (is_zero_zero _).unop (is_zero_zero _), },
      { exact iso.refl _ }, },
    { rintro i (j|(_|j)) (rfl : _ = _),
      { apply is_zero.eq_of_src, exact (is_zero_zero _).unop },
      { dsimp only [iso.refl_hom], erw [category.id_comp, category.comp_id], refl },
      { dsimp only [iso.refl_hom], erw [category.id_comp, category.comp_id], refl }, } },
  { intros X Y f, ext ((_|n)|n),
    { dsimp only [homological_complex.comp_f, homological_complex.hom.iso_of_components_hom_f, iso.refl_hom],
      erw [category.id_comp, category.comp_id], refl },
    { apply is_zero.eq_of_tgt, exact is_zero_zero _ },
    { dsimp only [homological_complex.comp_f, homological_complex.hom.iso_of_components_hom_f, iso.refl_hom],
      erw [category.id_comp, category.comp_id], refl } }
end
.

-- move me
lemma nat_up_int_down_c_iff : complex_shape.embedding.nat_up_int_down.c_iff :=
λ i j, complex_shape.embedding.nat_down_int_up_c_iff j i

def forget₂_unop :
  ((forget₂ SemiNormedGroup Ab).op.map_homological_complex (complex_shape.down ℕ)).op ⋙
  homological_complex.unop_functor ≅
  homological_complex.unop_functor ⋙
  (forget₂ SemiNormedGroup Ab).map_homological_complex (complex_shape.down ℕ).symm :=
begin
  refine nat_iso.of_components _ _,
  { intro X, refine homological_complex.hom.iso_of_components _ _,
    { intro n, exact iso.refl _ },
    { rintro i j (rfl : _ = _), dsimp only [iso.refl_hom],
      rw [category.id_comp, category.comp_id], refl } },
  { intros X Y f, ext n,
    dsimp only [homological_complex.comp_f, homological_complex.hom.iso_of_components_hom_f, iso.refl_hom],
    rw [category.id_comp, category.comp_id], refl }
end
.

def preadditive_yoneda_obj_obj_CondensedSet_to_Condensed_Ab
  (M : Condensed.{u} Ab.{u+1}) (X : Profinite) :
  (preadditive_yoneda.obj M).obj (op $ CondensedSet_to_Condensed_Ab.obj (Profinite_to_Condensed.obj X)) ≅
  M.val.obj (op X) :=
let e := Condensed_Ab_CondensedSet_adjunction.hom_equiv X.to_Condensed M in
add_equiv.to_AddCommGroup_iso $
{ to_fun := λ t, yoneda'_equiv _ _ (e t).val,
  inv_fun := λ t, e.symm $ ⟨(yoneda'_equiv _ _).symm $ by apply t⟩,
  left_inv := λ t, begin
    dsimp only,
    apply_fun e, rw equiv.apply_symm_apply, ext1,
    dsimp only, erw equiv.apply_symm_apply,
  end,
  right_inv := λ t, begin
    dsimp only,
    rw equiv.apply_symm_apply,
    rw equiv.apply_symm_apply,
  end,
  map_add' := begin
    intros x y,
    refl,
  end }

end

